import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  void _init() async {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserModel();
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserModel() async {
    if (_user != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(_user!.uid)
            .get();
        
        if (doc.exists) {
          _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      } catch (e) {
        _error = 'Error loading user data: $e';
      }
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Check if user exists in Firestore, if not create a new user document
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _createUserDocument(userCredential.user!);
      }

      return true;
    } catch (e) {
      _error = 'Error signing in with Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _createUserDocument(User user) async {
    try {
      final userModel = UserModel(
        userId: user.uid,
        email: user.email ?? '',
        userName: user.displayName ?? '',
        profilePhotoUrl: user.photoURL,
        isDentist: true, // Default to dentist, can be changed later
        userType: 'dentist', // Default type
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());
      
      _userModel = userModel;
    } catch (e) {
      _error = 'Error creating user document: $e';
    }
  }

  Future<bool> updateUserProfile({
    required bool isDentist,
    required String userType,
    String? phoneNumber,
    String? address,
    List<String>? skills,
    List<String>? workLocationPreference,
    List<String>? education,
    List<String>? experience,
    String? clinicName,
    String? clinicAddress,
    List<String>? serviceTypes,
  }) async {
    try {
      if (_user == null || _userModel == null) return false;

      final updatedUser = _userModel!.copyWith(
        isDentist: isDentist,
        userType: userType,
        phoneNumber: phoneNumber,
        address: address,
        skills: skills,
        workLocationPreference: workLocationPreference,
        education: education,
        experience: experience,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        serviceTypes: serviceTypes,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update(updatedUser.toMap());

      _userModel = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating user profile: $e';
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
} 