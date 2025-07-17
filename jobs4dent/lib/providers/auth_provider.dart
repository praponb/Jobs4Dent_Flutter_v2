import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    print('🚀 Initializing AuthProvider...');
    
    // Set a timeout to ensure loading doesn't stay true forever
    Timer(const Duration(seconds: 3), () {
      if (_isLoading) {
        print('⏰ Timeout reached - setting loading to false');
        _isLoading = false;
        notifyListeners();
      }
    });
    
    // Optional: Run diagnosis for debugging (can be removed in production)
    // await Future.delayed(const Duration(milliseconds: 500));
    // await diagnoseFirebaseState();
    
    // Listen for auth state changes - this is the primary way to handle auth state
    _auth.authStateChanges().listen((User? user) async {
      print('🔐 Auth state changed: ${user?.email ?? "No user"}');
      
      _user = user;
      if (user != null) {
        print('👤 User authenticated: ${user.email}');
        print('📧 Email verified: ${user.emailVerified}');
        
        await _loadUserModel();
        
        if (_userModel != null) {
          print('✅ User model loaded successfully');
          print('👤 User type: ${_userModel!.userType}');
          print('📝 Profile complete: ${_userModel!.isProfileComplete}');
          print('🎯 Needs profile setup: $needsProfileSetup');
          
          await _updateLastLogin();
        } else {
          print('❌ Failed to load user model');
        }
      } else {
        print('❌ No authenticated user');
        _userModel = null;
      }
      
      // Set loading to false after processing auth state
      _isLoading = false;
      notifyListeners();
      
      // Debug final state (can be removed in production)
      // debugAuthState();
    });
  }

  Future<void> _loadUserModel() async {
    if (_user != null) {
      try {
        print('📄 Loading user document from Firestore for UID: ${_user!.uid}');
        
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(_user!.uid)
            .get();
        
        if (doc.exists) {
          print('📋 Document exists, parsing UserModel...');
          final data = doc.data() as Map<String, dynamic>;
          
          // Add missing required fields with defaults if they don't exist
          data['userId'] = data['userId'] ?? _user!.uid;
          data['email'] = data['email'] ?? _user!.email ?? '';
          data['userName'] = data['userName'] ?? _user!.displayName ?? 'User';
          data['isDentist'] = data['isDentist'] ?? (data['userType'] == 'dentist' || data['userType'] == 'assistant');
          data['userType'] = data['userType'] ?? 'dentist';
          data['currentRole'] = data['currentRole'] ?? data['userType'] ?? 'dentist';
          data['roles'] = data['roles'] ?? [data['userType'] ?? 'dentist'];
          data['isMainAccount'] = data['isMainAccount'] ?? true;
          data['isActive'] = data['isActive'] ?? true;
          data['isProfileComplete'] = data['isProfileComplete'] ?? false;
          data['authProvider'] = data['authProvider'] ?? 'email';
          data['isEmailVerified'] = data['isEmailVerified'] ?? (_user!.emailVerified);
          data['verificationStatus'] = data['verificationStatus'] ?? 'unverified';
          
          // Handle timestamps - convert Firestore Timestamp to int milliseconds
          if (data['createdAt'] == null) {
            data['createdAt'] = DateTime.now().millisecondsSinceEpoch;
          } else if (data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
          }
          
          if (data['updatedAt'] == null) {
            data['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
          } else if (data['updatedAt'] is Timestamp) {
            data['updatedAt'] = (data['updatedAt'] as Timestamp).millisecondsSinceEpoch;
          }
          
          // Handle other potential timestamp fields
          if (data['lastLoginAt'] != null && data['lastLoginAt'] is Timestamp) {
            data['lastLoginAt'] = (data['lastLoginAt'] as Timestamp).millisecondsSinceEpoch;
          }
          
          if (data['verificationSubmittedAt'] != null && data['verificationSubmittedAt'] is Timestamp) {
            data['verificationSubmittedAt'] = (data['verificationSubmittedAt'] as Timestamp).millisecondsSinceEpoch;
          }
          
          if (data['verificationReviewedAt'] != null && data['verificationReviewedAt'] is Timestamp) {
            data['verificationReviewedAt'] = (data['verificationReviewedAt'] as Timestamp).millisecondsSinceEpoch;
          }
          
          print('📊 Attempting to create UserModel with data: ${data.keys}');
          
          _userModel = UserModel.fromMap(data);
          
          print('✅ UserModel created successfully');
          print('   Email: ${_userModel!.email}');
          print('   UserType: ${_userModel!.userType}');
          print('   IsProfileComplete: ${_userModel!.isProfileComplete}');
          
          // Update email verification status if it has changed
          if (_userModel!.isEmailVerified != _user!.emailVerified) {
            await _updateEmailVerificationStatus(_user!.emailVerified);
          }

          // Check and update profile completion status for existing users
          await _checkAndUpdateProfileCompletion();
        } else {
          print('❌ User document doesn\'t exist in Firestore, creating new one...');
          // User document doesn't exist in Firestore, create it
          await _createUserDocumentFromExistingAuth();
        }
      } catch (e) {
        print('❌ Error loading user data: $e');
        print('   Stack trace: ${e.toString()}');
        _error = 'Error loading user data: $e';
        
        // If UserModel parsing fails, try to create a new document
        if (e.toString().contains('fromMap') || e.toString().contains('UserModel')) {
          print('🔧 UserModel parsing failed, creating new document...');
          try {
            await _createUserDocumentFromExistingAuth();
          } catch (createError) {
            print('❌ Failed to create new document: $createError');
          }
        }
      }
    }
  }

  Future<void> _updateLastLogin() async {
    if (_user != null && _userModel != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_user!.uid)
            .update({
          'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (e) {
        // Silent fail for last login update
      }
    }
  }

  Future<void> _checkAndUpdateProfileCompletion() async {
    if (_user != null && _userModel != null) {
      try {
        print('🔄 Checking profile completion for: ${_userModel!.email}');
        print('   Current isProfileComplete: ${_userModel!.isProfileComplete}');
        
        // Check if user has essential profile data to be considered complete
        bool shouldBeComplete = _hasEssentialProfileData();
        
        // If the user should be complete but isn't marked as such, update it
        if (shouldBeComplete && !_userModel!.isProfileComplete) {
          print('✏️ Updating profile completion status for existing user: ${_user!.uid}');
          
          await _firestore
              .collection('users')
              .doc(_user!.uid)
              .update({
            'isProfileComplete': true,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
          
          // Update local model
          _userModel = _userModel!.copyWith(
            isProfileComplete: true,
            updatedAt: DateTime.now(),
          );
          
          print('✅ Successfully updated profile completion status to true');
        } else if (shouldBeComplete) {
          print('✅ Profile is already marked as complete');
        } else {
          print('❌ Profile does not have essential data - keeping incomplete');
        }
      } catch (e) {
        print('❌ Error checking profile completion: $e');
      }
    }
  }

  bool _hasEssentialProfileData() {
    if (_userModel == null) return false;
    
    print('🔍 Checking essential profile data for: ${_userModel!.email}');
    
    // Check if user has the essential data that indicates a complete profile
    bool hasBasicInfo = _userModel!.userName.isNotEmpty && 
                       _userModel!.email.isNotEmpty;
    
    bool hasUserType = _userModel!.userType.isNotEmpty && 
                      _userModel!.userType != 'unknown' &&
                      _userModel!.userType != '';
    
    bool hasRole = _userModel!.currentRole.isNotEmpty;
    
    print('   Basic info: $hasBasicInfo (name: "${_userModel!.userName}", email: "${_userModel!.email}")');
    print('   User type: $hasUserType ("${_userModel!.userType}")');
    print('   Role: $hasRole ("${_userModel!.currentRole}")');
    
    // For any user type, if they have basic info + user type + role, consider it complete
    // This is more lenient than the previous version
    bool isComplete = hasBasicInfo && hasUserType && hasRole;
    
    print('   Essential data complete: $isComplete');
    return isComplete;
  }

  Future<void> _updateEmailVerificationStatus(bool isVerified) async {
    if (_user != null && _userModel != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_user!.uid)
            .update({
          'isEmailVerified': isVerified,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
        
        // Update local model
        _userModel = _userModel!.copyWith(
          isEmailVerified: isVerified,
          updatedAt: DateTime.now(),
        );
      } catch (e) {
        // Silent fail for email verification update
      }
    }
  }

  Future<void> _createUserDocumentFromExistingAuth() async {
    if (_user != null) {
      try {
        print('🏗️ Creating user document for existing auth user: ${_user!.email}');
        
        // Determine auth provider based on providerData
        String authProvider = 'email';
        if (_user!.providerData.any((info) => info.providerId == 'google.com')) {
          authProvider = 'google';
        }

        await _createUserDocument(
          _user!,
          authProvider: authProvider,
          userType: 'dentist', // Default type
          isEmailVerified: _user!.emailVerified,
          additionalData: {
            'isProfileComplete': true, // Mark existing users as complete
          },
        );
        
        print('✅ User document created for existing auth user');
      } catch (e) {
        print('❌ Error creating user document: $e');
        _error = 'Error creating user document: $e';
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

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Update display name
      await userCredential.user!.updateDisplayName(userName);

      // Create user document
      await _createUserDocument(
        userCredential.user!,
        authProvider: 'email',
        userType: userType,
        isEmailVerified: false,
      );

      _successMessage = 'ลงทะเบียนสำเร็จแล้ว! กรุณาตรวจสอบอีเมลเพื่อยืนยันบัญชีของคุณ';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: ${_getErrorMessage(e)}';
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

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        _error = 'กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ';
        await _auth.signOut();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Load user data from Firestore
      await _loadUserModel();
      
      // Update last login time
      await _updateLastLogin();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign-in failed: ${_getErrorMessage(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Resend email verification
  Future<bool> resendEmailVerification() async {
    try {
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();
        _successMessage = 'ส่งอีเมลยืนยันแล้ว! กรุณาตรวจสอบกล่องจดหมายของคุณ';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
              _error = 'ไม่สามารถส่งอีเมลยืนยันได้: ${_getErrorMessage(e)}';
      notifyListeners();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      _error = null;
      _successMessage = null;
      await _auth.sendPasswordResetEmail(email: email);
      _successMessage = 'ส่งอีเมลรีเซ็ตรหัสผ่านแล้ว! กรุณาตรวจสอบกล่องจดหมายของคุณ';
      notifyListeners();
      return true;
    } catch (e) {
              _error = 'ไม่สามารถส่งอีเมลรีเซ็ตได้: ${_getErrorMessage(e)}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      debugPrint('🔄 Starting Google Sign-In process...');

      // Check if Google Play Services is available
      final bool isAvailable = await _googleSignIn.isSignedIn();
      debugPrint('📱 Google Play Services available: $isAvailable');

      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      debugPrint('🔄 Signed out from previous session');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('❌ User cancelled Google Sign-In');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      debugPrint('✅ Google user selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      debugPrint('✅ Got Google authentication tokens');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔄 Signing in with Firebase...');
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Firebase');
      }

      debugPrint('✅ Firebase sign-in successful: ${userCredential.user!.email}');
      
      // Check if user exists in Firestore, if not create a new user document
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser == true;
      
      if (isNewUser) {
        debugPrint('🔄 Creating new user document in Firestore...');
        await _createUserDocument(
          userCredential.user!,
          authProvider: 'google',
          userType: 'dentist', // Default
          isEmailVerified: true,
          additionalData: {
            'signInMethod': 'google',
            'googleProfile': {
              'displayName': userCredential.user!.displayName,
              'photoURL': userCredential.user!.photoURL,
            }
          },
        );
        debugPrint('✅ New Google user created in Firestore: ${userCredential.user!.email}');
      } else {
        debugPrint('🔄 Loading existing user data from Firestore...');
        // Load existing user data from Firestore
        await _loadUserModel();
        
        // Update last login time for existing users
        await _updateLastLogin();
        debugPrint('✅ Existing Google user loaded from Firestore: ${userCredential.user!.email}');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      _error = 'Error signing in with Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _createUserDocument(
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
        currentRole: userType,
        roles: [userType],
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

      // Store user data in Firestore 'users' collection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
      
      _userModel = userModel;
      
      // Log successful user creation
      debugPrint('✅ User document created in Firestore: ${user.email}');
    } catch (e) {
      _error = 'Error creating user document in Firestore: $e';
      debugPrint('❌ Failed to create user document: $e');
    }
  }

  // Role switching functionality
  Future<bool> switchRole(String newRole) async {
    try {
      if (_userModel == null || !_userModel!.roles.contains(newRole)) {
        _error = 'Invalid role or access denied';
        notifyListeners();
        return false;
      }

      final updatedUser = _userModel!.copyWith(
        currentRole: newRole,
        isDentist: newRole == 'dentist' || newRole == 'assistant',
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update({'currentRole': newRole, 'isDentist': updatedUser.isDentist});

      _userModel = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error switching role: $e';
      notifyListeners();
      return false;
    }
  }

  // Add role to user
  Future<bool> addRole(String role) async {
    try {
      if (_userModel == null || _userModel!.roles.contains(role)) {
        return false;
      }

      List<String> newRoles = List.from(_userModel!.roles)..add(role);
      
      final updatedUser = _userModel!.copyWith(
        roles: newRoles,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update({'roles': newRoles});

      _userModel = updatedUser;
      notifyListeners();
      return true;
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
      if (_userModel == null || !_userModel!.isMainAccount || _userModel!.userType != 'clinic') {
        _error = 'Only clinic owners can create sub-users';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      notifyListeners();

      // Create Firebase Auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(userName);
      await userCredential.user!.sendEmailVerification();

      // Create sub-user document
      final subUserModel = UserModel(
        userId: userCredential.user!.uid,
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
        parentUserId: _user!.uid,
        isMainAccount: false,
        branchName: branchName,
        branchAddress: branchAddress,
        permissions: {'permissions': permissions},
        isActive: true,
        isProfileComplete: true,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(subUserModel.toMap());

      // Update main account with sub-user ID
      List<String> currentSubUsers = List.from(_userModel!.subUserIds ?? []);
      currentSubUsers.add(userCredential.user!.uid);

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update({'subUserIds': currentSubUsers});

      // Update local user model
      _userModel = _userModel!.copyWith(subUserIds: currentSubUsers);

      _isLoading = false;
      _successMessage = 'สร้างผู้ใช้ย่อยสำเร็จแล้ว! อีเมลยืนยันถูกส่งไปแล้ว';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error creating sub-user: ${_getErrorMessage(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get sub-users for clinic
  Future<List<UserModel>> getSubUsers() async {
    if (_userModel == null || _userModel!.subUserIds == null) {
      return [];
    }

    try {
      List<UserModel> subUsers = [];
      for (String subUserId in _userModel!.subUserIds!) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(subUserId)
            .get();
        
        if (doc.exists) {
          subUsers.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
        }
      }
      return subUsers;
    } catch (e) {
      _error = 'Error loading sub-users: $e';
      notifyListeners();
      return [];
    }
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

      // Update user data in Firestore 'users' collection
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .set(updatedUser.toMap(), SetOptions(merge: true));

      _userModel = updatedUser;
      notifyListeners();
      
      debugPrint('✅ User profile updated in Firestore: ${_user!.email}');
      return true;
    } catch (e) {
      _error = 'Error updating user profile in Firestore: $e';
      debugPrint('❌ Failed to update user profile: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _userModel = null;
    } catch (e) {
      _error = 'Error signing out: $e';
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
    print('🤔 Checking if profile setup is needed...');
    
    if (_userModel == null) {
      print('   UserModel is null - setup needed');
      return true;
    }
    
    print('   UserModel exists for: ${_userModel!.email}');
    print('   isProfileComplete: ${_userModel!.isProfileComplete}');
    
    // If explicitly marked as complete, no setup needed
    if (_userModel!.isProfileComplete) {
      print('   Profile marked as complete - no setup needed');
      return false;
    }
    
    // For existing users, check if they have essential data even if not marked complete
    // This helps users who registered before the isProfileComplete field was implemented
    bool hasEssentialData = _hasEssentialProfileData();
    bool needsSetup = !hasEssentialData;
    
    print('   Profile not marked complete, checking essential data...');
    print('   Has essential data: $hasEssentialData');
    print('   Needs setup: $needsSetup');
    
    return needsSetup;
  }

  // Force refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_user != null) {
      print('🔄 Refreshing user data from Firestore...');
      await _loadUserModel();
      notifyListeners();
    }
  }

  // Debug method to check current auth state
  void debugAuthState() {
    print('🐛 DEBUG AUTH STATE:');
    print('   Firebase User: ${_user?.email ?? "null"}');
    print('   Firebase User UID: ${_user?.uid ?? "null"}');
    print('   UserModel: ${_userModel?.email ?? "null"}');
    print('   UserModel UserType: ${_userModel?.userType ?? "null"}');
    print('   IsProfileComplete: ${_userModel?.isProfileComplete ?? "null"}');
    print('   NeedsProfileSetup: $needsProfileSetup');
    print('   IsLoading: $_isLoading');
  }

  // Manual diagnostic method to check Firebase state
  Future<void> diagnoseFirebaseState() async {
    print('🔬 MANUAL FIREBASE DIAGNOSIS:');
    
    // Check Firebase Auth current user
    final currentUser = _auth.currentUser;
    print('   Firebase Auth currentUser: ${currentUser?.email ?? "null"}');
    print('   Firebase Auth currentUser UID: ${currentUser?.uid ?? "null"}');
    
    if (currentUser != null) {
      try {
        // Check if user document exists in Firestore
        final doc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        print('   Firestore document exists: ${doc.exists}');
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          print('   Firestore email: ${data['email'] ?? "null"}');
          print('   Firestore userType: ${data['userType'] ?? "null"}');
          print('   Firestore currentRole: ${data['currentRole'] ?? "null"}');
          print('   Firestore isProfileComplete: ${data['isProfileComplete'] ?? "null"}');
          print('   Firestore userName: ${data['userName'] ?? "null"}');
        }
      } catch (e) {
        print('   Error checking Firestore: $e');
      }
    }
    
    print('🔬 DIAGNOSIS COMPLETE');
  }

  // Sync user data between Firebase Auth and Firestore
  Future<bool> syncUserData() async {
    if (_user == null) return false;
    
    try {
      await _loadUserModel();
      
      if (_userModel != null) {
        // Update any discrepancies between Auth and Firestore
        Map<String, dynamic> updates = {};
        
        if (_userModel!.email != _user!.email) {
          updates['email'] = _user!.email;
        }
        
        if (_userModel!.isEmailVerified != _user!.emailVerified) {
          updates['isEmailVerified'] = _user!.emailVerified;
        }
        
        if (_userModel!.userName != _user!.displayName && _user!.displayName != null) {
          updates['userName'] = _user!.displayName;
        }
        
        if (_userModel!.profilePhotoUrl != _user!.photoURL) {
          updates['profilePhotoUrl'] = _user!.photoURL;
        }
        
        if (updates.isNotEmpty) {
          updates['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
          
          await _firestore
              .collection('users')
              .doc(_user!.uid)
              .update(updates);
              
          await _loadUserModel(); // Reload updated data
          debugPrint('✅ User data synchronized between Auth and Firestore');
        }
      }
      
      return true;
    } catch (e) {
      _error = 'Error syncing user data: $e';
      debugPrint('❌ Failed to sync user data: $e');
      return false;
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-not-found':
          return 'No user found for this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'พยายามหลายครั้งเกินไป กรุณาลองใหม่อีกครั้งในภายหลัง';
        default:
          return error.message ?? 'An error occurred.';
      }
    }
    return error.toString();
  }
} 