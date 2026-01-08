import 'package:firebase_auth/firebase_auth.dart';
import 'auth_error_handler.dart';

/// Service class for Firebase Authentication operations
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register with email and password
  static Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String userName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Update display name
      await userCredential.user!.updateDisplayName(userName);

      return AuthResult.success(
        user: userCredential.user!,
        message: AuthErrorHandler.registrationSuccess,
      );
    } catch (e) {
      return AuthResult.error(AuthErrorHandler.getErrorMessage(e));
    }
  }

  /// Sign in with email and password
  static Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        return AuthResult.error(AuthErrorHandler.emailNotVerified);
      }

      return AuthResult.success(user: userCredential.user!);
    } catch (e) {
      return AuthResult.error(AuthErrorHandler.getErrorMessage(e));
    }
  }

  /// Resend email verification
  static Future<AuthResult> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return AuthResult.success(
          user: user,
          message: AuthErrorHandler.emailVerificationSent,
        );
      }
      return AuthResult.error('No user to send verification to');
    } catch (e) {
      return AuthResult.error('ไม่สามารถส่งอีเมลยืนยันได้: ${AuthErrorHandler.getErrorMessage(e)}');
    }
  }

  /// Reset password
  static Future<AuthResult> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(message: AuthErrorHandler.passwordResetSent);
    } catch (e) {
      return AuthResult.error('ไม่สามารถส่งอีเมลรีเซ็ตได้: ${AuthErrorHandler.getErrorMessage(e)}');
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Create user with Firebase Auth for sub-users
  static Future<AuthResult> createSubUserAccount({
    required String email,
    required String password,
    required String userName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(userName);
      await userCredential.user!.sendEmailVerification();

      return AuthResult.success(
        user: userCredential.user!,
        message: AuthErrorHandler.subUserCreated,
      );
    } catch (e) {
      return AuthResult.error(AuthErrorHandler.getErrorMessage(e));
    }
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool success;
  final User? user;
  final String? message;
  final String? error;

  AuthResult._({
    required this.success,
    this.user,
    this.message,
    this.error,
  });

  factory AuthResult.success({User? user, String? message}) {
    return AuthResult._(
      success: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }
} 