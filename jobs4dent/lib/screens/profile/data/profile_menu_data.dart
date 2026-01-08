import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../document_verification_screen.dart';

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showBadge;
  final Color? badgeColor;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.showBadge = false,
    this.badgeColor,
  });
}

class ProfileMenuData {
  static List<ProfileMenuItem> getMenuItems(
    UserModel user,
    BuildContext context,
  ) {
    List<ProfileMenuItem> items = [];

    // Common verification and role management
    items.addAll([
      ProfileMenuItem(
        icon: Icons.verified_user,
        title: 'การตรวจสอบตัวตน',
        subtitle: _getVerificationSubtitle(user.verificationStatus),
        showBadge:
            user.verificationStatus == 'unverified' ||
            user.verificationStatus == 'rejected',
        badgeColor: user.verificationStatus == 'rejected'
            ? Colors.red
            : Colors.orange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DocumentVerificationScreen(),
          ),
        ),
      ),
    ]);

    return items;
  }

  static String _getVerificationSubtitle(String status) {
    switch (status) {
      case 'verified':
        return 'ผ่านการตรวจสอบแล้ว';
      case 'pending':
        return 'รอการตรวจสอบ';
      case 'rejected':
        return 'ถูกปฏิเสธ - โปรดอัปโหลดเอกสารใหม่';
      default:
        return 'ยังไม่ได้ตรวจสอบ - โปรดอัปโหลดเอกสาร';
    }
  }
}
