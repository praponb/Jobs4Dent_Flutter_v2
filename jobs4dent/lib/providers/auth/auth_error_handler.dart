import 'package:firebase_auth/firebase_auth.dart';

/// Utility class for handling authentication error messages
class AuthErrorHandler {
  /// Get user-friendly error messages for Firebase Auth exceptions
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'รหัสผ่านไม่ปลอดภัยเพียงพอ กรุณาใช้รหัสผ่านที่แข็งแกร่งกว่านี้';
        case 'email-already-in-use':
          return 'อีเมลนี้ถูกใช้งานแล้ว\n\n'
              '💡 หากคุณกำลังทดสอบ:\n'
              '• ลบผู้ใช้จาก Firebase Authentication Console\n'
              '• หรือใช้อีเมลอื่นสำหรับการทดสอบ\n\n'
              'กรุณาเข้าสู่ระบบ หรือใช้อีเมลอื่น';
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'user-not-found':
          return 'ไม่พบบัญชีผู้ใช้สำหรับอีเมลนี้';
        case 'wrong-password':
          return 'รหัสผ่านไม่ถูกต้อง';
        case 'user-disabled':
          return 'บัญชีผู้ใช้นี้ถูกปิดใช้งาน';
        case 'invalid-credential':
        case 'INVALID_LOGIN_CREDENTIALS':
          return 'ข้อมูลการเข้าสู่ระบบไม่ถูกต้อง หรือเซสชันหมดอายุ';
        case 'too-many-requests':
          return 'พยายามหลายครั้งเกินไป กรุณาลองใหม่อีกครั้งในภายหลัง';
        default:
          return error.message ?? 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
      }
    }
    return error.toString();
  }

  /// Common success messages for authentication operations
  static const String registrationSuccess =
      'ลงทะเบียนสำเร็จแล้ว! กรุณาตรวจสอบอีเมลเพื่อยืนยันบัญชีของคุณ';
  static const String emailVerificationSent =
      'ส่งอีเมลยืนยันแล้ว! กรุณาตรวจสอบกล่องจดหมายของคุณ';
  static const String passwordResetSent =
      'ส่งอีเมลรีเซ็ตรหัสผ่านแล้ว! กรุณาตรวจสอบกล่องจดหมายของคุณ';
  static const String subUserCreated =
      'สร้างผู้ใช้ย่อยสำเร็จแล้ว! อีเมลยืนยันถูกส่งไปแล้ว';

  /// Common error messages
  static const String emailNotVerified = 'กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ';
  static const String invalidRoleOrAccess = 'Invalid role or access denied';
  static const String clinicOwnerOnly =
      'Only clinic owners can create sub-users';
}
