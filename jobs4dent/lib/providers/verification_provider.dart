import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
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

      // Update user's verification status and documents in Firestore
      await _firestore.collection('users').doc(userId).update({
        'verificationStatus': 'pending',
        'verificationDocuments': documentUrls,
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
        'verificationRejectionReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _uploadedDocuments = documentUrls;
      _isLoading = false;
      notifyListeners();

      debugPrint('Successfully uploaded ${documentUrls.length} verification documents for user $userId');

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

  // Pick files for verification with validation
  Future<List<File>?> pickVerificationDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
        allowCompression: true,
        withData: false, // Don't load file data into memory immediately
      );

      if (result != null && result.files.isNotEmpty) {
        List<File> selectedFiles = [];
        
        // Validate each selected file
        for (final platformFile in result.files) {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            
            // Check if file exists
            if (!await file.exists()) {
              _error = 'ไม่พบไฟล์: ${platformFile.name}';
              notifyListeners();
              return null;
            }
            
            // Check file size (max 10MB)
            final fileSize = await file.length();
            if (fileSize > 10 * 1024 * 1024) {
              _error = 'ไฟล์ ${platformFile.name} มีขนาดเกิน 10 MB';
              notifyListeners();
              return null;
            }
            
            // Check if file is empty
            if (fileSize == 0) {
              _error = 'ไฟล์ ${platformFile.name} ว่างเปล่า';
              notifyListeners();
              return null;
            }
            
            selectedFiles.add(file);
          }
        }
        
        if (selectedFiles.isEmpty) {
          _error = 'ไม่พบไฟล์ที่ถูกต้อง';
          notifyListeners();
          return null;
        }
        
        return selectedFiles;
      }
      return null;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเลือกไฟล์: ${e.toString()}';
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
        if (deleteOldDocuments) 'verificationDocuments': [],
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
    if (user.verificationDocuments != null && user.verificationDocuments!.isNotEmpty) return 0.5;
    return 0.0;
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