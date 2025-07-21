import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import 'firebase_auth_service.dart';
// import 'user_management_service.dart';
import 'auth_error_handler.dart';

/// Service class for role management and sub-user operations
class RoleManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Switch user role
  static Future<RoleResult> switchRole(
    UserModel userModel,
    String newRole,
  ) async {
    try {
      if (!userModel.roles.contains(newRole)) {
        return RoleResult.error(AuthErrorHandler.invalidRoleOrAccess);
      }

      final updatedUser = userModel.copyWith(
        currentRole: newRole,
        isDentist: newRole == 'dentist' || newRole == 'assistant',
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userModel.userId)
          .update({
        'currentRole': newRole,
        'isDentist': updatedUser.isDentist,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return RoleResult.success(updatedUser);
    } catch (e) {
      debugPrint('❌ Error switching role: $e');
      return RoleResult.error('Error switching role: $e');
    }
  }

  /// Add role to user
  static Future<RoleResult> addRole(
    UserModel userModel,
    String role,
  ) async {
    try {
      if (userModel.roles.contains(role)) {
        return RoleResult.error('Role already exists');
      }

      List<String> newRoles = List.from(userModel.roles)..add(role);
      
      final updatedUser = userModel.copyWith(
        roles: newRoles,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userModel.userId)
          .update({
        'roles': newRoles,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return RoleResult.success(updatedUser);
    } catch (e) {
      debugPrint('❌ Error adding role: $e');
      return RoleResult.error('Error adding role: $e');
    }
  }

  /// Create sub-user (for clinic branches)
  static Future<SubUserResult> createSubUser({
    required UserModel parentUser,
    required String email,
    required String password,
    required String userName,
    required String branchName,
    required String branchAddress,
    required List<String> permissions,
  }) async {
    try {
      if (!parentUser.isMainAccount || parentUser.userType != 'clinic') {
        return SubUserResult.error(AuthErrorHandler.clinicOwnerOnly);
      }

      // Create Firebase Auth user
      final authResult = await FirebaseAuthService.createSubUserAccount(
        email: email,
        password: password,
        userName: userName,
      );

      if (!authResult.success || authResult.user == null) {
        return SubUserResult.error(authResult.error ?? 'Failed to create sub-user account');
      }

      // Create sub-user document
      final subUserModel = UserModel(
        userId: authResult.user!.uid,
        email: email,
        userName: userName,
        isDentist: false,
        userType: 'clinic',
        currentRole: 'clinic',
        roles: ['clinic'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        authProvider: 'email',
        isEmailVerified: false,
        parentUserId: parentUser.userId,
        isMainAccount: false,
        branchName: branchName,
        branchAddress: branchAddress,
        permissions: {'permissions': permissions},
        isActive: true,
        isProfileComplete: true,
      );

      await _firestore
          .collection('users')
          .doc(authResult.user!.uid)
          .set(subUserModel.toMap());

      // Update main account with sub-user ID
      List<String> currentSubUsers = List.from(parentUser.subUserIds ?? []);
      currentSubUsers.add(authResult.user!.uid);

      await _firestore
          .collection('users')
          .doc(parentUser.userId)
          .update({'subUserIds': currentSubUsers});

      // Update parent user model
      final updatedParent = parentUser.copyWith(subUserIds: currentSubUsers);

      return SubUserResult.success(
        subUser: subUserModel,
        updatedParent: updatedParent,
        message: AuthErrorHandler.subUserCreated,
      );
    } catch (e) {
      debugPrint('❌ Error creating sub-user: $e');
      return SubUserResult.error(AuthErrorHandler.getErrorMessage(e));
    }
  }

  /// Get sub-users for clinic
  static Future<List<UserModel>> getSubUsers(UserModel userModel) async {
    if (userModel.subUserIds == null) {
      return [];
    }

    try {
      List<UserModel> subUsers = [];
      for (String subUserId in userModel.subUserIds!) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(subUserId)
            .get();
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          subUsers.add(UserModel.fromMap(data));
        }
      }
      return subUsers;
    } catch (e) {
      debugPrint('❌ Error loading sub-users: $e');
      return [];
    }
  }

  /// Update sub-user permissions
  static Future<bool> updateSubUserPermissions(
    String subUserId,
    List<String> permissions,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(subUserId)
          .update({
        'permissions': {'permissions': permissions},
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return true;
    } catch (e) {
      debugPrint('❌ Error updating sub-user permissions: $e');
      return false;
    }
  }

  /// Activate/deactivate sub-user
  static Future<bool> toggleSubUserStatus(
    String subUserId,
    bool isActive,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(subUserId)
          .update({
        'isActive': isActive,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return true;
    } catch (e) {
      debugPrint('❌ Error toggling sub-user status: $e');
      return false;
    }
  }
}

/// Result class for role operations
class RoleResult {
  final bool success;
  final UserModel? userModel;
  final String? error;

  RoleResult._({
    required this.success,
    this.userModel,
    this.error,
  });

  factory RoleResult.success(UserModel userModel) {
    return RoleResult._(
      success: true,
      userModel: userModel,
    );
  }

  factory RoleResult.error(String error) {
    return RoleResult._(
      success: false,
      error: error,
    );
  }
}

/// Result class for sub-user operations
class SubUserResult {
  final bool success;
  final UserModel? subUser;
  final UserModel? updatedParent;
  final String? message;
  final String? error;

  SubUserResult._({
    required this.success,
    this.subUser,
    this.updatedParent,
    this.message,
    this.error,
  });

  factory SubUserResult.success({
    required UserModel subUser,
    required UserModel updatedParent,
    String? message,
  }) {
    return SubUserResult._(
      success: true,
      subUser: subUser,
      updatedParent: updatedParent,
      message: message,
    );
  }

  factory SubUserResult.error(String error) {
    return SubUserResult._(
      success: false,
      error: error,
    );
  }
} 