import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for dashboard formatting and helper methods
class DashboardUtils {
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  /// Get color based on application status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Colors.blue;
      case 'under_review':
        return Colors.orange;
      case 'interview_scheduled':
        return Colors.purple;
      case 'offer_made':
        return Colors.green;
      case 'hired':
        return Colors.teal;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get display name for application status
  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'submitted':
        return 'ใหม่';
      case 'under_review':
        return 'กำลังพิจารณา';
      case 'interview_scheduled':
        return 'นัดสัมภาษณ์';
      case 'offer_made':
        return 'ให้ข้อเสนอแล้ว';
      case 'hired':
        return 'จ้างแล้ว';
      case 'rejected':
        return 'ปฏิเสธ';
      default:
        return 'ไม่ทราบ';
    }
  }

  /// Format time ago from datetime
  static String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 7) {
      return _dateFormat.format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }

  /// Format date using the standard format
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Create standard box shadow for dashboard cards
  static List<BoxShadow> get cardShadow {
    return [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.1),
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Create gradient box shadow for clinic info card
  static List<BoxShadow> get gradientCardShadow {
    return [
      BoxShadow(
        color: const Color(0xFF2196F3).withValues(alpha: 0.3),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ];
  }

  /// Standard card decoration
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: cardShadow,
    );
  }

  /// Show detailed analytics dialog
  static void showDetailedAnalytics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายงานวิเคราะห์โดยละเอียด'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ฟังก์ชันการวิเคราะห์แบบละเอียดจะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
            SizedBox(height: 16),
            Text('ฟีเจอร์ที่จะรวม:'),
            Text('• แนวโน้มการสมัครงานรายเดือน'),
            Text('• ประสิทธิภาพตามหมวดหมู่งาน'),
            Text('• อัตราการจ้างงานที่สำเร็จ'),
            Text('• ตัวชี้วัดเวลาในการจ้างงาน'),
            Text('• การวิเคราะห์แหล่งที่มาของผู้สมัคร'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
} 