import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../models/job_model.dart';
import '../../models/job_application_model.dart';
import '../jobs/job_posting_screen.dart';
import '../jobs/applicant_management_screen.dart';
import '../jobs/my_posted_jobs_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/sub_user_management_screen.dart';

class ClinicDashboard extends StatefulWidget {
  const ClinicDashboard({super.key});

  @override
  State<ClinicDashboard> createState() => _ClinicDashboardState();
}

class _ClinicDashboardState extends State<ClinicDashboard> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel != null) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await Future.wait([
        jobProvider.loadMyPostedJobs(authProvider.userModel!.userId),
        jobProvider.loadApplicantsForMyJobs(authProvider.userModel!.userId),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('แดชบอร์ดคลินิก'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Note: Notifications feature pending implementation
            },
          ),
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

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clinic Info Card
                  _buildClinicInfoCard(user),
                  const SizedBox(height: 24),

                  // Key Metrics
                  _buildKeyMetrics(jobProvider),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Job Posting Performance Chart
                  _buildPerformanceChart(jobProvider),
                  const SizedBox(height: 24),

                  // Active Jobs Overview
                  _buildActiveJobsOverview(jobProvider),
                  const SizedBox(height: 24),

                  // Recent Applications
                  _buildRecentApplications(jobProvider),
                  const SizedBox(height: 24),

                  // Branch Management Section
                  _buildBranchManagement(user),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JobPostingScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('ประกาศงาน'),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildClinicInfoCard(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.clinicName ?? 'คลินิกของคุณ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.userType == 'clinic' ? 'คลินิกหลัก' : 'สาขาคลินิก',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.address ?? 'จัดการคลินิกของคุณและค้นหาผู้เชี่ยวชาญทันตกรรมที่ดีที่สุด',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          if (user.branches?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              '${user.branches!.length} สาขา',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(JobProvider jobProvider) {
    final jobs = jobProvider.myPostedJobs;
    final applications = jobProvider.applicantsForMyJobs;
    
    final activeJobs = jobs.where((job) => job.isActive).length;
    final expiredJobs = jobs.where((job) => 
        job.deadline != null && job.deadline!.isBefore(DateTime.now())).length;
    final filledJobs = jobs.where((job) => 
        applications.any((app) => app.jobId == job.jobId && app.status == 'hired')).length;
    final totalApplications = applications.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ตัวชี้วัดหลัก',
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
              child: _buildMetricCard(
                title: 'งานที่เปิดรับ',
                value: activeJobs.toString(),
                icon: Icons.work,
                color: Colors.green,
                subtitle: 'กำลังรับสมัคร',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'ใบสมัคร',
                value: totalApplications.toString(),
                icon: Icons.people,
                color: Colors.orange,
                subtitle: 'รวมที่ได้รับ',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'จ้างงานแล้ว',
                value: filledJobs.toString(),
                icon: Icons.check_circle,
                color: Colors.blue,
                subtitle: 'จ้างงานสำเร็จ',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'หมดอายุ',
                value: expiredJobs.toString(),
                icon: Icons.schedule,
                color: Colors.red,
                subtitle: 'เลยกำหนด',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
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
                title: 'ประกาศงานใหม่',
                subtitle: 'หาผู้เชี่ยวชาญทันตกรรม',
                icon: Icons.add_circle,
                color: const Color(0xFF2196F3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JobPostingScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'ดูใบสมัคร',
                subtitle: 'ตรวจสอบผู้สมัคร',
                icon: Icons.inbox,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ApplicantManagementScreen()),
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
                title: 'จัดการสาขา',
                subtitle: 'Sub-users & permissions',
                icon: Icons.account_tree,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubUserManagementScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'ตลาดซื้อขาย',
                subtitle: 'ซื้อ/ขายสินค้า',
                icon: Icons.store,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
                  );
                },
              ),
            ),
          ],
        ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(JobProvider jobProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ประสิทธิภาพการประกาศงาน',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showDetailedAnalytics();
                },
                child: const Text('ดูรายละเอียด'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildJobsChart(jobProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsChart(JobProvider jobProvider) {
    final applications = jobProvider.applicantsForMyJobs;
    
    // Group applications by month
    final Map<int, int> monthlyApplications = {};
    for (var app in applications) {
      final month = app.appliedAt.month;
      monthlyApplications[month] = (monthlyApplications[month] ?? 0) + 1;
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(months[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(12, (index) {
              return FlSpot(
                index.toDouble(),
                (monthlyApplications[index + 1] ?? 0).toDouble(),
              );
            }),
            isCurved: true,
            color: const Color(0xFF2196F3),
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobsOverview(JobProvider jobProvider) {
    final activeJobs = jobProvider.myPostedJobs
        .where((job) => job.isActive)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'ประกาศงานที่เปิดอยู่',
                style: const TextStyle(
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
                    builder: (context) => const MyPostedJobsScreen(),
                  ),
                );
              },
              child: const Text('ดูทั้งหมด'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (activeJobs.isEmpty)
          Container(
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
                        builder: (context) => const JobPostingScreen(),
                      ),
                    );
                  },
                  child: const Text('ประกาศหางาน'),
                ),
              ],
            ),
          )
        else
          ...activeJobs.map((job) => _buildJobCard(job, jobProvider)),
      ],
    );
  }

  Widget _buildJobCard(JobModel job, JobProvider jobProvider) {
    final applications = jobProvider.applicantsForMyJobs
        .where((app) => app.jobId == job.jobId)
        .toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
                '${applications.length} ใบสมัคร',
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
                  'กำหนดส่ง: ${_dateFormat.format(job.deadline!)}',
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentApplications(JobProvider jobProvider) {
    final recentApplications = jobProvider.applicantsForMyJobs
        .where((app) => app.appliedAt.isAfter(
            DateTime.now().subtract(const Duration(days: 7))))
        .take(5)
        .toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'ใบสมัครล่าสุด',
                style: const TextStyle(
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
          Container(
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
          )
        else
          ...recentApplications.map((application) => 
            _buildApplicationCard(application)),
      ],
    );
  }

  Widget _buildApplicationCard(JobApplicationModel application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  'สมัครเมื่อ ${_getTimeAgo(application.appliedAt)}',
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
              color: _getStatusColor(application.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusDisplayName(application.status),
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(application.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchManagement(user) {
    final branches = user.branches ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'การจัดการสาขา',
                style: const TextStyle(
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
                    builder: (context) => const SubUserManagementScreen(),
                  ),
                );
              },
              child: const Text('จัดการ'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.account_tree, color: Colors.blue[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sub-Users & Branches',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          branches.isEmpty 
                              ? 'ยังไม่ได้ตั้งค่าสาขา'
                              : '${branches.length} สาขาเปิดใช้งาน',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubUserManagementScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
              if (branches.isNotEmpty) ...[
                const Divider(),
                ...branches.take(3).map((branch) => 
                  _buildBranchItem(branch)),
                if (branches.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${branches.length - 3} สาขาอื่นๆ',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBranchItem(Map<String, dynamic> branch) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.location_city, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              branch['name'] ?? 'สาขา',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'เปิดใช้งาน',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายงานวิเคราะห์โดยละเอียด'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                    Text('ฟังก์ชันการวิเคราะห์แบบละเอียดจะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
        SizedBox(height: 16),
        Text('ฟีเจอร์ที่จะรวม:'),
                    Text('• แนวโน้มการสมัครงานรายเดือน'),
        Text('• ประสิทธิภาพตามหมวดหมู่งาน'),
        Text('• อัตราการจ้างงานที่สำเร็จ'),
        Text('• ตัวชี้วัดเวลาในการจ้างงาน'),
        Text('• การวิเคราะห์แหล่งที่มาของผู้สมัคร'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Colors.blue;
      case 'under_review':
        return Colors.orange;
      case 'interview_scheduled':
        return Colors.purple;
      case 'offer_made':
        return Colors.green;
      case 'hired':
        return Colors.teal;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'submitted':
        return 'ใหม่';
      case 'under_review':
        return 'กำลังพิจารณา';
      case 'interview_scheduled':
        return 'นัดสัมภาษณ์';
      case 'offer_made':
        return 'ให้ข้อเสนอแล้ว';
      case 'hired':
        return 'จ้างแล้ว';
      case 'rejected':
        return 'ปฏิเสธ';
      default:
        return 'ไม่ทราบ';
    }
  }

    String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 7) {
      return _dateFormat.format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }
} 