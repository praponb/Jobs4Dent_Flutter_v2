import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/assistant_job_model.dart';
import 'assistant_job_posting_screen.dart';

class MyPostedAssistantJobsScreen extends StatefulWidget {
  const MyPostedAssistantJobsScreen({super.key});

  @override
  State<MyPostedAssistantJobsScreen> createState() =>
      _MyPostedAssistantJobsScreenState();
}

class _MyPostedAssistantJobsScreenState
    extends State<MyPostedAssistantJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AssistantJobModel> _assistantJobs = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First try the query with orderBy
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection('job_posts_assistant')
            .where('clinicId', isEqualTo: authProvider.userModel!.userId)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (indexError) {
        debugPrint(
          'Index error, falling back to query without orderBy: $indexError',
        );
        // Fallback: Query without orderBy if index doesn't exist
        querySnapshot = await _firestore
            .collection('job_posts_assistant')
            .where('clinicId', isEqualTo: authProvider.userModel!.userId)
            .get();
      }

      final jobs = <AssistantJobModel>[];

      for (var doc in querySnapshot.docs) {
        try {
          final jobData = doc.data() as Map<String, dynamic>;
          // Add document ID to the data if it's missing
          jobData['jobId'] = jobData['jobId'] ?? doc.id;
          final job = AssistantJobModel.fromMap(jobData);
          jobs.add(job);
        } catch (parseError) {
          debugPrint('Error parsing job document ${doc.id}: $parseError');
          debugPrint('Document data: ${doc.data()}');
          // Continue with other documents instead of failing entirely
        }
      }

      // Sort jobs by createdAt if we used the fallback query
      if (querySnapshot.docs.isNotEmpty) {
        jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      setState(() {
        _assistantJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading assistant jobs: $e');
      setState(() {
        _error = 'เกิดข้อผิดพลาดในการโหลดงาน: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('งาน(ผู้ช่วย)ที่ประกาศทั้งหมด'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ทั้งหมด'),
            Tab(text: 'เปิดรับสมัคร'),
            Tab(text: 'ปิดรับสมัคร'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadJobs),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobsList(),
          _buildJobsList(statusFilter: 'active'),
          _buildJobsList(statusFilter: 'inactive'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AssistantJobPostingScreen(),
            ),
          ).then((_) => _loadJobs());
        },
        icon: const Icon(Icons.add),
        label: const Text('ประกาศงานใหม่'),
      ),
    );
  }

  Widget _buildJobsList({String? statusFilter}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'เกิดข้อผิดพลาดในการโหลดงาน',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadJobs, child: const Text('ลองใหม่')),
          ],
        ),
      );
    }

    List<AssistantJobModel> jobs = _assistantJobs;

    // Apply status filter
    if (statusFilter == 'active') {
      jobs = jobs.where((job) => job.isActive).toList();
    } else if (statusFilter == 'inactive') {
      jobs = jobs.where((job) => !job.isActive).toList();
    }

    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              statusFilter == null
                  ? 'ยังไม่มีงานที่ประกาศ'
                  : statusFilter == 'active'
                  ? 'ไม่มีงานที่เปิดรับสมัคร'
                  : 'ไม่มีงานที่ปิดรับสมัคร',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('สร้างประกาศงานแรกของคุณเพื่อเริ่มต้นการจ้างงาน'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssistantJobPostingScreen(),
                  ),
                ).then((_) => _loadJobs());
              },
              child: const Text('ประกาศงานใหม่'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(AssistantJobModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showJobDetails(job),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
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
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.clinicNameAndBranch,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(job),
                ],
              ),
              const SizedBox(height: 12),

              // Work type and skills info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: job.workType == 'Full-time'
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.workType,
                      style: TextStyle(
                        fontSize: 12,
                        color: job.workType == 'Full-time'
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w500,
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
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${job.skillAssistant.length} ทักษะ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Skills preview
              if (job.skillAssistant.isNotEmpty) ...[
                const Text(
                  'ทักษะที่ต้องการ:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      job.skillAssistant.take(3).map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }).toList()..addAll([
                        if (job.skillAssistant.length > 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${job.skillAssistant.length - 3}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ]),
                ),
                const SizedBox(height: 8),
              ],

              // Salary/Rate information
              if (job.workType == 'Part-time') ...[
                if (job.payPerDayPartTime != null ||
                    job.payPerHourPartTime != null)
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
              ] else ...[
                if (job.salaryFullTime != null)
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'เงินเดือน ${job.salaryFullTime} บาท',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
              ],

              const SizedBox(height: 12),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${job.applicationCount} ใบสมัคร',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    'โพสต์เมื่อ ${_dateFormat.format(job.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),

              // Action Buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AssistantJobPostingScreen(jobToEdit: job),
                          ),
                        ).then((_) => _loadJobs());
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('แก้ไข'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: job.applicationCount > 0
                          ? () {
                              // Navigate to assistant applicant management when implemented
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'ฟีเจอร์การจัดการผู้สมัครงานผู้ช่วยทันตแพทย์จะพัฒนาเพิ่มในอนาคต',
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.people, size: 16),
                      label: Text('ดูผู้สมัคร (${job.applicationCount})'),
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

  Widget _buildStatusChip(AssistantJobModel job) {
    Color chipBackgroundColor;
    Color chipTextColor;
    String chipText;

    if (!job.isActive) {
      chipBackgroundColor = Colors.grey.shade100;
      chipTextColor = Colors.grey.shade700;
      chipText = 'ปิด';
    } else {
      chipBackgroundColor = Colors.green.shade100;
      chipTextColor = Colors.green.shade700;
      chipText = 'เปิด';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipTextColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          color: chipTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
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

  void _showJobDetails(AssistantJobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'รายละเอียดงาน',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AssistantJobPostingScreen(jobToEdit: job),
                                ),
                              ).then((_) => _loadJobs());
                            },
                            icon: const Icon(Icons.edit),
                            tooltip: 'แก้ไข',
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title and Status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job.titlePost,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildStatusChip(job),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.clinicNameAndBranch,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Location Information
                          _buildDetailSection('ข้อมูลสถานที่', [
                            if (job.selectedProvinceZones != null)
                              _buildDetailRow(
                                'โซนที่ตั้ง',
                                job.selectedProvinceZones!,
                              ),
                            if (job.selectedLocationZones != null)
                              _buildDetailRow(
                                'จังหวัด/โซนในจังหวัด',
                                job.selectedLocationZones!,
                              ),
                            if (job.selectedTrainLine != null)
                              _buildDetailRow(
                                'รถไฟฟ้า',
                                job.selectedTrainLine!,
                              ),
                            if (job.selectedTrainStation != null)
                              _buildDetailRow(
                                'สถานีรถไฟฟ้า',
                                job.selectedTrainStation!,
                              ),
                          ]),

                          const SizedBox(height: 20),
                          // Job Details
                          _buildDetailSection('รายละเอียดงาน', [
                            _buildDetailRow('ประเภทงาน', job.workType),
                            _buildDetailRow(
                              'จำนวนทักษะที่ต้องการ',
                              '${job.skillAssistant.length} ทักษะ',
                            ),
                          ]),

                          // Skills
                          if (job.skillAssistant.isNotEmpty) ...[
                            const Text(
                              'ทักษะที่ต้องการ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: job.skillAssistant.map((skill) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    skill,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Work Details based on type
                          if (job.workType == 'Part-time') ...[
                            _buildDetailSection('ข้อมูลงาน Part-time', [
                              if (job.paymentTermPartTime != null)
                                _buildDetailRow(
                                  'เงื่อนไขการจ่าย',
                                  job.paymentTermPartTime!,
                                ),
                              if (job.payPerDayPartTime != null &&
                                  job.payPerDayPartTime!.isNotEmpty)
                                _buildDetailRow(
                                  'ค่าแรงต่อวัน',
                                  '${job.payPerDayPartTime} บาท',
                                ),
                              if (job.payPerHourPartTime != null &&
                                  job.payPerHourPartTime!.isNotEmpty)
                                _buildDetailRow(
                                  'ค่าแรงต่อชั่วโมง',
                                  '${job.payPerHourPartTime} บาท',
                                ),
                              if (job.workDayPartTime != null &&
                                  job.workDayPartTime!.isNotEmpty)
                                _buildDetailRow(
                                  'วันทำงาน',
                                  _formatWorkDays(job.workDayPartTime!),
                                ),
                            ]),
                          ] else ...[
                            _buildDetailSection('ข้อมูลงาน Full-time', [
                              if (job.salaryFullTime != null &&
                                  job.salaryFullTime!.isNotEmpty)
                                _buildDetailRow(
                                  'เงินเดือน',
                                  '${job.salaryFullTime} บาท',
                                ),
                              if (job.totalIncomeFullTime != null &&
                                  job.totalIncomeFullTime!.isNotEmpty)
                                _buildDetailRow(
                                  'รายได้รวม',
                                  '${job.totalIncomeFullTime} บาท',
                                ),
                              if (job.dayOffFullTime != null)
                                _buildDetailRow('วันหยุด', job.dayOffFullTime!),
                              if (job.workTimeStart != null &&
                                  job.workTimeEnd != null)
                                _buildDetailRow(
                                  'เวลาทำงาน',
                                  '${job.workTimeStart} - ${job.workTimeEnd}',
                                ),
                            ]),

                            if (job.perk != null && job.perk!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const Text(
                                'สวัสดิการและรายละเอียดเพิ่มเติม',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                job.perk!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ],

                          // Statistics
                          const SizedBox(height: 20),
                          _buildDetailSection('สถิติ', [
                            _buildDetailRow(
                              'จำนวนผู้สมัคร',
                              '${job.applicationCount} คน',
                            ),
                            _buildDetailRow(
                              'วันที่ประกาศ',
                              _dateFormat.format(job.createdAt),
                            ),
                            if (job.updatedAt != job.createdAt)
                              _buildDetailRow(
                                'แก้ไขล่าสุด',
                                _dateFormat.format(job.updatedAt),
                              ),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Actions
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AssistantJobPostingScreen(jobToEdit: job),
                              ),
                            ).then((_) => _loadJobs());
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('แก้ไขงาน'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: job.applicationCount > 0
                              ? () {
                                  Navigator.pop(context);
                                  // Navigate to assistant applicant management when implemented
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'ฟีเจอร์การจัดการผู้สมัครงานผู้ช่วยทันตแพทย์จะพัฒนาเพิ่มในอนาคต',
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.people),
                          label: Text('ดูผู้สมัคร (${job.applicationCount})'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 16),
      ],
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatWorkDays(List<DateTime> workDays) {
    if (workDays.isEmpty) return 'ไม่ระบุ';

    final sortedDays = List<DateTime>.from(workDays)..sort();
    final formattedDays = sortedDays.map((date) {
      return '${date.day}/${date.month}/${date.year}';
    }).toList();

    if (formattedDays.length <= 3) {
      return formattedDays.join(', ');
    } else {
      return '${formattedDays.take(3).join(', ')} และอีก ${formattedDays.length - 3} วัน';
    }
  }
}
