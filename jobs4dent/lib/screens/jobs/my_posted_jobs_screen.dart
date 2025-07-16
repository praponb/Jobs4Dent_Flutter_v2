import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_model.dart';
import 'job_posting_screen.dart';
import 'applicant_management_screen.dart';

class MyPostedJobsScreen extends StatefulWidget {
  const MyPostedJobsScreen({super.key});

  @override
  State<MyPostedJobsScreen> createState() => _MyPostedJobsScreenState();
}

class _MyPostedJobsScreenState extends State<MyPostedJobsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  
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
    if (authProvider.userModel != null) {
      await Provider.of<JobProvider>(context, listen: false)
          .loadMyPostedJobs(authProvider.userModel!.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('งานที่ประกาศทั้งหมด'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ทั้งหมด'),
            Tab(text: 'เปิดรับสมัคร'),
            Tab(text: 'ปิดรับสมัคร'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJobs,
          ),
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
              builder: (context) => const JobPostingScreen(),
            ),
          ).then((_) => _loadJobs());
        },
        icon: const Icon(Icons.add),
        label: const Text('ประกาศงานใหม่'),
      ),
    );
  }

  Widget _buildJobsList({String? statusFilter}) {
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
                  'เกิดข้อผิดพลาดในการโหลดงาน',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(jobProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadJobs,
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        List<JobModel> jobs = jobProvider.myPostedJobs;

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
                        builder: (context) => const JobPostingScreen(),
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
              return _buildJobCard(job, jobProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildJobCard(JobModel job, JobProvider jobProvider) {
    final applications = jobProvider.applicantsForMyJobs
        .where((app) => app.jobId == job.jobId)
        .toList();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showJobDetails(job, jobProvider),
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
                          job.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.jobCategory,
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

              // Location and Salary Info
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${job.city}, ${job.province}',
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (job.trainLine != null && job.trainStation != null) ...[
                Row(
                  children: [
                    Icon(Icons.train, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${job.trainLine} - ${job.trainStation}',
                        style: TextStyle(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (job.minSalary != null) ...[
                Row(
                  children: [
                    Icon(Icons.monetization_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'เงินเดือนขั้นต่ำ: ${_formatNumber(job.minSalary!)} บาท',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Experience and Salary Type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.experienceLevel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.salaryType,
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

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${applications.length} ใบสมัคร',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    'โพสต์เมื่อ ${_dateFormat.format(job.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
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
                            builder: (context) => JobPostingScreen(jobToEdit: job),
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
                      onPressed: applications.isNotEmpty ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApplicantManagementScreen(),
                          ),
                        );
                      } : null,
                      icon: const Icon(Icons.people, size: 16),
                      label: Text('ดูผู้สมัคร (${applications.length})'),
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

  Widget _buildStatusChip(JobModel job) {
    Color chipBackgroundColor;
    Color chipTextColor;
    String chipText;
    
    if (!job.isActive) {
      chipBackgroundColor = Colors.grey.shade100;
      chipTextColor = Colors.grey.shade700;
      chipText = 'ปิด';
    } else if (job.deadline != null && job.deadline!.isBefore(DateTime.now())) {
      chipBackgroundColor = Colors.orange.shade100;
      chipTextColor = Colors.orange.shade700;
      chipText = 'หมดเขต';
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

  String _formatNumber(double number) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(number);
  }

  void _showJobDetails(JobModel job, JobProvider jobProvider) {
    final applications = jobProvider.applicantsForMyJobs
        .where((app) => app.jobId == job.jobId)
        .toList();

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
                                  builder: (context) => JobPostingScreen(jobToEdit: job),
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
                                  job.title,
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
                            job.jobCategory,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Job Details
                          _buildDetailSection('รายละเอียดงาน', [
                            _buildDetailRow('ประสบการณ์', job.experienceLevel),
                            _buildDetailRow('ประเภทเงินเดือน', job.salaryType),
                            if (job.minSalary != null)
                              _buildDetailRow('เงินเดือนขั้นต่ำ', '${_formatNumber(job.minSalary!)} บาท'),
                            if (job.workingDays != null && job.workingDays!.isNotEmpty)
                              _buildDetailRow('วันทำงาน', job.workingDays!.join(', ')),
                            if (job.workingHours != null)
                              _buildDetailRow('เวลาทำงาน', job.workingHours!),
                            if (job.perks != null && job.perks!.isNotEmpty)
                              _buildDetailRow('สิทธิพิเศษ', job.perks!),
                          ]),

                          // Location Details
                          _buildDetailSection('สถานที่', [
                            _buildDetailRow('จังหวัด/โซน', job.province),
                            _buildDetailRow('พื้นที่', job.city),
                            if (job.trainLine != null && job.trainStation != null)
                              _buildDetailRow('รถไฟฟ้า', '${job.trainLine} - ${job.trainStation}'),
                          ]),

                          // Description
                          const SizedBox(height: 20),
                          const Text(
                            'รายละเอียดเพิ่มเติม',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            job.description,
                            style: const TextStyle(fontSize: 16),
                          ),

                          if (job.additionalRequirements != null && job.additionalRequirements!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text(
                              'ข้อกำหนดเพิ่มเติม',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              job.additionalRequirements!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],

                          // Statistics
                          const SizedBox(height: 20),
                          _buildDetailSection('สถิติ', [
                            _buildDetailRow('จำนวนผู้สมัคร', '${applications.length} คน'),
                            _buildDetailRow('วันที่ประกาศ', _dateFormat.format(job.createdAt)),
                            if (job.updatedAt != job.createdAt)
                              _buildDetailRow('แก้ไขล่าสุด', _dateFormat.format(job.updatedAt)),
                            if (job.deadline != null)
                              _buildDetailRow('กำหนดส่ง', _dateFormat.format(job.deadline!)),
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
                                builder: (context) => JobPostingScreen(jobToEdit: job),
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
                          onPressed: applications.isNotEmpty ? () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ApplicantManagementScreen(),
                              ),
                            );
                          } : null,
                          icon: const Icon(Icons.people),
                          label: Text('ดูผู้สมัคร (${applications.length})'),
                        ),
                      ),
                    ],
                  ),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
} 