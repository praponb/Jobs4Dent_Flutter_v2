import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';

import '../profile/profile_screen.dart';
import '../profile/sub_branch_management_screen.dart';
import 'dashboard_data_processor.dart';
import 'widgets/clinic_info_card.dart';
import 'widgets/dashboard_metrics.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_performance_chart.dart';
import 'widgets/dashboard_jobs_overview.dart';
import 'widgets/dashboard_recent_applications.dart';

class ClinicDashboard extends StatefulWidget {
  const ClinicDashboard({super.key});

  @override
  State<ClinicDashboard> createState() => _ClinicDashboardState();
}

class _ClinicDashboardState extends State<ClinicDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel != null) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      
      debugPrint('Clinic Dashboard: Loading data for user ${authProvider.userModel!.userId}');
      debugPrint('Clinic Dashboard: User type: ${authProvider.userModel!.userType}');
      
      // Load clinic's posted jobs (both dentist and assistant) and their applicants
      await Future.wait([
        jobProvider.loadMyPostedJobs(authProvider.userModel!.userId),
        jobProvider.loadMyPostedAssistantJobs(authProvider.userModel!.userId),
        jobProvider.loadApplicantsForMyJobs(authProvider.userModel!.userId),
      ]);
      
      debugPrint('Clinic Dashboard: Data loading completed');
      debugPrint('Clinic Dashboard: Assistant jobs count: ${jobProvider.myPostedAssistantJobs.length}');
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

          final metrics = DashboardDataProcessor.calculateMetrics(
            jobProvider.myPostedJobs,
            jobProvider.myPostedAssistantJobs,
            jobProvider.applicantsForMyJobs,
          );

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clinic Info Card
                  ClinicInfoCard(user: user),
                  const SizedBox(height: 24),

                  // Key Metrics
                  DashboardMetricsWidget(metrics: metrics),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const DashboardQuickActions(),
                  const SizedBox(height: 24),

                  // Job Posting Performance Chart
                  DashboardPerformanceChart(
                    applications: jobProvider.applicantsForMyJobs,
                  ),
                  const SizedBox(height: 24),

                  // Active Jobs Overview
                  DashboardJobsOverview(
                    jobs: jobProvider.myPostedJobs,
                    assistantJobs: jobProvider.myPostedAssistantJobs,
                    applications: jobProvider.applicantsForMyJobs,
                  ),
                  const SizedBox(height: 24),

                  // Recent Applications
                  DashboardRecentApplications(
                    applications: jobProvider.applicantsForMyJobs,
                  ),
                  const SizedBox(height: 24),

                  // Branch Management Section
                  _buildBranchManagement(user),
                ],
              ),
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //                     MaterialPageRoute(builder: (context) => const DentistJobPostingScreen()),
      //     );
      //   },
      //   icon: const Icon(Icons.add),
      //   label: const Text('ประกาศงาน'),
      //   backgroundColor: const Color(0xFF2196F3),
      // ),
    );
  }

  Widget _buildBranchManagement(user) {
    final branches = DashboardDataProcessor.getBranchesForOverview(user.branches);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'การจัดการสาขา',
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
                    builder: (context) => const SubBranchManagementScreen(),
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
                          builder: (context) => const SubBranchManagementScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
              if (branches.isNotEmpty) ...[
                const Divider(),
                ...branches.map((branch) => _buildBranchItem(branch)),
                if ((user.branches?.length ?? 0) > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${(user.branches?.length ?? 0) - 3} สาขาอื่นๆ',
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
} 