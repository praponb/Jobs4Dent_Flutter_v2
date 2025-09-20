import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_model.dart';
import '../../models/job_application_model.dart';

class DentistJobSearchScreen extends StatefulWidget {
  const DentistJobSearchScreen({super.key});

  @override
  State<DentistJobSearchScreen> createState() => _DentistJobSearchScreenState();
}

class _DentistJobSearchScreenState extends State<DentistJobSearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minExperienceYearsController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _trainLineController = TextEditingController();
  final TextEditingController _trainStationController = TextEditingController();
  final TextEditingController _workingDaysController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController();
  final TextEditingController _additionalRequirementsController =
      TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  String? _selectedCategory;
  String? _selectedExperienceLevel;
  String? _selectedSalaryType;
  String? _selectedPerks;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _locationController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _minExperienceYearsController.dispose();
    _cityController.dispose();
    _trainLineController.dispose();
    _trainStationController.dispose();
    _workingDaysController.dispose();
    _workingHoursController.dispose();
    _additionalRequirementsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _loadJobs() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<JobProvider>(
        context,
        listen: false,
      ).searchJobs(userId: authProvider.userModel?.userId);
    });
  }

  void _searchJobs() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    jobProvider.searchJobs(
      keyword: _keywordController.text.trim().isEmpty
          ? null
          : _keywordController.text.trim(),
      jobCategory: _selectedCategory,
      experienceLevel: _selectedExperienceLevel,
      province: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      minSalary: _minSalaryController.text.trim().isEmpty
          ? null
          : _minSalaryController.text.trim(),
      userId: authProvider.userModel?.userId,
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      minExperienceYears: _minExperienceYearsController.text.trim().isEmpty
          ? null
          : _minExperienceYearsController.text.trim(),
      salaryType: _selectedSalaryType,
      perks: _selectedPerks,
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      trainLine: _trainLineController.text.trim().isEmpty
          ? null
          : _trainLineController.text.trim(),
      trainStation: _trainStationController.text.trim().isEmpty
          ? null
          : _trainStationController.text.trim(),
      workingDays: _workingDaysController.text.trim().isEmpty
          ? null
          : _workingDaysController.text.trim(),
      workingHours: _workingHoursController.text.trim().isEmpty
          ? null
          : _workingHoursController.text.trim(),
      additionalRequirements:
          _additionalRequirementsController.text.trim().isEmpty
          ? null
          : _additionalRequirementsController.text.trim(),
      startDate: _startDateController.text.trim().isEmpty
          ? null
          : _startDateController.text.trim(),
      endDate: _endDateController.text.trim().isEmpty
          ? null
          : _endDateController.text.trim(),
      //isActive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ค้นหางานทันตแพทย์'), actions: []),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _keywordController,
                        decoration: const InputDecoration(
                          hintText: 'ค้นหาชื่องาน หรือคำอธิบาย...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _searchJobs(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchJobs,
                      child: const Text('ค้นหา'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Search Criteria Display
          Consumer<JobProvider>(
            builder: (context, jobProvider, child) {
              final searchCriteria = jobProvider.getFormattedSearchCriteria();
              if (searchCriteria.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'เงื่อนไขการค้นหา',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: searchCriteria.map((criteria) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade300),
                          ),
                          child: Text(
                            criteria,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),

          // Results
          Expanded(
            child: Consumer<JobProvider>(
              builder: (context, jobProvider, child) {
                if (jobProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (jobProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          jobProvider.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadJobs,
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  );
                }

                if (jobProvider.jobs.isEmpty) {
                  return const Center(child: Text('ไม่พบงานที่ค้นหา'));
                }

                return ListView.builder(
                  itemCount: jobProvider.jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobProvider.jobs[index];
                    return _buildJobCard(job);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showJobDetails(job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showReportDialog(job),
                    icon: const Icon(Icons.flag_outlined, size: 20),
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.clinicName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.jobCategory,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${job.city}, ${job.province}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (job.minSalary != null)
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatSalary(job),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job.experienceLevel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job.salaryType,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'โพสต์เมื่อ ${_formatDate(job.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${job.applicationCount} ใบสมัคร',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSalary(JobModel job) {
    if (job.minSalary != null && job.minSalary!.isNotEmpty) {
      final salary = double.tryParse(job.minSalary!);
      if (salary != null) {
        return 'เริ่มต้น ${_formatNumber(salary)} บาท';
      }
    }
    return 'ตามตกลง';
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เพิ่งโพสต์';
    }
  }

  void _showJobDetails(JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: const Text('รายละเอียดงาน'),
            ),
            leading: const SizedBox(), // Remove default back button
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
            elevation: 1,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.clinicName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildDetailRow('หมวดหมู่', job.jobCategory),
                        _buildDetailRow('ประสบการณ์', job.experienceLevel),
                        _buildDetailRow('ประเภทเงินเดือน', job.salaryType),
                        if (job.minSalary != null)
                          _buildDetailRow('เงินเดือน', _formatSalary(job)),
                        _buildDetailRow(
                          'สถานที่',
                          '${job.city}, ${job.province}',
                        ),
                        if (job.trainLine != null && job.trainStation != null)
                          _buildDetailRow(
                            'รถไฟฟ้า',
                            '${job.trainLine} - ${job.trainStation}',
                          ),
                        if (job.workingDays != null &&
                            job.workingDays!.isNotEmpty)
                          _buildDetailRow('วันทำงาน', job.workingDays!),
                        if (job.workingHours != null)
                          _buildDetailRow('เวลาทำงาน', job.workingHours!),
                        if (job.perks != null && job.perks!.isNotEmpty)
                          _buildDetailRow('สิทธิพิเศษ', job.perks!),

                        const SizedBox(height: 16),
                        const Text(
                          'รายละเอียดงาน',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.description,
                          style: const TextStyle(fontSize: 14),
                        ),

                        if (job.additionalRequirements != null &&
                            job.additionalRequirements!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'ข้อกำหนดเพิ่มเติม',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.additionalRequirements!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],

                        const SizedBox(height: 16),
                        Row(children: [
                          ],
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'โพสต์เมื่อ ${_formatDate(job.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyForJob(job);
                      },
                      child: const Text('สมัครงาน'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  void _showReportDialog(JobModel job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('รายงานโพสต์งาน'),
          content: const Text(
            'คุณต้องการรายงานโพสต์งานนี้ว่าไม่เหมาะสมหรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _reportJob(job);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('รายงาน'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reportJob(JobModel job) async {
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.reportJob(job.jobId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รายงานโพสต์งานเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error reporting job: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการรายงาน'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _applyForJob(JobModel job) async {
    debugPrint('=== STARTING JOB APPLICATION PROCESS ===');
    debugPrint('Job ID: ${job.jobId}');
    debugPrint('Job Title: ${job.title}');
    debugPrint('Job Clinic: ${job.clinicName}');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userModel == null) {
      debugPrint('ERROR: User not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนสมัครงาน')),
      );
      return;
    }

    debugPrint('User authenticated: ${authProvider.userModel!.userId}');

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Add timeout to prevent hanging
      await Future.any([
        _processJobApplication(job, authProvider.userModel!),
        Future.delayed(const Duration(seconds: 30), () {
          throw Exception('timeout');
        }),
      ]);
    } catch (e) {
      debugPrint('=== ERROR IN JOB APPLICATION ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        String errorMessage = 'เกิดข้อผิดพลาดในการสมัครงาน';

        // Provide more specific error messages based on the error type
        if (e.toString().contains('not-found')) {
          errorMessage = 'ไม่พบข้อมูลงานหรือผู้ใช้ กรุณาลองใหม่อีกครั้ง';
        } else if (e.toString().contains('permission-denied')) {
          errorMessage = 'ไม่มีสิทธิ์ในการสมัครงาน กรุณาติดต่อผู้ดูแลระบบ';
        } else if (e.toString().contains('network')) {
          errorMessage = 'เกิดปัญหาการเชื่อมต่อ กรุณาตรวจสอบอินเทอร์เน็ต';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'การเชื่อมต่อใช้เวลานานเกินไป กรุณาลองใหม่อีกครั้ง';
        } else {
          // Show the actual error message for debugging
          errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'ลองใหม่',
              textColor: Colors.white,
              onPressed: () => _applyForJob(job),
            ),
          ),
        );
      }
      debugPrint('=== END ERROR HANDLING ===');
    }
  }

  Future<void> _processJobApplication(JobModel job, user) async {
    try {
      final now = DateTime.now();

      debugPrint('Processing job application for jobId: ${job.jobId}');
      debugPrint('Job title: ${job.title}');
      debugPrint('Job clinic: ${job.clinicName}');

      // Skip job validation for now - trust the job data we already have
      // The job was loaded successfully from the search results, so it should exist
      debugPrint(
        'Skipping job validation - using job data from search results',
      );
      debugPrint('Job isActive from search results: ${job.isActive}');

      // Only check if job is active from the loaded data
      if (!job.isActive) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('งานนี้ไม่เปิดรับสมัครแล้ว'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Check if already applied
      final existingApplication = await _firestore
          .collection('job_applications_dentist')
          .where('jobId', isEqualTo: job.jobId)
          .where('applicantId', isEqualTo: user.userId)
          .limit(1)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('คุณได้สมัครงานนี้แล้ว'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Fetch additional user data from 'users' collection with proper error handling
      Map<String, dynamic> userData = {};
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.userId)
            .get();

        if (userDoc.exists) {
          userData = userDoc.data() as Map<String, dynamic>;
          debugPrint(
            'Fetched user data from users collection: ${userData.keys.toList()}',
          );
        } else {
          debugPrint(
            'User document not found in users collection, using auth data only',
          );
          // Use basic user data from auth provider if user document doesn't exist
          userData = {
            'fullName': user.userName,
            'nickName': '',
            'age': null,
            'educationInstitute': '',
            'experienceYears': 0,
            'educationSpecialist': '',
            'coreCompetencies': [],
            'workLimitations': [],
            'verificationStatus': 'unverified',
            'isProfileComplete': false,
          };
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        // Fallback to basic user data from auth provider
        userData = {
          'fullName': user.userName,
          'nickName': '',
          'age': null,
          'educationInstitute': '',
          'experienceYears': 0,
          'educationSpecialist': '',
          'coreCompetencies': [],
          'workLimitations': [],
          'verificationStatus': 'unverified',
          'isProfileComplete': false,
        };
      }

      // Create application ID
      final applicationId = _firestore
          .collection('job_applications_dentist')
          .doc()
          .id;

      // Create comprehensive applicant profile with data from DentistMiniResumeScreen
      final applicantProfile = {
        // Basic user information
        'userName': user.userName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'profilePhotoUrl': user.profilePhotoUrl,
        'userType': user.userType,

        // Personal Information from DentistMiniResumeScreen
        'fullName': userData['fullName'] ?? '',
        'nickName': userData['nickName'] ?? '',
        'age': userData['age'],

        // Education and Experience from DentistMiniResumeScreen
        'educationInstitute': userData['educationInstitute'] ?? '',
        'experienceYears': userData['experienceYears'] ?? 0,
        'educationSpecialist': userData['educationSpecialist'] ?? '',

        // Skills from DentistMiniResumeScreen
        'coreCompetencies': userData['coreCompetencies'] ?? [],
        'workLimitations': userData['workLimitations'] ?? [],

        // Additional profile information
        'verificationStatus': userData['verificationStatus'] ?? 'unverified',
        'isProfileComplete': userData['isProfileComplete'] ?? false,
      };

      // Create job application
      final application = JobApplicationModel(
        applicationId: applicationId,
        jobId: job.jobId,
        applicantId: user.userId,
        clinicId: job.clinicId,
        applicantName: userData['fullName']?.toString() ?? user.userName,
        applicantEmail: user.email,
        applicantPhone: user.phoneNumber,
        applicantProfilePhoto: user.profilePhotoUrl,
        coverLetter: 'สมัครงานตำแหน่ง ${job.title} ที่ ${job.clinicName}',
        additionalDocuments: const [],
        status: 'submitted',
        appliedAt: now,
        updatedAt: now,
        notes: null,
        interviewDate: null,
        interviewLocation: null,
        interviewNotes: null,
        matchingScore: null,
        applicantProfile: applicantProfile,
        jobTitle: job.title,
        clinicName: job.clinicName,
      );

      // Save to Firestore
      await _firestore
          .collection('job_applications_dentist')
          .doc(applicationId)
          .set(application.toMap());

      // Update job's application count - try direct update first, then fallback
      try {
        await _firestore.collection('job_posts_dentist').doc(job.jobId).update({
          'applicationCount': FieldValue.increment(1),
          'applicationIds': FieldValue.arrayUnion([applicationId]),
          'updatedAt': now.millisecondsSinceEpoch,
        });
        debugPrint('Successfully updated job application count by document ID');
      } catch (e) {
        debugPrint('Error updating job by document ID, trying by query: $e');
        try {
          // Fallback: find the job document and update it
          final querySnapshot = await _firestore
              .collection('job_posts_dentist')
              .where('jobId', isEqualTo: job.jobId)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            await querySnapshot.docs.first.reference.update({
              'applicationCount': FieldValue.increment(1),
              'applicationIds': FieldValue.arrayUnion([applicationId]),
              'updatedAt': now.millisecondsSinceEpoch,
            });
            debugPrint('Successfully updated job application count by query');
          } else {
            debugPrint(
              'Warning: Could not find job to update application count',
            );
          }
        } catch (fallbackError) {
          debugPrint('Error in fallback job update: $fallbackError');
          // Don't fail the application if we can't update the count
        }
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สมัครงาน ${job.title} สำเร็จแล้ว!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(label: 'ปิด', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in _processJobApplication: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'ลองใหม่',
              textColor: Colors.white,
              onPressed: () => _applyForJob(job),
            ),
          ),
        );
      }
      rethrow; // Re-throw to be caught by the outer try-catch
    }
  }
}
