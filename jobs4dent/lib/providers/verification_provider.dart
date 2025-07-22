import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';

class VerificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  String? _error;
  List<String> _uploadedDocuments = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get uploadedDocuments => _uploadedDocuments;

  // Document types required for each user type
  Map<String, List<String>> get requiredDocuments => {
    'dentist': ['ใบประกอบวิชาชีพทันตกรรม'],
    'clinic': ['ใบอนุญาตให้ประกอบกิจการสถานพยาบาล (ส.พ.7)'],
    'assistant': ['ใบประกาศนียบัตรผู้ช่วยทันตแพทย์', 'บัตรประชาชน'],
  };

  // Get verification status color
  Color getVerificationStatusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get verification status text
  String getVerificationStatusText(String status) {
    switch (status) {
      case 'verified':
        return 'ยืนยันแล้ว';
      case 'pending':
        return 'รอการตรวจสอบ';
      case 'rejected':
        return 'ไม่ผ่านการตรวจสอบ';
      default:
        return 'ยังไม่ยืนยัน';
    }
  }

  // Get verification status icon
  IconData getVerificationStatusIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.verified;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.warning;
    }
  }

  // Upload verification documents to Firebase Storage
  Future<void> uploadVerificationDocuments({
    required String userId,
    required List<File> documents,
    required String userType,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      List<String> documentUrls = [];
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Validate files before upload
      for (final file in documents) {
        // Check file size (max 10MB per file)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          throw Exception('ไฟล์ ${file.path.split('/').last} มีขนาดเกิน 10 MB');
        }

        // Check file extension
        final extension = file.path.split('.').last.toLowerCase();
        if (!['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
          throw Exception('ไฟล์ ${file.path.split('/').last} ไม่ใช่ประเภทที่รองรับ');
        }
      }

      // Upload each document to Firebase Storage
      for (int i = 0; i < documents.length; i++) {
        final file = documents[i];
        final extension = file.path.split('.').last.toLowerCase();
        final fileName = 'verification_${userId}_${userType}_${timestamp}_$i.$extension';
        
        // Create reference to Firebase Storage
        final ref = _storage.ref().child('verification_documents').child(userId).child(fileName);
        
        try {
          // Upload file to Firebase Storage
          final uploadTask = ref.putFile(
            file,
            SettableMetadata(
              contentType: _getContentType(extension),
              customMetadata: {
                'userId': userId,
                'userType': userType,
                'uploadedAt': DateTime.now().toIso8601String(),
              },
            ),
          );

          // Wait for upload completion
          final snapshot = await uploadTask;
          
          // Get download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();
          
          documentUrls.add(downloadUrl);
          
          debugPrint('Successfully uploaded file $i: $downloadUrl');
        } catch (uploadError) {
          // If one file fails, delete already uploaded files
          for (final url in documentUrls) {
            try {
              await _storage.refFromURL(url).delete();
            } catch (deleteError) {
              debugPrint('Failed to delete file during cleanup: $deleteError');
            }
          }
          throw Exception('เกิดข้อผิดพลาดในการอัปโหลดไฟล์ ${file.path.split('/').last}: ${uploadError.toString()}');
        }
      }

      // Get current verification documents from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? <String, dynamic>{};
      
      // Get existing documents or empty list if none exist
      final existingDocuments = List<String>.from(userData['verificationDocuments'] ?? []);
      
      // Append new documents to existing ones
      final allDocuments = [...existingDocuments, ...documentUrls];
      
      // Update user's verification status and documents in Firestore
      await _firestore.collection('users').doc(userId).update({
        'verificationStatus': 'pending',
        'verificationDocuments': allDocuments,
        'verificationDocumentCounts': allDocuments.length,
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
        'verificationRejectionReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _uploadedDocuments = allDocuments;
      _isLoading = false;
      notifyListeners();

      debugPrint('Successfully uploaded ${documentUrls.length} new verification documents for user $userId. Total documents: ${allDocuments.length}');

    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการอัปโหลดเอกสาร: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Helper method to get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  // Pick images from Photo Gallery for verification with validation
  Future<List<File>?> pickVerificationDocuments() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show dialog to user to choose single or multiple images
      final List<XFile> selectedImages = await picker.pickMultiImage(
        imageQuality: 85, // Compress images to reduce file size
      );

      if (selectedImages.isNotEmpty) {
        List<File> selectedFiles = [];
        
        // Validate each selected image
        for (final xFile in selectedImages) {
          final file = File(xFile.path);
          
          // Check if file exists
          if (!await file.exists()) {
            _error = 'ไม่พบไฟล์: ${xFile.name}';
            notifyListeners();
            return null;
          }
          
          // Check file size (max 10MB)
          final fileSize = await file.length();
          if (fileSize > 10 * 1024 * 1024) {
            _error = 'รูปภาพ ${xFile.name} มีขนาดเกิน 10 MB';
            notifyListeners();
            return null;
          }
          
          // Check if file is empty
          if (fileSize == 0) {
            _error = 'รูปภาพ ${xFile.name} ว่างเปล่า';
            notifyListeners();
            return null;
          }
          
          selectedFiles.add(file);
        }
        
        if (selectedFiles.isEmpty) {
          _error = 'ไม่พบรูปภาพที่ถูกต้อง';
          notifyListeners();
          return null;
        }
        
        return selectedFiles;
      }
      return null;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเลือกรูปภาพ: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Pick a single image from Photo Gallery (alternative method)
  Future<File?> pickSingleVerificationDocument() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Pick single image from gallery
      final XFile? selectedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress image to reduce file size
      );

      if (selectedImage != null) {
        final file = File(selectedImage.path);
        
        // Check if file exists
        if (!await file.exists()) {
          _error = 'ไม่พบรูปภาพ';
          notifyListeners();
          return null;
        }
        
        // Check file size (max 10MB)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          _error = 'รูปภาพมีขนาดเกิน 10 MB';
          notifyListeners();
          return null;
        }
        
        // Check if file is empty
        if (fileSize == 0) {
          _error = 'รูปภาพว่างเปล่า';
          notifyListeners();
          return null;
        }
        
        return file;
      }
      return null;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเลือกรูปภาพ: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Admin methods for reviewing verification
  Future<void> approveVerification({
    required String userId,
    required String adminId,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'verificationStatus': 'verified',
        'verificationReviewedAt': FieldValue.serverTimestamp(),
        'reviewedByAdminId': adminId,
        'verificationRejectionReason': null,
      });
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการอนุมัติ: ${e.toString()}');
    }
  }

  Future<void> rejectVerification({
    required String userId,
    required String adminId,
    required String reason,
    bool deleteOldDocuments = false,
  }) async {
    try {
      // Optionally delete old verification documents
      if (deleteOldDocuments) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final oldDocuments = List<String>.from(userData['verificationDocuments'] ?? []);
          if (oldDocuments.isNotEmpty) {
            await deleteVerificationDocuments(oldDocuments);
          }
        }
      }

      await _firestore.collection('users').doc(userId).update({
        'verificationStatus': 'rejected',
        'verificationReviewedAt': FieldValue.serverTimestamp(),
        'reviewedByAdminId': adminId,
        'verificationRejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
        // Optionally clear old documents if deleted
        if (deleteOldDocuments) ...{
          'verificationDocuments': [],
          'verificationDocumentCounts': 0,
        },
      });
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการปฏิเสธ: ${e.toString()}');
    }
  }

  // Get pending verifications for admin
  Stream<QuerySnapshot> getPendingVerifications() {
    return _firestore
        .collection('users')
        .where('verificationStatus', isEqualTo: 'pending')
        .snapshots();
  }

  // Check if user can perform certain actions based on verification status
  bool canPerformAction(String verificationStatus, String action) {
    if (verificationStatus == 'verified') return true;
    
    // Define actions that require verification
    const restrictedActions = [
      'apply_for_job',
      'post_job',
      'contact_users',
      'access_full_features',
    ];
    
    return !restrictedActions.contains(action);
  }

  // Get verification progress percentage
  double getVerificationProgress(UserModel user) {
    if (user.verificationStatus == 'verified') return 1.0;
    if (user.verificationStatus == 'pending') return 0.7;
    // Use verificationDocumentCounts for better performance, fallback to checking array
    if ((user.verificationDocumentCounts != null && user.verificationDocumentCounts! > 0) ||
        (user.verificationDocuments != null && user.verificationDocuments!.isNotEmpty)) {
      return 0.5;
    }
    return 0.0;
  }

  // Get the number of verification documents (optimized with count field)
  int getVerificationDocumentCount(UserModel user) {
    // Use the new count field if available for better performance
    if (user.verificationDocumentCounts != null) {
      return user.verificationDocumentCounts!;
    }
    // Fallback to checking array length if count field is not available
    return user.verificationDocuments?.length ?? 0;
  }

  // Check if user has any verification documents (optimized with count field)
  bool hasVerificationDocuments(UserModel user) {
    // Use the new count field if available for better performance
    if (user.verificationDocumentCounts != null) {
      return user.verificationDocumentCounts! > 0;
    }
    // Fallback to checking array if count field is not available
    return user.verificationDocuments != null && user.verificationDocuments!.isNotEmpty;
  }

  // Delete verification documents from Firebase Storage
  Future<void> deleteVerificationDocuments(List<String> documentUrls) async {
    try {
      for (final url in documentUrls) {
        try {
          final ref = _storage.refFromURL(url);
          await ref.delete();
          debugPrint('Successfully deleted document: $url');
        } catch (deleteError) {
          debugPrint('Failed to delete document $url: $deleteError');
          // Continue with other files even if one fails
        }
      }
    } catch (e) {
      debugPrint('Error deleting verification documents: $e');
      // Don't throw error here as this might be called during cleanup
    }
  }

  // Delete a single verification document by index
  Future<void> deleteSingleVerificationDocument({
    required String userId,
    required int documentIndex,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get current user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? <String, dynamic>{};
      
      // Get current documents array
      final currentDocuments = List<String>.from(userData['verificationDocuments'] ?? []);
      
      // Validate index
      if (documentIndex < 0 || documentIndex >= currentDocuments.length) {
        throw Exception('ดัชนีเอกสารไม่ถูกต้อง');
      }
      
      // Get the document URL to delete from Storage
      final documentUrlToDelete = currentDocuments[documentIndex];
      
      // Delete from Firebase Storage
      try {
        final ref = _storage.refFromURL(documentUrlToDelete);
        await ref.delete();
        debugPrint('Successfully deleted document from Storage: $documentUrlToDelete');
      } catch (storageError) {
        debugPrint('Failed to delete document from Storage: $storageError');
        // Continue with Firestore update even if Storage deletion fails
      }
      
      // Remove document from array
      currentDocuments.removeAt(documentIndex);
      
      // Update Firestore with new array and count
      await _firestore.collection('users').doc(userId).update({
        'verificationDocuments': currentDocuments,
        'verificationDocumentCounts': currentDocuments.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      _isLoading = false;
      notifyListeners();
      
      debugPrint('Successfully deleted document at index $documentIndex. Remaining documents: ${currentDocuments.length}');
      
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการลบเอกสาร: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get file info from Firebase Storage
  Future<Map<String, dynamic>?> getFileInfo(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final metadata = await ref.getMetadata();
      
      return {
        'name': ref.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'created': metadata.timeCreated,
        'updated': metadata.updated,
        'customMetadata': metadata.customMetadata,
      };
    } catch (e) {
      debugPrint('Error getting file info: $e');
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _isLoading = false;
    _error = null;
    _uploadedDocuments = [];
    notifyListeners();
  }
} 