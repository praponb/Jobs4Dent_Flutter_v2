import 'package:flutter/material.dart';
import '../../../models/job_application_model.dart';
import '../../../models/job_model.dart';
import '../../jobs/my_applications_screen.dart';
import '../../jobs/dentist_job_search_screen.dart';

/// Recent applications widget for dentist dashboard
class DentistRecentApplications extends StatelessWidget {
  final List<JobApplicationModel> recentApplications;
  final Map<String, JobModel> jobDetails;

  const DentistRecentApplications({
    super.key,
    required this.recentApplications,
    required this.jobDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (recentApplications.isEmpty) {
      return _buildEmptyState(context);
    }

    // Get the newest application (first in the list since they're sorted by date)
    final newestApplication = recentApplications.first;
    final job = jobDetails[newestApplication.jobId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'การสมัครงานล่าสุด',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApplicationsScreen(),
                  ),
                );
              },
              child: const Text('ดูทั้งหมด'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildApplicationCard(context, newestApplication, job),
      ],
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    JobApplicationModel application,
    JobModel? job,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showApplicationDetails(context, application, job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with job title and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job?.title ?? application.jobTitle ?? 'งานทันตกรรม',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job?.clinicName ??
                              application.clinicName ??
                              'คลินิกทันตกรรม',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, application.status),
                ],
              ),
              const SizedBox(height: 12),

              // Application info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'สมัครเมื่อ: ${_formatDate(application.appliedAt)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'อัปเดต: ${_formatDate(application.updatedAt)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              // Interview info (if applicable)
              if (application.interviewDate != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'นัดสัมภาษณ์แล้ว',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                            Text(
                              _formatDate(application.interviewDate!),
                              style: TextStyle(color: Colors.orange[700]),
                            ),
                            if (application.interviewLocation != null)
                              Text(
                                application.interviewLocation!,
                                style: TextStyle(color: Colors.orange[700]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Notes (if any)
              if (application.notes != null &&
                  application.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'หมายเหตุจากคลินิก:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            Text(
                              application.notes!,
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Job details
              if (job != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.work, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'ประเภทงาน: ${job.jobCategory}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (job.minSalary != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'เงินเดือน: ${job.minSalary} บาทขึ้นไป',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
                if (job.experienceLevel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'ระดับประสบการณ์: ${job.experienceLevel}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
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
          const Icon(Icons.inbox, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'ไม่มีการสมัครล่าสุด',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'เริ่มสมัครงานเพื่อดูรายการที่นี่',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DentistJobSearchScreen(),
                ),
              );
            },
            child: const Text('หางาน'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'submitted':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        icon = Icons.send;
        break;
      case 'under_review':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        icon = Icons.search;
        break;
      case 'shortlisted':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        icon = Icons.star;
        break;
      case 'interview_scheduled':
        backgroundColor = Colors.indigo[100]!;
        textColor = Colors.indigo[700]!;
        icon = Icons.event;
        break;
      case 'interview_completed':
        backgroundColor = Colors.teal[100]!;
        textColor = Colors.teal[700]!;
        icon = Icons.check_circle;
        break;
      case 'offered':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        icon = Icons.local_offer;
        break;
      case 'hired':
        backgroundColor = Colors.green[200]!;
        textColor = Colors.green[800]!;
        icon = Icons.celebration;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'submitted':
        return 'ส่งแล้ว';
      case 'under_review':
        return 'กำลังพิจารณา';
      case 'shortlisted':
        return 'คัดเลือก';
      case 'interview_scheduled':
        return 'สัมภาษณ์';
      case 'interview_completed':
        return 'สัมภาษณ์แล้ว';
      case 'offered':
        return 'ได้รับข้อเสนอ';
      case 'hired':
        return 'ได้งาน';
      case 'rejected':
        return 'ไม่ผ่าน';
      default:
        return 'ไม่ทราบ';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showApplicationDetails(
    BuildContext context,
    JobApplicationModel application,
    JobModel? job,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'รายละเอียดใบสมัคร',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(context, application.status),
                ],
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info
                      _buildDetailRow(
                        'วันที่สมัคร',
                        _formatDate(application.appliedAt),
                      ),
                      _buildDetailRow(
                        'อัปเดตล่าสุด',
                        _formatDate(application.updatedAt),
                      ),
                      _buildDetailRow(
                        'หมายเลขใบสมัคร',
                        application.applicationId,
                      ),

                      // Job Information
                      if (job != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'ข้อมูลงาน',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('ตำแหน่งงาน', job.title),
                        _buildDetailRow('คลินิก', job.clinicName),
                        _buildDetailRow('ประเภทงาน', job.jobCategory),
                        if (job.minSalary != null)
                          _buildDetailRow(
                            'เงินเดือน',
                            '${job.minSalary} บาทขึ้นไป',
                          ),
                        if (job.experienceLevel.isNotEmpty)
                          _buildDetailRow(
                            'ระดับประสบการณ์',
                            job.experienceLevel,
                          ),
                        if (job.perks != null && job.perks!.isNotEmpty)
                          _buildDetailRow('สวัสดิการ', job.perks!),
                      ],

                      if (application.interviewDate != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'ข้อมูลการสัมภาษณ์',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'วันที่สัมภาษณ์',
                          _formatDate(application.interviewDate!),
                        ),
                        if (application.interviewLocation != null)
                          _buildDetailRow(
                            'สถานที่',
                            application.interviewLocation!,
                          ),
                        if (application.interviewNotes != null)
                          _buildDetailRow(
                            'หมายเหตุ',
                            application.interviewNotes!,
                          ),
                      ],

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Cover Letter
                      Text(
                        'จดหมายนำ',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(application.coverLetter),
                      ),

                      // Additional Documents
                      if (application.additionalDocuments.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'เอกสารเพิ่มเติม',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...application.additionalDocuments.map(
                          (doc) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.description, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(doc)),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Notes from clinic
                      if (application.notes != null &&
                          application.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'หมายเหตุจากคลินิก',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(application.notes!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
