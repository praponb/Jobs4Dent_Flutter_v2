import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dashboard_utils.dart';
import '../../jobs/dentist_job_search_screen.dart';
import '../../jobs/my_applications_screen.dart';
import '../../profile/dentist_mini_resume_screen.dart';
import '../../profile/assistant_mini_resume_screen.dart';
import '../../profile/document_verification_screen.dart';
// import '../../marketplace/marketplace_screen.dart';
import '../../../providers/auth_provider.dart';

/// Quick actions widget for dentist dashboard
class DentistQuickActions extends StatelessWidget {
  final VoidCallback? onAvailabilityTap;

  const DentistQuickActions({super.key, this.onAvailabilityTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'การดำเนินการด่วน',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'ค้นหางาน',
                subtitle: 'ค้นหาโอกาสใหม่',
                icon: Icons.search,
                color: const Color(0xFF2196F3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DentistJobSearchScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'การสมัครของฉัน',
                subtitle: 'ติดตามความคืบหน้า',
                icon: Icons.folder,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyApplicationsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'ข้อมูลสำหรับสมัครงาน',
                subtitle: 'จัดการ Resume ย่อ',
                icon: Icons.assignment,
                color: Colors.orange,
                onTap: () {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final user = authProvider.userModel;

                  if (user?.userType == 'assistant') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssistantMiniResumeScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DentistMiniResumeScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'ยืนยันตัวตน',
                subtitle: 'อัปโหลดเอกสาร',
                icon: Icons.verified_user,
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentVerificationScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // const SizedBox(height: 12),
        // Row(
        //   children: [
        //     Expanded(
        //       child: _ActionCard(
        //         title: 'ตลาด',
        //         subtitle: 'ซื้อ/ขายผลิตภัณฑ์',
        //         icon: Icons.store,
        //         color: Colors.green,
        //         onTap: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
        //           );
        //         },
        //       ),
        //     ),
        //     const SizedBox(width: 12),
        //     Expanded(
        //       child: _ActionCard(
        //         title: 'ความพร้อม',
        //         subtitle: 'จัดการปฏิทิน',
        //         icon: Icons.event_available,
        //         color: Colors.purple,
        //         onTap: onAvailabilityTap,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

/// Individual action card widget
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: DashboardUtils.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
