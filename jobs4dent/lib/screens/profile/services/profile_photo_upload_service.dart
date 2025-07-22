import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../../providers/auth_provider.dart';

class ProfilePhotoUploadService {
  static Future<void> showPhotoSelectionModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'เลือกรูปภาพโปรไฟล์',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery option
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            size: 40,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'คลังภาพ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Camera option
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.green[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'กล้อง',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
            ],
          ),
        );
      },
    );
  }

  // Pick image from gallery
  static Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      debugPrint('🖼️ Starting image picker from gallery...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Reduced quality for smaller file size
        maxWidth: 200,    // 10% resolution (reduced from 1920)
        maxHeight: 200,   // 10% resolution (reduced from 1920)
      );

      debugPrint('📷 Image picker result: ${image?.path ?? "null"}');

      if (image != null) {
        debugPrint('✅ Image selected: ${image.path}');
        final imageFile = File(image.path);
        debugPrint('📁 File exists: ${await imageFile.exists()}');
        
        if (context.mounted) {
          debugPrint('📤 Starting upload process...');
          await _uploadProfilePhoto(context, imageFile);
        } else {
          debugPrint('❌ Widget not mounted when trying to upload');
        }
      } else {
        debugPrint('❌ No image selected from gallery');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่ได้เลือกรูปภาพ'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error in _pickImageFromGallery: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเลือกรูปภาพ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Pick image from camera
  static Future<void> _pickImageFromCamera(BuildContext context) async {
    try {
      debugPrint('📷 Starting camera...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Reduced quality for smaller file size
        maxWidth: 200,    // 10% resolution (reduced from 1920)
        maxHeight: 200,   // 10% resolution (reduced from 1920)
        preferredCameraDevice: CameraDevice.rear,
      );

      debugPrint('📷 Camera result: ${image?.path ?? "null"}');

      if (image != null) {
        debugPrint('✅ Photo captured: ${image.path}');
        final imageFile = File(image.path);
        debugPrint('📁 File exists: ${await imageFile.exists()}');
        
        if (context.mounted) {
          debugPrint('📤 Starting upload process...');
          await _uploadProfilePhoto(context, imageFile);
        } else {
          debugPrint('❌ Widget not mounted when trying to upload');
        }
      } else {
        debugPrint('❌ No photo captured from camera');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่ได้ถ่ายรูปภาพ'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error in _pickImageFromCamera: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการถ่ายรูป: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Upload profile photo to Firebase Storage and update Firestore
  static Future<void> _uploadProfilePhoto(BuildContext context, File imageFile) async {
    try {
      debugPrint('🔧 Starting upload process...');
      debugPrint('📁 Image file path: ${imageFile.path}');
      
      // Check authentication first (before any async operations)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      debugPrint('👤 AuthProvider obtained');
      
      final user = authProvider.userModel;
      debugPrint('👤 User model: ${user?.email ?? "null"}');
      debugPrint('👤 User ID: ${user?.userId ?? "null"}');

      if (user?.userId == null) {
        debugPrint('❌ User ID is null - user not authenticated');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กรุณาล็อกอินก่อนอัปโหลดรูปภาพ'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Check if file exists
      if (!await imageFile.exists()) {
        debugPrint('❌ Image file does not exist');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่พบไฟล์รูปภาพ'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      debugPrint('📁 File exists: true');

      // Show loading dialog
      debugPrint('💬 Showing loading dialog...');
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('กำลังอัปโหลดรูปภาพ...'),
                ],
              ),
            );
          },
        );
        debugPrint('✅ Loading dialog shown');
      }

      // Validate file size (max 5MB) - With 10% resolution, expect much smaller files (~50-200KB)
      final fileSize = await imageFile.length();
      debugPrint('📏 File size: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB) - Compressed to 10% resolution');
      
      if (fileSize > 5 * 1024 * 1024) {
        debugPrint('❌ File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('รูปภาพมีขนาดเกิน 5 MB กรุณาเลือกรูปภาพใหม่'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Create storage reference
      debugPrint('🔥 Creating Firebase Storage reference...');
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child(user!.userId)
          .child('profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
      debugPrint('✅ Storage reference created: ${storageRef.fullPath}');

      // Upload file to Firebase Storage
      debugPrint('📤 Starting Firebase Storage upload...');
      String downloadUrl;
      try {
        final uploadTask = storageRef.putFile(
          imageFile,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'userId': user.userId,
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );

        debugPrint('⏳ Waiting for upload to complete...');
        final snapshot = await uploadTask;
        debugPrint('✅ Upload completed successfully');
        
        debugPrint('🔗 Getting download URL...');
        downloadUrl = await snapshot.ref.getDownloadURL();
        debugPrint('✅ Download URL obtained: $downloadUrl');
      } catch (storageError) {
        debugPrint('❌ Firebase Storage upload failed: $storageError');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          String errorMessage = 'เกิดข้อผิดพลาดในการอัปโหลด';
          if (storageError.toString().contains('network') || 
              storageError.toString().contains('Unable to resolve host')) {
            errorMessage = 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อ';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Update profilePhotoUrl in Firestore
      debugPrint('💾 Updating Firestore with new profile photo URL...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .update({
        'profilePhotoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Firestore updated successfully');

      // Refresh user data to update UI
      debugPrint('🔄 Refreshing user data...');
      await authProvider.refreshUserData();
      debugPrint('✅ User data refreshed');

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        debugPrint('🎉 Showing success message');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปโหลดรูปภาพโปรไฟล์สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error in _uploadProfilePhoto: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog if it's open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 