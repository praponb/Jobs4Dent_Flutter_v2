import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Service for sending push notifications via Firebase Cloud Messaging
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase Functions with asia-southeast1 region to match Firestore
  FirebaseFunctions get _functions {
    return FirebaseFunctions.instanceFor(region: 'asia-southeast1');
  }

  /// Send notification to clinic when a dentist applies for a job
  /// This method should be called after a job application is successfully created
  Future<void> sendJobApplicationNotification({
    required String clinicId,
    required String applicantName,
    required String jobTitle,
    required String applicationId,
  }) async {
    try {
      debugPrint(
        '📤 Sending job application notification to clinic: $clinicId',
      );

      // Get clinic's device tokens from Firestore
      final clinicDoc = await _firestore
          .collection('users')
          .doc(clinicId)
          .get();

      if (!clinicDoc.exists) {
        debugPrint('⚠️ Clinic document not found: $clinicId');
        return;
      }

      final clinicData = clinicDoc.data() as Map<String, dynamic>;
      final deviceTokens = clinicData['deviceTokens'] as List<dynamic>? ?? [];

      if (deviceTokens.isEmpty) {
        debugPrint('⚠️ No device tokens found for clinic: $clinicId');
        return;
      }

      debugPrint(
        '🔍 Found ${deviceTokens.length} device tokens for clinic: $clinicId',
      );

      // Call Cloud Function to send notification
      try {
        final callable = _functions.httpsCallable(
          'sendJobApplicationNotification',
        );

        final result = await callable.call({
          'clinicId': clinicId,
          'deviceTokens': deviceTokens,
          'title': 'มีผู้สมัครงานใหม่',
          'body': '$applicantName สมัครงานตำแหน่ง $jobTitle',
          'data': {
            'type': 'job_application',
            'applicationId': applicationId,
            'jobTitle': jobTitle,
            'applicantName': applicantName,
            'clinicId': clinicId,
          },
        });

        debugPrint('✅ Notification sent successfully: ${result.data}');

        // Attempt to clean up invalid tokens
        await _cleanupInvalidTokens(
          userId: clinicId,
          tokens: deviceTokens,
          result: Map<String, dynamic>.from(result.data as Map),
        );
      } catch (e) {
        debugPrint('❌ Error calling Cloud Function: $e');

        // Fallback: Store notification in Firestore for the clinic to retrieve
        await _storeNotificationInFirestore(
          clinicId: clinicId,
          applicantName: applicantName,
          jobTitle: jobTitle,
          applicationId: applicationId,
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      // Don't throw - notifications are not critical for the application process
    }
  }

  /// Store notification in Firestore as fallback
  /// Clinics can retrieve these notifications even if push notifications fail
  Future<void> _storeNotificationInFirestore({
    required String clinicId,
    required String applicantName,
    required String jobTitle,
    required String applicationId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'clinicId': clinicId,
        'type': 'job_application',
        'title': 'มีผู้สมัครงานใหม่',
        'body': '$applicantName สมัครงานตำแหน่ง $jobTitle',
        'applicationId': applicationId,
        'jobTitle': jobTitle,
        'applicantName': applicantName,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Notification stored in Firestore as fallback');
    } catch (e) {
      debugPrint('❌ Error storing notification in Firestore: $e');
    }
  }

  /// Save device token for a user
  /// Should be called when user logs in or app starts
  Future<void> saveDeviceToken({
    required String userId,
    required String deviceToken,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'deviceTokens': FieldValue.arrayUnion([deviceToken]),
        'lastDeviceTokenUpdate': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Device token saved for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving device token: $e');

      // If update fails, try set with merge
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          final existingTokens = data['deviceTokens'] as List<dynamic>? ?? [];
          if (!existingTokens.contains(deviceToken)) {
            existingTokens.add(deviceToken);
          }

          await _firestore.collection('users').doc(userId).set({
            ...data,
            'deviceTokens': existingTokens,
            'lastDeviceTokenUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          debugPrint('✅ Device token saved using set with merge');
        }
      } catch (e2) {
        debugPrint('❌ Error saving device token with set: $e2');
      }
    }
  }

  /// Remove device token when user logs out
  Future<void> removeDeviceToken({
    required String userId,
    required String deviceToken,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'deviceTokens': FieldValue.arrayRemove([deviceToken]),
      });

      debugPrint('✅ Device token removed for user: $userId');
    } catch (e) {
      debugPrint('❌ Error removing device token: $e');
    }
  }

  /// Send notification to applicant when clinic updates application status
  /// This method should be called after application status is successfully updated
  Future<void> sendApplicationStatusUpdateNotification({
    required String applicantId,
    required String clinicName,
    required String jobTitle,
    required String status,
    required String applicationId,
  }) async {
    try {
      debugPrint(
        '📤 Sending status update notification to applicant: $applicantId',
      );

      // Get applicant's device tokens from Firestore
      final applicantDoc = await _firestore
          .collection('users')
          .doc(applicantId)
          .get();

      if (!applicantDoc.exists) {
        debugPrint('⚠️ Applicant document not found: $applicantId');
        return;
      }

      final applicantData = applicantDoc.data() as Map<String, dynamic>;
      final deviceTokens =
          applicantData['deviceTokens'] as List<dynamic>? ?? [];

      if (deviceTokens.isEmpty) {
        debugPrint('⚠️ No device tokens found for applicant: $applicantId');
        return;
      }

      // Get Thai status display name
      String statusDisplayName;
      switch (status) {
        case 'submitted':
          statusDisplayName = 'ส่งใบสมัครแล้ว';
          break;
        case 'interview_scheduled':
          statusDisplayName = 'นัดสัมภาษณ์แล้ว';
          break;
        case 'hired':
          statusDisplayName = 'ได้งานแล้ว';
          break;
        case 'rejected':
          statusDisplayName = 'ไม่ได้รับคัดเลือก';
          break;
        default:
          statusDisplayName = 'อัปเดตสถานะ';
      }

      // Call Cloud Function to send notification
      try {
        final callable = _functions.httpsCallable(
          'sendJobApplicationNotification',
        );

        final result = await callable.call({
          'clinicId':
              applicantId, // Note: using applicantId as userId for the function
          'deviceTokens': deviceTokens,
          'title': 'อัปเดตสถานะใบสมัครงาน',
          'body':
              'สถานะใบสมัครของคุณที่ $clinicName ตำแหน่ง $jobTitle ถูกเปลี่ยนเป็น: $statusDisplayName',
          'data': {
            'type': 'application_status_update',
            'applicationId': applicationId,
            'jobTitle': jobTitle,
            'clinicName': clinicName,
            'status': status,
            'applicantId': applicantId,
          },
        });

        debugPrint(
          '✅ Status update notification sent successfully: ${result.data}',
        );

        // Attempt to clean up invalid tokens
        await _cleanupInvalidTokens(
          userId: applicantId,
          tokens: deviceTokens,
          result: Map<String, dynamic>.from(result.data as Map),
        );
      } catch (e) {
        debugPrint('❌ Error calling Cloud Function: $e');

        // Fallback: Store notification in Firestore for the applicant to retrieve
        await _storeStatusUpdateNotificationInFirestore(
          applicantId: applicantId,
          clinicName: clinicName,
          jobTitle: jobTitle,
          status: status,
          statusDisplayName: statusDisplayName,
          applicationId: applicationId,
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending status update notification: $e');
      // Don't throw - notifications are not critical for the status update process
    }
  }

  /// Store status update notification in Firestore as fallback
  Future<void> _storeStatusUpdateNotificationInFirestore({
    required String applicantId,
    required String clinicName,
    required String jobTitle,
    required String status,
    required String statusDisplayName,
    required String applicationId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'applicantId': applicantId,
        'type': 'application_status_update',
        'title': 'อัปเดตสถานะใบสมัครงาน',
        'body':
            'สถานะใบสมัครของคุณที่ $clinicName ตำแหน่ง $jobTitle ถูกเปลี่ยนเป็น: $statusDisplayName',
        'applicationId': applicationId,
        'jobTitle': jobTitle,
        'clinicName': clinicName,
        'status': status,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint(
        '✅ Status update notification stored in Firestore as fallback',
      );
    } catch (e) {
      debugPrint('❌ Error storing status update notification in Firestore: $e');
    }
  }

  /// Helper to clean up invalid tokens from the result of a multicast send
  Future<void> _cleanupInvalidTokens({
    required String userId,
    required List<dynamic> tokens,
    required Map<String, dynamic> result,
  }) async {
    try {
      if (result['failureCount'] != null &&
          (result['failureCount'] as int) > 0) {
        final results = result['results'] as List<dynamic>?;
        if (results != null && results.length == tokens.length) {
          final List<String> tokensToRemove = [];

          for (int i = 0; i < results.length; i++) {
            final res = Map<String, dynamic>.from(results[i] as Map);
            final error = res['error'];
            if (error != null) {
              final errorCode = error['code'] as String?;
              // Check for common validity errors
              if (errorCode == 'messaging/invalid-registration-token' ||
                  errorCode == 'messaging/registration-token-not-registered') {
                tokensToRemove.add(tokens[i] as String);
              }
            }
          }

          if (tokensToRemove.isNotEmpty) {
            debugPrint(
              '🧹 Cleaning up ${tokensToRemove.length} stale tokens for user $userId',
            );
            await _firestore.collection('users').doc(userId).update({
              'deviceTokens': FieldValue.arrayRemove(tokensToRemove),
            });
            debugPrint('✅ Stale tokens removed');
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error cleaning up tokens: $e');
    }
  }
}
