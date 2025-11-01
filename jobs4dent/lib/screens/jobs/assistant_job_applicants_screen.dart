import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_application_model.dart';

class AssistantJobApplicantsScreen extends StatefulWidget {
  const AssistantJobApplicantsScreen({super.key});

  @override
  State<AssistantJobApplicantsScreen> createState() =>
      _AssistantJobApplicantsScreenState();
}

class _AssistantJobApplicantsScreenState
    extends State<AssistantJobApplicantsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadApplications() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (authProvider.userModel != null) {
      jobProvider.getAssistantApplicantsForMyJobs(
        authProvider.userModel!.userId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการผู้สมัครงานผู้ช่วย'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'ทั้งหมด'),
            Tab(text: 'ใหม่'),
            Tab(text: 'กำลังดำเนินการ'),
            Tab(text: 'เสร็จสิ้น'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationsList(),
          _buildApplicationsList(statusFilter: 'new'),
          _buildApplicationsList(statusFilter: 'in_progress'),
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

        List<JobApplicationModel> applications =
            jobProvider.assistantApplicantsForMyJobs;

        // Apply status filter
        if (statusFilter == 'new') {
          applications = applications.where((app) => app.isPending).toList();
        } else if (statusFilter == 'in_progress') {
          applications = applications.where((app) => app.isInProgress).toList();
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
                      ? 'ยังไม่มีการสมัครงานผู้ช่วย'
                      : 'ไม่มีการสมัครงานผู้ช่วย${statusFilter.replaceAll('_', ' ')}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'การสมัครจะปรากฏที่นี่เมื่อมีคนสมัครงานผู้ช่วยของคุณ',
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showApplicationDetails(application),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with applicant name and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    backgroundImage: application.applicantProfilePhoto != null
                        ? NetworkImage(application.applicantProfilePhoto!)
                        : null,
                    child: application.applicantProfilePhoto == null
                        ? Text(
                            application.applicantName.isNotEmpty
                                ? application.applicantName[0].toUpperCase()
                                : 'A',
                            style: TextStyle(color: Colors.blue[700]),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.applicantName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.applicantEmail,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status chips in column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Verification status badge
                      if (application.applicantProfile != null &&
                          application.applicantProfile!['verificationStatus'] !=
                              null)
                        _buildVerificationStatusChip(
                          application.applicantProfile!['verificationStatus'],
                        ),
                      if (application.applicantProfile != null &&
                          application.applicantProfile!['verificationStatus'] !=
                              null)
                        const SizedBox(height: 4),
                      _buildStatusChip(application.status),
                    ],
                  ),
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
                  const SizedBox(width: 16),
                  if (application.matchingScore != null) ...[
                    Icon(Icons.star, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 4),
                    Text(
                      'ตรงกัน ${application.matchingScore!.round()}%',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              // Job type indicator
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.work, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'ประเภทงาน: ผู้ช่วยทันตแพทย์',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Phone number if available
              if (application.applicantPhone != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      application.applicantPhone!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],

              // Cover letter preview
              const SizedBox(height: 12),
              Text(
                'จดหมายนำ:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                application.coverLetter,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),

              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateStatusDialog(application),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('อัปเดตสถานะ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApplicationDetails(application),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('ดูรายละเอียด'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'submitted':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        break;
      case 'under_review':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        break;
      case 'shortlisted':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        break;
      case 'interview_scheduled':
        backgroundColor = Colors.indigo[100]!;
        textColor = Colors.indigo[700]!;
        break;
      case 'interview_completed':
        backgroundColor = Colors.teal[100]!;
        textColor = Colors.teal[700]!;
        break;
      case 'offered':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        break;
      case 'hired':
        backgroundColor = Colors.green[200]!;
        textColor = Colors.green[800]!;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'submitted':
        return 'ใหม่';
      case 'under_review':
        return 'กำลังพิจารณา';
      case 'shortlisted':
        return 'ผ่านเข้ารอบ';
      case 'interview_scheduled':
        return 'นัดสัมภาษณ์';
      case 'interview_completed':
        return 'สัมภาษณ์แล้ว';
      case 'offered':
        return 'ได้รับข้อเสนอ';
      case 'hired':
        return 'รับเข้าทำงาน';
      case 'rejected':
        return 'ปฏิเสธ';
      default:
        return 'ไม่ทราบ';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showApplicationDetails(JobApplicationModel application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
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

              // Header with actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      application.applicantName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showUpdateStatusDialog(application);
                    },
                    child: const Text('อัปเดตสถานะ'),
                  ),
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
                      // Applicant profile information
                      if (application.applicantProfile != null) ...[
                        _buildSectionTitle('โปรไฟล์ผู้สมัคร'),
                        _buildProfileCard(application.applicantProfile!),
                        const SizedBox(height: 16),
                      ],

                      // Cover letter
                      _buildSectionTitle('จดหมายนำ'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(application.coverLetter),
                      ),
                      const SizedBox(height: 16),

                      // Additional documents
                      if (application.additionalDocuments.isNotEmpty) ...[
                        _buildSectionTitle('เอกสารเพิ่มเติม'),
                        ...application.additionalDocuments.map(
                          (doc) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.description),
                              title: Text(doc),
                              trailing: IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  // Note: Document download feature pending implementation
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'การดาวน์โหลดเอกสาร - เร็วๆ นี้',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Application timeline
                      _buildSectionTitle('ไทมไลน์การสมัคร'),
                      _buildTimelineCard(application),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Information from AssistantMiniResumeScreen
            if (profile['fullName'] != null &&
                profile['fullName'].toString().isNotEmpty)
              _buildProfileRow('ชื่อ-นามสกุล', profile['fullName']),
            if (profile['nickName'] != null &&
                profile['nickName'].toString().isNotEmpty)
              _buildProfileRow('ชื่อเล่น', profile['nickName']),
            if (profile['age'] != null)
              _buildProfileRow('อายุ', '${profile['age']} ปี'),
            if (profile['phoneNumber'] != null &&
                profile['phoneNumber'].toString().isNotEmpty)
              _buildProfileRow('เบอร์โทรศัพท์', profile['phoneNumber']),

            // Job Application Information from AssistantMiniResumeScreen
            if (profile['educationLevel'] != null)
              _buildProfileRow('วุฒิการศึกษา', profile['educationLevel']),
            if (profile['jobType'] != null)
              _buildProfileRow('ประเภทงานที่ต้องการ', profile['jobType']),
            if (profile['jobReadiness'] != null)
              _buildProfileRow(
                'ความพร้อมในการเริ่มงาน',
                profile['jobReadiness'],
              ),
            if (profile['minSalary'] != null ||
                profile['maxSalary'] != null) ...[
              () {
                String salaryRange = '';
                if (profile['minSalary'] != null &&
                    profile['maxSalary'] != null) {
                  salaryRange =
                      '${profile['minSalary']} - ${profile['maxSalary']} บาท/เดือน';
                } else if (profile['minSalary'] != null) {
                  salaryRange = '${profile['minSalary']} บาท/เดือนขึ้นไป';
                } else if (profile['maxSalary'] != null) {
                  salaryRange = 'ไม่เกิน ${profile['maxSalary']} บาท/เดือน';
                }
                return _buildProfileRow('เงินเดือนที่ต้องการ', salaryRange);
              }(),
            ],

            // Education and Experience from AssistantMiniResumeScreen
            if (profile['educationInstitute'] != null &&
                profile['educationInstitute'].toString().isNotEmpty)
              _buildProfileRow('สถาบันการศึกษา', profile['educationInstitute']),
            if (profile['experienceYears'] != null)
              _buildProfileRow(
                'ประสบการณ์',
                '${profile['experienceYears']} ปี',
              ),
            if (profile['educationSpecialist'] != null &&
                profile['educationSpecialist'].toString().isNotEmpty)
              _buildProfileRow('การศึกษาพิเศษ', profile['educationSpecialist']),

            // Skills from AssistantMiniResumeScreen
            if (profile['coreCompetencies'] != null &&
                (profile['coreCompetencies'] as List).isNotEmpty)
              _buildProfileRow(
                'ทักษะผู้ช่วยทันตแพทย์',
                (profile['coreCompetencies'] as List).join(', '),
              ),
            if (profile['counterSkills'] != null &&
                (profile['counterSkills'] as List).isNotEmpty)
              _buildProfileRow(
                'ทักษะเคาน์เตอร์',
                (profile['counterSkills'] as List).join(', '),
              ),
            if (profile['softwareSkills'] != null &&
                (profile['softwareSkills'] as List).isNotEmpty)
              _buildProfileRow(
                'ซอฟต์แวร์ที่ใช้ได้',
                (profile['softwareSkills'] as List).join(', '),
              ),
            if (profile['eqSkills'] != null &&
                (profile['eqSkills'] as List).isNotEmpty)
              _buildProfileRow(
                'ทักษะด้านอารมณ์และสังคม',
                (profile['eqSkills'] as List).join(', '),
              ),
            if (profile['workLimitations'] != null &&
                (profile['workLimitations'] as List).isNotEmpty)
              _buildProfileRow(
                'ข้อจำกัดในการทำงาน',
                (profile['workLimitations'] as List).join(', '),
              ),

            // Additional profile information
            if (profile['address'] != null &&
                profile['address'].toString().isNotEmpty)
              _buildProfileRow('ที่อยู่', profile['address']),
            if (profile['verificationStatus'] != null)
              _buildProfileRow(
                'สถานะการยืนยันตัวตน',
                _getVerificationStatusText(profile['verificationStatus']),
              ),

            // Legacy fields (for backward compatibility)
            if (profile['currentPosition'] != null)
              _buildProfileRow('ตำแหน่งปัจจุบัน', profile['currentPosition']),
            if (profile['yearsOfExperience'] != null &&
                profile['experienceYears'] == null)
              _buildProfileRow(
                'ประสบการณ์',
                '${profile['yearsOfExperience']} ปี',
              ),
            if (profile['skills'] != null &&
                (profile['skills'] as List).isNotEmpty &&
                profile['coreCompetencies'] == null)
              _buildProfileRow('ทักษะ', (profile['skills'] as List).join(', ')),
            if (profile['specialties'] != null &&
                (profile['specialties'] as List).isNotEmpty)
              _buildProfileRow(
                'ความเชี่ยวชาญ',
                (profile['specialties'] as List).join(', '),
              ),
            if (profile['education'] != null &&
                (profile['education'] as List).isNotEmpty)
              _buildProfileRow(
                'การศึกษา',
                '${(profile['education'] as List).length} รายการ',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  String _getVerificationStatusText(String status) {
    switch (status) {
      case 'unverified':
        return 'ยังไม่ยืนยันตัวตน';
      case 'pending':
        return 'รอการตรวจสอบ';
      case 'verified':
        return 'ยืนยันตัวตนแล้ว';
      case 'rejected':
        return 'การยืนยันถูกปฏิเสธ';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  Widget _buildVerificationStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'verified':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.verified;
        break;
      case 'pending':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.pending;
        break;
      case 'rejected':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[700]!;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            _getVerificationStatusText(status),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(JobApplicationModel application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimelineItem('สมัครเมื่อ', application.appliedAt, true),
            _buildTimelineItem('อัปเดตล่าสุด', application.updatedAt, false),
            if (application.interviewDate != null)
              _buildTimelineItem(
                'กำหนดการสัมภาษณ์',
                application.interviewDate!,
                false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date, bool isFirst) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isFirst ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            if (!isFirst)
              Container(width: 2, height: 20, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                _formatDate(date),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // List of valid application status values (English)
  List<String> get _applicationStatusValues => [
    'submitted',
    'under_review',
    'shortlisted',
    'interview_scheduled',
    'interview_completed',
    'offered',
    'hired',
    'rejected',
  ];

  void _showUpdateStatusDialog(JobApplicationModel application) {
    String selectedStatus = application.status;
    final notesController = TextEditingController(
      text: application.notes ?? '',
    );
    DateTime? interviewDate = application.interviewDate;
    final interviewLocationController = TextEditingController(
      text: application.interviewLocation ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('อัปเดตสถานะใบสมัคร'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ผู้สมัคร: ${application.applicantName}'),
                const SizedBox(height: 16),

                // Status dropdown - use English status values
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'สถานะ',
                    border: OutlineInputBorder(),
                  ),
                  items: _applicationStatusValues.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusDisplayName(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Interview fields (if interview status selected)
                if (selectedStatus == 'interview_scheduled') ...[
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            interviewDate ??
                            DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          interviewDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'วันที่สัมภาษณ์',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        interviewDate != null
                            ? _formatDate(interviewDate!)
                            : 'เลือกวันที่สัมภาษณ์',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: interviewLocationController,
                    decoration: const InputDecoration(
                      labelText: 'สถานที่สัมภาษณ์',
                      border: OutlineInputBorder(),
                      hintText: 'เช่น สำนักงานคลินิก, วิดีโอคอล',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes field
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'หมายเหตุ (ไม่บังคับ)',
                    border: OutlineInputBorder(),
                    hintText: 'เพิ่มบันทึกสำหรับผู้สมัคร...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => _updateApplicationStatus(
                application.applicationId,
                selectedStatus,
                notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
                interviewDate,
                interviewLocationController.text.trim().isEmpty
                    ? null
                    : interviewLocationController.text.trim(),
              ),
              child: const Text('อัปเดต'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateApplicationStatus(
    String applicationId,
    String newStatus,
    String? notes,
    DateTime? interviewDate,
    String? interviewLocation,
  ) async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    Navigator.pop(context); // Close dialog

    final success = await jobProvider.updateApplicationStatus(
      applicationId: applicationId,
      newStatus: newStatus,
      notes: notes,
      interviewDate: interviewDate,
      interviewLocation: interviewLocation,
    );

    if (success) {
      // Reload assistant applicants
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel != null) {
        await jobProvider.getAssistantApplicantsForMyJobs(
          authProvider.userModel!.userId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปเดตสถานะใบสมัครเรียบร้อยแล้ว!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jobProvider.error ?? 'อัปเดตสถานะไม่สำเร็จ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
