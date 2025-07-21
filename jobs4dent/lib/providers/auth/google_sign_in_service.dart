import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service class for Google Sign-In operations
class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with Google
  static Future<GoogleSignInResult> signInWithGoogle() async {
    try {
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
        return GoogleSignInResult.cancelled();
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
      
      // Check if user is new or existing
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser == true;
      
      return GoogleSignInResult.success(
        user: userCredential.user!,
        isNewUser: isNewUser,
        googleProfile: GoogleUserProfile(
          displayName: userCredential.user!.displayName,
          photoURL: userCredential.user!.photoURL,
          email: userCredential.user!.email ?? '',
        ),
      );
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      return GoogleSignInResult.error('Error signing in with Google: $e');
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Check if user is signed in with Google
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}

/// Result class for Google Sign-In operations
class GoogleSignInResult {
  final bool success;
  final bool cancelled;
  final User? user;
  final bool isNewUser;
  final GoogleUserProfile? googleProfile;
  final String? error;

  GoogleSignInResult._({
    required this.success,
    this.cancelled = false,
    this.user,
    this.isNewUser = false,
    this.googleProfile,
    this.error,
  });

  factory GoogleSignInResult.success({
    required User user,
    required bool isNewUser,
    GoogleUserProfile? googleProfile,
  }) {
    return GoogleSignInResult._(
      success: true,
      user: user,
      isNewUser: isNewUser,
      googleProfile: googleProfile,
    );
  }

  factory GoogleSignInResult.cancelled() {
    return GoogleSignInResult._(
      success: false,
      cancelled: true,
    );
  }

  factory GoogleSignInResult.error(String error) {
    return GoogleSignInResult._(
      success: false,
      error: error,
    );
  }
}

/// Google user profile data
class GoogleUserProfile {
  final String? displayName;
  final String? photoURL;
  final String email;

  GoogleUserProfile({
    this.displayName,
    this.photoURL,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'photoURL': photoURL,
      'email': email,
    };
  }
} 