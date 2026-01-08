import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_application_model.dart';
import '../../models/assistant_job_model.dart';
import '../../models/job_model.dart';
import 'assistant_job_search_screen.dart';
import 'dentist_job_search_screen.dart';

class MyApplicationsScreen extends StatefulWidget {
  final String? initialFilter;

  const MyApplicationsScreen({super.key, this.initialFilter});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, AssistantJobModel> _assistantJobDetails = {};
  Map<String, JobModel> _dentistJobDetails = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Set initial tab based on filter
    if (widget.initialFilter == 'interview_scheduled') {
      _tabController.index = 1; // Active tab
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadApplications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (authProvider.userModel != null) {
      final user = authProvider.userModel!;

      if (user.userType == 'dentist') {
        // Load dentist job applications for the current user
        await jobProvider.getMyDentistApplications(user.userId);

        // Load dentist job details for each application
        await _loadDentistJobDetails(jobProvider.myApplications);
      } else {
        // Load assistant job applications for the current user
        await jobProvider.getMyAssistantApplications(user.userId);

        // Load assistant job details for each application
        await _loadAssistantJobDetails(jobProvider.myApplications);
      }
    }
  }

  Future<void> _loadAssistantJobDetails(
    List<JobApplicationModel> applications,
  ) async {
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
        debugPrint(
          'Error loading assistant job details for ${application.jobId}: $e',
        );
      }
    }

    if (mounted) {
      setState(() {
        _assistantJobDetails = jobDetails;
      });
    }
  }

  Future<void> _loadDentistJobDetails(
    List<JobApplicationModel> applications,
  ) async {
    final jobDetails = <String, JobModel>{};

    for (final application in applications) {
      try {
        final doc = await _firestore
            .collection('job_posts_dentist')
            .doc(application.jobId)
            .get();

        if (doc.exists) {
          final jobData = doc.data() as Map<String, dynamic>;
          jobData['jobId'] = jobData['jobId'] ?? doc.id;
          final job = JobModel.fromMap(jobData);
          jobDetails[application.jobId] = job;
        }
      } catch (e) {
        debugPrint(
          'Error loading dentist job details for ${application.jobId}: $e',
        );
      }
    }

    if (mounted) {
      setState(() {
        _dentistJobDetails = jobDetails;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การสมัครของฉัน'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ทั้งหมด'),
            Tab(text: 'กำลังดำเนินการ'),
            Tab(text: 'เสร็จสิ้น'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationsList(),
          _buildApplicationsList(statusFilter: 'active'),
          _buildApplicationsList(statusFilter: 'completed'),
        ],
      ),
    );
  }

  Widget _buildApplicationsList({String? statusFilter}) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (jobProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'เกิดข้อผิดพลาดในการโหลดการสมัคร',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(jobProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadApplications,
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        List<JobApplicationModel> applications = jobProvider.myApplications;

        // Apply status filter
        if (statusFilter == 'active') {
          applications = applications.where((app) => app.isActive).toList();
        } else if (statusFilter == 'completed') {
          applications = applications.where((app) => app.isCompleted).toList();
        }

        if (applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  statusFilter == null
                      ? 'ยังไม่มีการสมัคร'
                      : 'ไม่มีการสมัคร$statusFilter',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('เริ่มสมัครงานเพื่อดูรายการที่นี่'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    final user = authProvider.userModel;
                    if (user?.userType == 'dentist') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DentistJobSearchScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AssistantJobSearchScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text('ค้นหางาน'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadApplications(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return _buildApplicationCard(application);
            },
          ),
        );
      },
    );
  }

  Widget _buildApplicationCard(JobApplicationModel application) {
    final assistantJob = _assistantJobDetails[application.jobId];
    final dentistJob = _dentistJobDetails[application.jobId];

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
                          assistantJob?.titlePost ??
                              dentistJob?.title ??
                              application.jobTitle ??
                              'งานทันตกรรม',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assistantJob?.clinicNameAndBranch ??
                              dentistJob?.clinicName ??
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
              if (assistantJob != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.work, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'ประเภทงาน: ${assistantJob.workType}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                if (assistantJob.workType == 'Full-time' &&
                    assistantJob.salaryFullTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'เงินเดือน: ${assistantJob.salaryFullTime} บาท',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ] else if (assistantJob.workType == 'Part-time') ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatPartTimeRate(assistantJob),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
                if (assistantJob.skillAssistant.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'ทักษะ: ${assistantJob.skillAssistant.take(3).join(', ')}${assistantJob.skillAssistant.length > 3 ? ' และอีก ${assistantJob.skillAssistant.length - 3} รายการ' : ''}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ] else if (dentistJob != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.work, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'ประเภทงาน: ${dentistJob.jobCategory}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                if (dentistJob.minSalary != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'เงินเดือน: ${dentistJob.minSalary} บาทขึ้นไป',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
                if (dentistJob.experienceLevel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'ระดับประสบการณ์: ${dentistJob.experienceLevel}',
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
            _getStatusDisplayName(status),
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

  String _getStatusDisplayName(String status) {
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
    final assistantJob = _assistantJobDetails[application.jobId];
    final dentistJob = _dentistJobDetails[application.jobId];

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
                      if (assistantJob != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'ข้อมูลงาน',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('ตำแหน่งงาน', assistantJob.titlePost),
                        _buildDetailRow(
                          'คลินิก',
                          assistantJob.clinicNameAndBranch,
                        ),
                        _buildDetailRow('ประเภทงาน', assistantJob.workType),
                        if (assistantJob.workType == 'Full-time' &&
                            assistantJob.salaryFullTime != null)
                          _buildDetailRow(
                            'เงินเดือน',
                            '${assistantJob.salaryFullTime} บาท',
                          ),
                        if (assistantJob.workType == 'Part-time')
                          _buildDetailRow(
                            'อัตราค่าจ้าง',
                            _formatPartTimeRate(assistantJob),
                          ),
                        if (assistantJob.skillAssistant.isNotEmpty)
                          _buildDetailRow(
                            'ทักษะที่ต้องการ',
                            assistantJob.skillAssistant.join(', '),
                          ),
                        if (assistantJob.perk != null &&
                            assistantJob.perk!.isNotEmpty)
                          _buildDetailRow('สวัสดิการ', assistantJob.perk!),
                      ] else if (dentistJob != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'ข้อมูลงาน',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('ตำแหน่งงาน', dentistJob.title),
                        _buildDetailRow('คลินิก', dentistJob.clinicName),
                        _buildDetailRow('ประเภทงาน', dentistJob.jobCategory),
                        if (dentistJob.minSalary != null)
                          _buildDetailRow(
                            'เงินเดือน',
                            '${dentistJob.minSalary} บาทขึ้นไป',
                          ),
                        if (dentistJob.experienceLevel.isNotEmpty)
                          _buildDetailRow(
                            'ระดับประสบการณ์',
                            dentistJob.experienceLevel,
                          ),
                        if (dentistJob.perks != null &&
                            dentistJob.perks!.isNotEmpty)
                          _buildDetailRow('สวัสดิการ', dentistJob.perks!),
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
