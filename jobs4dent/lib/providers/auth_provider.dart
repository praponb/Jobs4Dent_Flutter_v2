import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'auth/firebase_auth_service.dart';
import 'auth/google_sign_in_service.dart';
import 'auth/user_management_service.dart';
import 'auth/role_management_service.dart';
import 'auth/auth_error_handler.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _error;
  String? _successMessage;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  AuthProvider() {
    _init();
  }

  void _init() async {
    debugPrint('🚀 Initializing AuthProvider...');
    
    // Set a timeout to ensure loading doesn't stay true forever
    Timer(const Duration(seconds: 3), () {
      if (_isLoading) {
        debugPrint('⏰ Timeout reached - setting loading to false');
        _isLoading = false;
        notifyListeners();
      }
    });
    
    // Listen for auth state changes
    FirebaseAuthService.authStateChanges.listen((User? user) async {
      debugPrint('🔐 Auth state changed: ${user?.email ?? "No user"}');
      
      _user = user;
      if (user != null) {
        debugPrint('👤 User authenticated: ${user.email}');
        debugPrint('📧 Email verified: ${user.emailVerified}');
        
        await _loadUserModel();
        
        if (_userModel != null) {
          debugPrint('✅ User model loaded successfully');
          debugPrint('👤 User type: ${_userModel!.userType}');
          debugPrint('📝 Profile complete: ${_userModel!.isProfileComplete}');
          debugPrint('🎯 Needs profile setup: $needsProfileSetup');
          
          await UserManagementService.updateLastLogin(user.uid);
        } else {
          debugPrint('❌ Failed to load user model');
        }
      } else {
        debugPrint('❌ No authenticated user');
        _userModel = null;
      }
      
      // Set loading to false after processing auth state
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserModel() async {
    if (_user != null) {
      try {
        _userModel = await UserManagementService.loadUserModel(_user!.uid);
        
        if (_userModel != null) {
          // Update email verification status if it has changed
          if (_userModel!.isEmailVerified != _user!.emailVerified) {
            await UserManagementService.updateEmailVerificationStatus(
              _user!.uid, 
              _user!.emailVerified
            );
          }

          // Check and update profile completion status for existing users
          _userModel = await UserManagementService.checkAndUpdateProfileCompletion(_userModel!);
        } else {
          // User document doesn't exist in Firestore, create it
          await UserManagementService.createUserDocumentFromExistingAuth(_user!);
          _userModel = await UserManagementService.loadUserModel(_user!.uid);
        }
              } catch (e) {
          debugPrint('❌ Error loading user data: $e');
          _error = 'Error loading user data: $e';
          
          // If UserModel parsing fails, try to create a new document
          if (e.toString().contains('fromMap') || e.toString().contains('UserModel')) {
            debugPrint('🔧 UserModel parsing failed, creating new document...');
            try {
              await UserManagementService.createUserDocumentFromExistingAuth(_user!);
              _userModel = await UserManagementService.loadUserModel(_user!.uid);
            } catch (createError) {
              debugPrint('❌ Failed to create new document: $createError');
            }
          }
        }
    }
  }

  // Email/Password Registration
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String userName,
    required String userType,
  }) async {
    try {
      _error = null;
      _successMessage = null;
      _isLoading = true;
      notifyListeners();

      final authResult = await FirebaseAuthService.registerWithEmail(
        email: email,
        password: password,
        userName: userName,
      );

      if (authResult.success && authResult.user != null) {
        // Create user document
        await UserManagementService.createUserDocument(
          authResult.user!,
          authProvider: 'email',
          userType: userType,
          isEmailVerified: false,
        );

        _successMessage = authResult.message;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = authResult.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: ${AuthErrorHandler.getErrorMessage(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Email/Password Sign-in
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _error = null;
      _successMessage = null;
      _isLoading = true;
      notifyListeners();

      final authResult = await FirebaseAuthService.signInWithEmail(
        email: email,
        password: password,
      );

      if (authResult.success) {
        // Load user data from Firestore
        await _loadUserModel();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = authResult.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Sign-in failed: ${AuthErrorHandler.getErrorMessage(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Resend email verification
  Future<bool> resendEmailVerification() async {
    try {
      final authResult = await FirebaseAuthService.resendEmailVerification();
      
      if (authResult.success) {
        _successMessage = authResult.message;
        notifyListeners();
        return true;
      } else {
        _error = authResult.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'ไม่สามารถส่งอีเมลยืนยันได้: ${AuthErrorHandler.getErrorMessage(e)}';
      notifyListeners();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      _error = null;
      _successMessage = null;
      
      final authResult = await FirebaseAuthService.resetPassword(email: email);
      
      if (authResult.success) {
        _successMessage = authResult.message;
        notifyListeners();
        return true;
      } else {
        _error = authResult.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'ไม่สามารถส่งอีเมลรีเซ็ตได้: ${AuthErrorHandler.getErrorMessage(e)}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final googleResult = await GoogleSignInService.signInWithGoogle();
      
      if (googleResult.success && googleResult.user != null) {
        if (googleResult.isNewUser) {
          debugPrint('🔄 Creating new user document in Firestore...');
          
          await UserManagementService.createUserDocument(
            googleResult.user!,
            authProvider: 'google',
            userType: 'pending', // Set to pending so user goes through UserTypeSelectionScreen
            isEmailVerified: true,
            additionalData: {
              'signInMethod': 'google',
              'googleProfile': googleResult.googleProfile?.toMap(),
              'isProfileComplete': false, // New users need to complete profile setup
            },
          );
          debugPrint('✅ New Google user created in Firestore: ${googleResult.user!.email}');
        } else {
          debugPrint('🔄 Loading existing user data from Firestore...');
          // Load existing user data from Firestore
          await _loadUserModel();
          debugPrint('✅ Existing Google user loaded from Firestore: ${googleResult.user!.email}');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else if (googleResult.cancelled) {
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _error = googleResult.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      _error = 'Error signing in with Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Role switching functionality
  Future<bool> switchRole(String newRole) async {
    try {
      if (_userModel == null) return false;

      final roleResult = await RoleManagementService.switchRole(_userModel!, newRole);
      
      if (roleResult.success && roleResult.userModel != null) {
        _userModel = roleResult.userModel;
        notifyListeners();
        return true;
      } else {
        _error = roleResult.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error switching role: $e';
      notifyListeners();
      return false;
    }
  }

  // Add role to user
  Future<bool> addRole(String role) async {
    try {
      if (_userModel == null) return false;

      final roleResult = await RoleManagementService.addRole(_userModel!, role);
      
      if (roleResult.success && roleResult.userModel != null) {
        _userModel = roleResult.userModel;
        notifyListeners();
        return true;
      } else {
        _error = roleResult.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error adding role: $e';
      notifyListeners();
      return false;
    }
  }

  // Create sub-user (for clinic branches)
  Future<bool> createSubUser({
    required String email,
    required String password,
    required String userName,
    required String branchName,
    required String branchAddress,
    required List<String> permissions,
  }) async {
    try {
      if (_userModel == null) return false;

      _isLoading = true;
      notifyListeners();

      final subUserResult = await RoleManagementService.createSubUser(
        parentUser: _userModel!,
        email: email,
        password: password,
        userName: userName,
        branchName: branchName,
        branchAddress: branchAddress,
        permissions: permissions,
      );

      if (subUserResult.success && subUserResult.updatedParent != null) {
        _userModel = subUserResult.updatedParent;
        _successMessage = subUserResult.message;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = subUserResult.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error creating sub-user: ${AuthErrorHandler.getErrorMessage(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get sub-users for clinic
  Future<List<UserModel>> getSubUsers() async {
    if (_userModel == null) return [];
    return await RoleManagementService.getSubUsers(_userModel!);
  }

  Future<bool> updateUserProfile({
    required bool isDentist,
    required String userType,
    String? phoneNumber,
    String? address,
    List<String>? skills,
    List<String>? workLocationPreference,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? experience,
    String? clinicName,
    String? clinicAddress,
    List<String>? serviceTypes,
  }) async {
    try {
      if (_user == null || _userModel == null) return false;

      final updatedUser = _userModel!.copyWith(
        isDentist: isDentist,
        userType: userType,
        currentRole: userType,
        roles: [userType], // Initialize with single role
        phoneNumber: phoneNumber,
        address: address,
        skills: skills,
        workLocationPreference: workLocationPreference,
        education: education,
        experience: experience,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        serviceTypes: serviceTypes,
        isProfileComplete: true,
        updatedAt: DateTime.now(),
      );

      final success = await UserManagementService.updateUserProfile(_user!.uid, updatedUser);
      
      if (success) {
        _userModel = updatedUser;
        notifyListeners();
        return true;
      } else {
        _error = 'Error updating user profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating user profile: $e';
      debugPrint('❌ Failed to update user profile: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🚪 Starting sign out process...');
      
      // Clear loading state first
      _isLoading = true;
      notifyListeners();
      
      // Sign out from Google and Firebase
      await GoogleSignInService.signOut();
      await FirebaseAuthService.signOut();
      
      // Clear all user data
      _user = null;
      _userModel = null;
      _error = null;
      _successMessage = null;
      _isLoading = false;
      
      debugPrint('✅ Sign out completed successfully');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      _error = 'Error signing out: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  // Update user model locally
  void updateUser(UserModel updatedUser) {
    _userModel = updatedUser;
    notifyListeners();
  }

  // Check if user needs to complete profile setup
  bool get needsProfileSetup {
    debugPrint('🤔 Checking if profile setup is needed...');
    
    if (_userModel == null) {
      debugPrint('   UserModel is null - setup needed');
      return true;
    }
    
    debugPrint('   UserModel exists for: ${_userModel!.email}');
    debugPrint('   UserType: ${_userModel!.userType}');
    debugPrint('   isProfileComplete: ${_userModel!.isProfileComplete}');
    
    // If user type is 'pending', always need setup
    if (_userModel!.userType == 'pending') {
      debugPrint('   User type is pending - setup needed');
      return true;
    }
    
    // If explicitly marked as complete, no setup needed
    if (_userModel!.isProfileComplete) {
      debugPrint('   Profile marked as complete - no setup needed');
      return false;
    }
    
    // For existing users, check if they have essential data even if not marked complete
    bool hasEssentialData = UserManagementService.hasEssentialProfileData(_userModel!);
    bool needsSetup = !hasEssentialData;
    
    debugPrint('   Profile not marked complete, checking essential data...');
    debugPrint('   Has essential data: $hasEssentialData');
    debugPrint('   Needs setup: $needsSetup');
    
    return needsSetup;
  }

  // Force refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_user != null) {
      debugPrint('🔄 Refreshing user data from Firestore...');
      await _loadUserModel();
      notifyListeners();
    }
  }

  // Debug method to check current auth state
  void debugAuthState() {
    debugPrint('🐛 DEBUG AUTH STATE:');
    debugPrint('   Firebase User: ${_user?.email ?? "null"}');
    debugPrint('   Firebase User UID: ${_user?.uid ?? "null"}');
    debugPrint('   UserModel: ${_userModel?.email ?? "null"}');
    debugPrint('   UserModel UserType: ${_userModel?.userType ?? "null"}');
    debugPrint('   IsProfileComplete: ${_userModel?.isProfileComplete ?? "null"}');
    debugPrint('   NeedsProfileSetup: $needsProfileSetup');
    debugPrint('   IsLoading: $_isLoading');
  }

  // Sync user data between Firebase Auth and Firestore
  Future<bool> syncUserData() async {
    if (_user == null || _userModel == null) return false;
    
    try {
      final success = await UserManagementService.syncUserData(_user!, _userModel!);
      
      if (success) {
        await _loadUserModel(); // Reload updated data
      }
      
      return success;
    } catch (e) {
      _error = 'Error syncing user data: $e';
      debugPrint('❌ Failed to sync user data: $e');
      return false;
    }
  }
} 