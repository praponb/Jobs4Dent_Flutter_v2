import 'package:flutter/material.dart';
import '../../../models/job_application_model.dart';
import '../dashboard_data_processor.dart';
import '../dashboard_utils.dart';
import '../../jobs/applicant_management_screen.dart';

/// Dashboard recent applications widget
class DashboardRecentApplications extends StatelessWidget {
  final List<JobApplicationModel> applications;

  const DashboardRecentApplications({
    super.key,
    required this.applications,
  });

  @override
  Widget build(BuildContext context) {
    final recentApplications = DashboardDataProcessor.getRecentApplications(applications)
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'ใบสมัครล่าสุด',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ApplicantManagementScreen(),
                  ),
                );
              },
              child: const Text('ดูทั้งหมด'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentApplications.isEmpty)
          _buildEmptyState()
        else
          ...recentApplications.map((application) => 
            _ApplicationCard(application: application)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'ไม่มีใบสมัครล่าสุด',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'ใบสมัครจะแสดงที่นี่เมื่อมีผู้สมัคร',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Individual application card widget
class _ApplicationCard extends StatelessWidget {
  final JobApplicationModel application;

  const _ApplicationCard({
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue[100],
            child: const Icon(Icons.person, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.applicantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'สมัครเมื่อ ${DashboardUtils.getTimeAgo(application.appliedAt)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DashboardUtils.getStatusColor(application.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              DashboardUtils.getStatusDisplayName(application.status),
              style: TextStyle(
                fontSize: 12,
                color: DashboardUtils.getStatusColor(application.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 