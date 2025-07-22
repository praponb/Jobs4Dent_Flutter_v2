import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../education_experience_screen.dart';
import '../skills_specialties_screen.dart';
import '../work_location_preference_screen.dart';
import '../branch_management_screen.dart';
import '../role_switcher_screen.dart';
import '../document_verification_screen.dart';
import '../dentist_mini_resume_screen.dart';
import '../assistant_mini_resume_screen.dart';

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
  static List<ProfileMenuItem> getMenuItems(UserModel user, BuildContext context) {
    List<ProfileMenuItem> items = [];

    // Common menu items for all users
    items.addAll([
      ProfileMenuItem(
        icon: Icons.school,
        title: 'การศึกษาและประสบการณ์',
        subtitle: 'จัดการข้อมูลการศึกษาและประสบการณ์การทำงาน',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EducationExperienceScreen()),
        ),
      ),
      ProfileMenuItem(
        icon: Icons.star,
        title: 'ทักษะและความเชี่ยวชาญ',
        subtitle: 'เพิ่มข้อมูลทักษะและความเชี่ยวชาญของคุณ',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SkillsSpecialtiesScreen()),
        ),
      ),
    ]);

    // User type specific menu items
    if (user.userType == 'dentist') {
      items.addAll(_getDentistMenuItems(user, context));
    } else if (user.userType == 'assistant') {
      items.addAll(_getAssistantMenuItems(user, context));
    } else if (user.userType == 'clinic') {
      items.addAll(_getClinicMenuItems(user, context));
    } else if (user.userType == 'seller') {
      items.addAll(_getSellerMenuItems(user, context));
    } else if (user.userType == 'admin') {
      items.addAll(_getAdminMenuItems(user, context));
    }

    // Common verification and role management
    items.addAll([
      ProfileMenuItem(
        icon: Icons.verified_user,
        title: 'การตรวจสอบตัวตน',
        subtitle: _getVerificationSubtitle(user.verificationStatus),
        showBadge: user.verificationStatus == 'unverified' || user.verificationStatus == 'rejected',
        badgeColor: user.verificationStatus == 'rejected' ? Colors.red : Colors.orange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DocumentVerificationScreen()),
        ),
      ),
    ]);

    // Role management for multi-role users
    if (user.roles.length > 1) {
      items.add(
        ProfileMenuItem(
          icon: Icons.swap_horiz,
          title: 'เปลี่ยนบทบาท',
          subtitle: 'เปลี่ยนระหว่างบทบาทของคุณ',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RoleSwitcherScreen()),
          ),
        ),
      );
    }

    return items;
  }

  static List<ProfileMenuItem> _getDentistMenuItems(UserModel user, BuildContext context) {
    return [
      ProfileMenuItem(
        icon: Icons.account_circle,
        title: 'ประวัติส่วนตัว',
        subtitle: 'จัดการข้อมูลส่วนตัวและประวัติทันตแพทย์',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DentistMiniResumeScreen()),
        ),
      ),
      ProfileMenuItem(
        icon: Icons.location_on,
        title: 'การตั้งค่าสถานที่ทำงาน',
        subtitle: 'เลือกสถานที่ที่ต้องการทำงาน',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WorkLocationPreferenceScreen()),
        ),
      ),
    ];
  }

  static List<ProfileMenuItem> _getAssistantMenuItems(UserModel user, BuildContext context) {
    return [
      ProfileMenuItem(
        icon: Icons.account_circle,
        title: 'ประวัติผู้ช่วยทันตแพทย์',
        subtitle: 'จัดการข้อมูลส่วนตัวและทักษะ',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AssistantMiniResumeScreen()),
        ),
      ),
      ProfileMenuItem(
        icon: Icons.location_on,
        title: 'การตั้งค่าสถานที่ทำงาน',
        subtitle: 'เลือกสถานที่ที่ต้องการทำงาน',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WorkLocationPreferenceScreen()),
        ),
      ),
    ];
  }

  static List<ProfileMenuItem> _getClinicMenuItems(UserModel user, BuildContext context) {
    return [
      ProfileMenuItem(
        icon: Icons.business,
        title: 'จัดการสาขา',
        subtitle: 'เพิ่ม แก้ไข หรือลบสาขาของคลินิก',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BranchManagementScreen()),
        ),
      ),
    ];
  }

  static List<ProfileMenuItem> _getSellerMenuItems(UserModel user, BuildContext context) {
    return [
      // Add seller-specific menu items here
    ];
  }

  static List<ProfileMenuItem> _getAdminMenuItems(UserModel user, BuildContext context) {
    return [
      // Add admin-specific menu items here
    ];
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