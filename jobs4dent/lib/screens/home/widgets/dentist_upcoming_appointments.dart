import 'package:flutter/material.dart';
import '../../../models/job_application_model.dart';
import '../dashboard_utils.dart';
import '../../jobs/my_applications_screen.dart';

/// Upcoming appointments widget for dentist dashboard
class DentistUpcomingAppointments extends StatelessWidget {
  final List<JobApplicationModel> upcomingInterviews;

  const DentistUpcomingAppointments({
    super.key,
    required this.upcomingInterviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'การสัมภาษณ์ที่กำลังจะมา',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (upcomingInterviews.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyApplicationsScreen(
                        initialFilter: 'interview_scheduled',
                      ),
                    ),
                  );
                },
                child: const Text('ดูทั้งหมด'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (upcomingInterviews.isEmpty)
          _buildEmptyState(context)
        else
          ...upcomingInterviews.map(
            (interview) => _InterviewCard(interview: interview),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
          Icon(Icons.event_note, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'ไม่มีการสัมภาษณ์ที่กำลังจะมา',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'สมัครงานต่อไปเพื่อรับคำเชิญให้สัมภาษณ์',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Individual interview card widget
class _InterviewCard extends StatelessWidget {
  final JobApplicationModel interview;

  const _InterviewCard({required this.interview});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'มีการนัดสัมภาษณ์',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  interview.interviewDate != null
                      ? DashboardUtils.formatDate(interview.interviewDate!)
                      : 'ไม่ระบุวันที่',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Clinic: ${interview.clinicId}', // In real app, fetch clinic name
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (interview.interviewLocation != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    interview.interviewLocation!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
