import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../models/assistant_job_model.dart';
import '../../../models/job_application_model.dart';
import '../dashboard_data_processor.dart';
import '../dashboard_utils.dart';
import '../../jobs/dentist_job_posting_screen.dart';
import '../../jobs/assistant_job_posting_screen.dart';
import '../../jobs/my_posted_dentist_jobs_screen.dart';
import '../../jobs/my_posted_assistant_jobs_screen.dart';

/// Dashboard active jobs overview widget
class DashboardJobsOverview extends StatelessWidget {
  final List<JobModel> jobs;
  final List<AssistantJobModel> assistantJobs;
  final List<JobApplicationModel> applications;

  const DashboardJobsOverview({
    super.key,
    required this.jobs,
    required this.assistantJobs,
    required this.applications,
  });

  @override
  Widget build(BuildContext context) {
    final activeJobs = DashboardDataProcessor.getActiveJobsForOverview(jobs);
    final activeAssistantJobs =
        DashboardDataProcessor.getActiveAssistantJobsForOverview(assistantJobs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'ประกาศงาน(ทันตแพทย์)ที่เปิดอยู่',
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
                    builder: (context) => const MyPostedDentistJobsScreen(),
                  ),
                );
              },
              child: const Text('ดูทั้งหมด'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (activeJobs.isEmpty)
          _buildEmptyState(context)
        else
          ...activeJobs.map(
            (job) => _JobCard(
              job: job,
              applicationCount: DashboardDataProcessor.getApplicationsForJob(
                job.jobId,
                applications,
              ).length,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'ประกาศงาน(ผู้ช่วย)ที่เปิดอยู่',
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
                    builder: (context) => const MyPostedAssistantJobsScreen(),
                  ),
                );
              },
              child: const Text('ดูทั้งหมด'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (activeAssistantJobs.isEmpty)
          _buildEmptyAssistantState(context)
        else
          ...activeAssistantJobs.map(
            (job) => _AssistantJobCard(
              job: job,
              applicationCount:
                  DashboardDataProcessor.getApplicationsForAssistantJob(
                    job.jobId,
                    applications,
                  ).length,
            ),
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
      child: Column(
        children: [
          const Icon(Icons.work_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'ไม่มีประกาศงานที่เปิดอยู่',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'สร้างประกาศงานแรกของคุณเพื่อเริ่มต้นการจ้างงาน',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DentistJobPostingScreen(),
                ),
              );
            },
            child: const Text('ประกาศหางาน'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAssistantState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.work_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'ไม่มีประกาศงานผู้ช่วยที่เปิดอยู่',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'สร้างประกาศงานผู้ช่วยทันตแพทย์เพื่อเริ่มต้นการจ้างงาน',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssistantJobPostingScreen(),
                ),
              );
            },
            child: const Text('ประกาศหางานผู้ช่วย'),
          ),
        ],
      ),
    );
  }
}

/// Individual job card widget
class _JobCard extends StatelessWidget {
  final JobModel job;
  final int applicationCount;

  const _JobCard({required this.job, required this.applicationCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.jobCategory,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'เปิดใช้งาน',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${job.city}, ${job.province}',
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$applicationCount ใบสมัคร',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          if (job.deadline != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.orange[600]),
                const SizedBox(width: 4),
                Text(
                  'กำหนดส่ง: ${DashboardUtils.formatDate(job.deadline!)}',
                  style: TextStyle(color: Colors.orange[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual assistant job card widget
class _AssistantJobCard extends StatelessWidget {
  final AssistantJobModel job;
  final int applicationCount;

  const _AssistantJobCard({required this.job, required this.applicationCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.titlePost,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.workType,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'เปิดใช้งาน',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.clinicNameAndBranch,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$applicationCount ใบสมัคร',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Skills preview
          if (job.skillAssistant.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.medical_services, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'ทักษะ: ${job.skillAssistant.take(2).join(", ")}${job.skillAssistant.length > 2 ? " และอีก ${job.skillAssistant.length - 2} ทักษะ" : ""}',
                    style: TextStyle(color: Colors.blue[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
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
