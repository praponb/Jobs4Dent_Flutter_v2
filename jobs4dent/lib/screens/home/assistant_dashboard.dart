import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../models/assistant_job_model.dart';
import '../../models/job_application_model.dart';
import '../profile/profile_screen.dart';
import '../jobs/my_applications_screen.dart';
import '../profile/assistant_mini_resume_screen.dart';
import '../profile/document_verification_screen.dart';
import '../jobs/assistant_job_search_screen.dart';
import 'dashboard_utils.dart';
import 'dentist_data_processor.dart';

class AssistantDashboard extends StatefulWidget {
  const AssistantDashboard({super.key});

  @override
  State<AssistantDashboard> createState() => _AssistantDashboardState();
}

class _AssistantDashboardState extends State<AssistantDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, AssistantJobModel> _jobDetails = {};
  @override
  void initState() {
    super.initState();
    // Defer provider-loading until after first frame to avoid notify during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel != null) {
      // Load user's assistant applications and related data
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.getMyAssistantApplications(
        authProvider.userModel!.userId,
      );

      // Load job details for applications
      await _loadJobDetails(jobProvider.myApplications);
    }
  }

  Future<void> _loadJobDetails(List<JobApplicationModel> applications) async {
    final jobDetails = <String, AssistantJobModel>{};

    for (final application in applications) {
      try {
        final doc = await _firestore
            .collection('job_posts_assistant')
            .doc(application.jobId)
            .get();

        if (doc.exists) {
          final jobData = doc.data() as Map<String, dynamic>;
          jobData['jobId'] = jobData['jobId'] ?? doc.id;
          final job = AssistantJobModel.fromMap(jobData);
          jobDetails[application.jobId] = job;
        }
      } catch (e) {
        debugPrint('Error loading job details for ${application.jobId}: $e');
      }
    }

    if (mounted) {
      setState(() {
        _jobDetails = jobDetails;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.notifications),
          //   onPressed: () {
          //     // Note: Notifications feature pending implementation
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, JobProvider>(
        builder: (context, authProvider, jobProvider, child) {
          final user = authProvider.userModel;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final applications = jobProvider.userApplications;
          final stats = DentistDataProcessor.calculateQuickStats(applications);
          final upcomingInterviews = DentistDataProcessor.getUpcomingInterviews(
            applications,
          );
          final recentApplications = DentistDataProcessor.getRecentApplications(
            applications,
          );

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(user),
                  const SizedBox(height: 24),

                  // Quick Stats
                  _buildQuickStats(stats),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Upcoming Interviews
                  if (upcomingInterviews.isNotEmpty) ...[
                    _buildUpcomingInterviews(upcomingInterviews),
                    const SizedBox(height: 24),
                  ],

                  // Recent Applications
                  if (recentApplications.isNotEmpty) ...[
                    _buildRecentApplications(recentApplications),
                    const SizedBox(height: 24),
                  ],

                  // Job Search Tips Section
                  _buildJobSearchTips(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DashboardUtils.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue[100],
                backgroundImage:
                    user.profilePhotoUrl != null &&
                        user.profilePhotoUrl!.isNotEmpty
                    ? NetworkImage(user.profilePhotoUrl!)
                    : null,
                child:
                    user.profilePhotoUrl == null ||
                        user.profilePhotoUrl!.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.blue)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สวัสดี, ${user.userName}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ผู้ช่วยทันตแพทย์',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'พร้อมช่วยเหลือทีมงานทันตกรรม',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DentistQuickStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สถิติการสมัครงาน',
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
              child: _buildStatCard(
                title: 'สมัครทั้งหมด',
                value: '${stats.totalApplications}',
                icon: Icons.send,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'นัดสัมภาษณ์',
                value: '${stats.interviewsScheduled}',
                icon: Icons.event,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'ได้รับข้อเสนอ',
                value: '${stats.offersReceived}',
                icon: Icons.thumb_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'ได้งานแล้ว',
                value: '${stats.hired}',
                icon: Icons.work,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
              child: _buildActionCard(
                title: 'ค้นหางาน',
                subtitle: 'หางานผู้ช่วยทันตแพทย์',
                icon: Icons.search,
                color: const Color(0xFF2196F3),
                onTap: () {
                  debugPrint(
                    'AssistantDashboard: Navigating to AssistantJobSearchScreen',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssistantJobSearchScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
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
              child: _buildActionCard(
                title: 'ข้อมูลสำหรับสมัครงาน',
                subtitle: 'จัดการ Resume ย่อ',
                icon: Icons.assignment,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssistantMiniResumeScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
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
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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

  Widget _buildUpcomingInterviews(List upcomingInterviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'การสัมภาษณ์ที่จะมาถึง',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: DashboardUtils.cardDecoration,
          child: Column(
            children: upcomingInterviews.map((interview) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            interview.jobTitle ?? 'ตำแหน่งงาน',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (interview.interviewDate != null)
                            Text(
                              '${interview.interviewDate!.day}/${interview.interviewDate!.month}/${interview.interviewDate!.year}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentApplications(List recentApplications) {
    if (recentApplications.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the newest application (first in the list since they're sorted by date)
    final newestApplication = recentApplications.first;
    final job = _jobDetails[newestApplication.jobId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'การสมัครงานล่าสุด',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildApplicationCard(newestApplication, job),
      ],
    );
  }

  Widget _buildApplicationCard(
    JobApplicationModel application,
    AssistantJobModel? job,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showApplicationDetails(application),
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
                          job?.titlePost ??
                              application.jobTitle ??
                              'งานผู้ช่วยทันตแพทย์',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job?.clinicNameAndBranch ??
                              application.clinicName ??
                              'คลินิกทันตกรรม',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(application.status),
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
                      'ประเภทงาน: ${job.workType}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (job.workType == 'Full-time' &&
                    job.salaryFullTime != null) ...[
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
                        'เงินเดือน: ${job.salaryFullTime} บาท',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ] else if (job.workType == 'Part-time') ...[
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
                        _formatPartTimeRate(job),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
                if (job.skillAssistant.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'ทักษะ: ${job.skillAssistant.take(3).join(', ')}${job.skillAssistant.length > 3 ? ' และอีก ${job.skillAssistant.length - 3} รายการ' : ''}',
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

  Widget _buildJobSearchTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                'คำแนะนำสำหรับการหางาน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('อัปเดตข้อมูลส่วนตัวและทักษะให้ครบถ้วน'),
          _buildTip('ตรวจสอบเอกสารการศึกษาและใบรับรองต่างๆ'),
          _buildTip('เตรียมตัวสำหรับการสัมภาษณ์งาน'),
          _buildTip('ค้นหางานที่เหมาะสมกับทักษะของคุณ'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'submitted':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        icon = Icons.send;
        break;
      case 'interview_scheduled':
        backgroundColor = Colors.indigo[100]!;
        textColor = Colors.indigo[700]!;
        icon = Icons.event;
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
      case 'interview_scheduled':
        return 'สัมภาษณ์';
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

  String _formatPartTimeRate(AssistantJobModel job) {
    List<String> rates = [];
    if (job.payPerDayPartTime != null && job.payPerDayPartTime!.isNotEmpty) {
      rates.add('${job.payPerDayPartTime}/วัน');
    }
    if (job.payPerHourPartTime != null && job.payPerHourPartTime!.isNotEmpty) {
      rates.add('${job.payPerHourPartTime}/ชม.');
    }
    return rates.isEmpty ? 'ตามตกลง' : rates.join(', ');
  }

  void _showApplicationDetails(JobApplicationModel application) {
    final job = _jobDetails[application.jobId];

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
                  _buildStatusChip(application.status),
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
                        _buildDetailRow('ตำแหน่งงาน', job.titlePost),
                        _buildDetailRow('คลินิก', job.clinicNameAndBranch),
                        _buildDetailRow('ประเภทงาน', job.workType),
                        if (job.workType == 'Full-time' &&
                            job.salaryFullTime != null)
                          _buildDetailRow(
                            'เงินเดือน',
                            '${job.salaryFullTime} บาท',
                          ),
                        if (job.workType == 'Part-time')
                          _buildDetailRow(
                            'อัตราค่าจ้าง',
                            _formatPartTimeRate(job),
                          ),
                        if (job.skillAssistant.isNotEmpty)
                          _buildDetailRow(
                            'ทักษะที่ต้องการ',
                            job.skillAssistant.join(', '),
                          ),
                        if (job.perk != null && job.perk!.isNotEmpty)
                          _buildDetailRow('สวัสดิการ', job.perk!),
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
