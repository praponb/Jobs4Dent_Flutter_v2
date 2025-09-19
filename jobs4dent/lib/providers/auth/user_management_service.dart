import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

/// Service class for user document management in Firestore
class UserManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load user model from Firestore
  static Future<UserModel?> loadUserModel(String uid) async {
    try {
      debugPrint('📄 Loading user document from Firestore for UID: $uid');

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        debugPrint('📋 Document exists, parsing UserModel...');
        final data = doc.data() as Map<String, dynamic>;

        // Add missing required fields with defaults if they don't exist
        final processedData = _processUserData(data, uid);

        debugPrint(
          '📊 Attempting to create UserModel with data: ${processedData.keys}',
        );

        final userModel = UserModel.fromMap(processedData);

        debugPrint('✅ UserModel created successfully');
        debugPrint('   Email: ${userModel.email}');
        debugPrint('   UserType: ${userModel.userType}');
        debugPrint('   IsProfileComplete: ${userModel.isProfileComplete}');

        return userModel;
      } else {
        debugPrint('❌ User document doesn\'t exist in Firestore');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      return null;
    }
  }

  /// Process user data to ensure all required fields exist
  static Map<String, dynamic> _processUserData(
    Map<String, dynamic> data,
    String uid,
  ) {
    // Add missing required fields with defaults if they don't exist
    data['userId'] = data['userId'] ?? uid;
    data['email'] = data['email'] ?? '';
    data['userName'] = data['userName'] ?? 'User';
    data['isDentist'] =
        data['isDentist'] ??
        (data['userType'] == 'dentist' || data['userType'] == 'assistant');
    data['userType'] = data['userType'] ?? 'pending';
    data['isMainAccount'] = data['isMainAccount'] ?? true;
    data['isActive'] = data['isActive'] ?? true;
    data['isProfileComplete'] = data['isProfileComplete'] ?? false;
    data['authProvider'] = data['authProvider'] ?? 'email';
    data['isEmailVerified'] = data['isEmailVerified'] ?? false;
    data['verificationStatus'] = data['verificationStatus'] ?? 'unverified';

    // Handle timestamps - convert Firestore Timestamp to int milliseconds
    data = _processTimestamps(data);

    return data;
  }

  /// Process timestamp fields
  static Map<String, dynamic> _processTimestamps(Map<String, dynamic> data) {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Handle createdAt
    if (data['createdAt'] == null) {
      data['createdAt'] = now;
    } else if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
    }

    // Handle updatedAt
    if (data['updatedAt'] == null) {
      data['updatedAt'] = now;
    } else if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] =
          (data['updatedAt'] as Timestamp).millisecondsSinceEpoch;
    }

    // Handle other potential timestamp fields
    if (data['lastLoginAt'] != null && data['lastLoginAt'] is Timestamp) {
      data['lastLoginAt'] =
          (data['lastLoginAt'] as Timestamp).millisecondsSinceEpoch;
    }

    if (data['verificationSubmittedAt'] != null &&
        data['verificationSubmittedAt'] is Timestamp) {
      data['verificationSubmittedAt'] =
          (data['verificationSubmittedAt'] as Timestamp).millisecondsSinceEpoch;
    }

    if (data['verificationReviewedAt'] != null &&
        data['verificationReviewedAt'] is Timestamp) {
      data['verificationReviewedAt'] =
          (data['verificationReviewedAt'] as Timestamp).millisecondsSinceEpoch;
    }

    return data;
  }

  /// Create user document in Firestore
  static Future<bool> createUserDocument(
    User user, {
    required String authProvider,
    required String userType,
    required bool isEmailVerified,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final now = DateTime.now();

      final userModel = UserModel(
        userId: user.uid,
        email: user.email ?? '',
        userName: user.displayName ?? 'User',
        profilePhotoUrl: user.photoURL,
        isDentist: userType == 'dentist' || userType == 'assistant',
        userType: userType,
        createdAt: now,
        updatedAt: now,
        authProvider: authProvider,
        isEmailVerified: isEmailVerified,
        isMainAccount: true,
        isActive: true,
        isProfileComplete: false,
        lastLoginAt: now,
      );

      // Merge additional data if provided
      Map<String, dynamic> userData = userModel.toMap();
      if (additionalData != null) {
        userData.addAll(additionalData);
      }

      // Explicitly remove the 'roles' field to ensure it's not preserved from old documents
      userData.remove('roles');

      // Store user data in Firestore 'users' collection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      // Log successful user creation
      debugPrint('✅ User document created in Firestore: ${user.email}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to create user document: $e');
      return false;
    }
  }

  /// Update user profile
  static Future<bool> updateUserProfile(
    String uid,
    UserModel updatedUser,
  ) async {
    try {
      Map<String, dynamic> userData = updatedUser.toMap();
      // Explicitly remove the 'roles' field to ensure it's not preserved from old documents
      userData.remove('roles');

      await _firestore
          .collection('users')
          .doc(uid)
          .set(userData, SetOptions(merge: true));

      debugPrint('✅ User profile updated in Firestore');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update user profile: $e');
      return false;
    }
  }

  /// Update last login time
  static Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Silent fail for last login update
      debugPrint('Failed to update last login: $e');
    }
  }

  /// Update email verification status
  static Future<void> updateEmailVerificationStatus(
    String uid,
    bool isVerified,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isEmailVerified': isVerified,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Silent fail for email verification update
      debugPrint('Failed to update email verification status: $e');
    }
  }

  /// Check and update profile completion status
  static Future<UserModel?> checkAndUpdateProfileCompletion(
    UserModel userModel,
  ) async {
    try {
      debugPrint('🔄 Checking profile completion for: ${userModel.email}');
      debugPrint(
        '   Current isProfileComplete: ${userModel.isProfileComplete}',
      );

      // Check if user has essential profile data to be considered complete
      bool shouldBeComplete = hasEssentialProfileData(userModel);

      // If the user should be complete but isn't marked as such, update it
      if (shouldBeComplete && !userModel.isProfileComplete) {
        debugPrint(
          '✏️ Updating profile completion status for existing user: ${userModel.userId}',
        );

        await _firestore.collection('users').doc(userModel.userId).update({
          'isProfileComplete': true,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });

        // Return updated model
        final updatedUser = userModel.copyWith(
          isProfileComplete: true,
          updatedAt: DateTime.now(),
        );

        debugPrint('✅ Successfully updated profile completion status to true');
        return updatedUser;
      } else if (shouldBeComplete) {
        debugPrint('✅ Profile is already marked as complete');
      } else {
        debugPrint(
          '❌ Profile does not have essential data - keeping incomplete',
        );
      }

      return userModel;
    } catch (e) {
      debugPrint('❌ Error checking profile completion: $e');
      return userModel;
    }
  }

  /// Check if user has essential profile data
  static bool hasEssentialProfileData(UserModel userModel) {
    debugPrint('🔍 Checking essential profile data for: ${userModel.email}');

    // Check if user has the essential data that indicates a complete profile
    bool hasBasicInfo =
        userModel.userName.isNotEmpty && userModel.email.isNotEmpty;

    bool hasUserType =
        userModel.userType.isNotEmpty &&
        userModel.userType != 'unknown' &&
        userModel.userType != '' &&
        userModel.userType != 'pending';

    bool hasRole = userModel.userType.isNotEmpty;

    debugPrint(
      '   Basic info: $hasBasicInfo (name: "${userModel.userName}", email: "${userModel.email}")',
    );
    debugPrint('   User type: $hasUserType ("${userModel.userType}")');
    debugPrint('   Role: $hasRole ("${userModel.userType}")');

    // For any user type, if they have basic info + user type + role, consider it complete
    bool isComplete = hasBasicInfo && hasUserType && hasRole;

    debugPrint('   Essential data complete: $isComplete');
    return isComplete;
  }

  /// Sync user data between Firebase Auth and Firestore
  static Future<bool> syncUserData(User user, UserModel userModel) async {
    try {
      Map<String, dynamic> updates = {};

      if (userModel.email != user.email) {
        updates['email'] = user.email;
      }

      if (userModel.isEmailVerified != user.emailVerified) {
        updates['isEmailVerified'] = user.emailVerified;
      }

      if (userModel.userName != user.displayName && user.displayName != null) {
        updates['userName'] = user.displayName;
      }

      if (userModel.profilePhotoUrl != user.photoURL) {
        updates['profilePhotoUrl'] = user.photoURL;
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

        await _firestore.collection('users').doc(user.uid).update(updates);

        debugPrint('✅ User data synchronized between Auth and Firestore');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Failed to sync user data: $e');
      return false;
    }
  }

  /// Create user document from existing auth user
  static Future<bool> createUserDocumentFromExistingAuth(User user) async {
    try {
      debugPrint(
        '🏗️ Creating user document for existing auth user: ${user.email}',
      );

      // Determine auth provider based on providerData
      String authProvider = 'email';
      if (user.providerData.any((info) => info.providerId == 'google.com')) {
        authProvider = 'google';
      }

      // For new users, set userType to 'pending' so they go through user type selection
      return await createUserDocument(
        user,
        authProvider: authProvider,
        userType: 'pending',
        isEmailVerified: user.emailVerified,
        additionalData: {'isProfileComplete': false},
      );
    } catch (e) {
      debugPrint('❌ Error creating user document: $e');
      return false;
    }
  }

  /// Remove 'roles' field from user document (migration helper)
  static Future<bool> removeRolesField(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'roles': FieldValue.delete(),
      });
      debugPrint('✅ Removed roles field from user: $uid');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to remove roles field: $e');
      return false;
    }
  }

  /// Remove 'roles' field from all user documents (batch migration)
  static Future<void> migrateAllUsersRemoveRoles() async {
    try {
      debugPrint(
        '🔄 Starting migration to remove roles field from all users...',
      );

      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .get();

      WriteBatch batch = _firestore.batch();
      int batchCount = 0;

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Only update if the document has a 'roles' field
        if (data.containsKey('roles')) {
          batch.update(doc.reference, {'roles': FieldValue.delete()});
          batchCount++;

          // Firestore batch limit is 500 operations
          if (batchCount >= 500) {
            await batch.commit();
            batch = _firestore.batch();
            batchCount = 0;
            debugPrint('📦 Committed batch of 500 operations...');
          }
        }
      }

      // Commit remaining operations
      if (batchCount > 0) {
        await batch.commit();
      }

      debugPrint(
        '✅ Migration completed. Removed roles field from $batchCount users.',
      );
    } catch (e) {
      debugPrint('❌ Migration failed: $e');
    }
  }
}
