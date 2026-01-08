import 'package:flutter/material.dart';
import '../dashboard_utils.dart';
import '../../jobs/dentist_job_posting_screen.dart';
import '../../jobs/assistant_job_posting_screen.dart';
import '../../jobs/my_posted_assistant_jobs_screen.dart';
import '../../jobs/my_posted_dentist_jobs_screen.dart';
import '../../jobs/applicant_management_screen.dart';
// import '../../profile/branch_management_screen.dart';
import '../../profile/document_verification_screen.dart';
// import '../../profile/sub_branch_management_screen.dart';

/// Dashboard quick actions widget
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

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
                title: 'ประกาศงานทันตแพทย์',
                subtitle: 'หาทันตแพทย์',
                icon: Icons.add_circle,
                color: const Color(0xFF2196F3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DentistJobPostingScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'ประกาศงานผู้ช่วยทันตแพทย์',
                subtitle: 'หาผู้ช่วยทันตแพทย์',
                icon: Icons.person_add,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssistantJobPostingScreen(),
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
                title: 'งานที่ประกาศ',
                subtitle: 'ดูงานทันตแพทย์',
                icon: Icons.work_history,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyPostedDentistJobsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'งานที่ประกาศ',
                subtitle: 'ดูงานผู้ช่วยทันตแพทย์',
                icon: Icons.work_history,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyPostedAssistantJobsScreen(),
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
                title: 'ดูใบสมัคร',
                subtitle: 'ตรวจสอบผู้สมัคร',
                icon: Icons.inbox,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApplicantManagementScreen(),
                    ),
                  );
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
        const SizedBox(height: 12),
        // Row(
        //   children: [
        //     Expanded(
        //       child: _ActionCard(
        //         title: 'จัดการข้อมูลสาขา',
        //         subtitle: 'จัดการสาขาคลินิก',
        //         icon: Icons.business,
        //         color: Colors.purple,
        //         onTap: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => const BranchManagementScreen(),
        //             ),
        //           );
        //         },
        //       ),
        //     ),
        //     const SizedBox(width: 12),
        //     Expanded(
        //       child: _ActionCard(
        //         title: 'จัดการผู้ใช้ย่อย',
        //         subtitle: 'Sub-users & permissions',
        //         icon: Icons.account_tree,
        //         color: Colors.amber,
        //         onTap: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => const SubBranchManagementScreen(),
        //             ),
        //           );
        //         },
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
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
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
