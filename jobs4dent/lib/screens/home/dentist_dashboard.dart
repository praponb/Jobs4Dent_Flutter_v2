import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../models/job_application_model.dart';
import '../../models/job_model.dart';
import '../profile/profile_screen.dart';
import 'dentist_data_processor.dart';
import 'widgets/dentist_welcome_card.dart';
import 'widgets/dentist_quick_stats.dart';
import 'widgets/dentist_quick_actions.dart';
import 'widgets/dentist_upcoming_appointments.dart';
import 'widgets/dentist_recent_applications.dart';
import 'widgets/dentist_availability_section.dart';

class DentistDashboard extends StatefulWidget {
  const DentistDashboard({super.key});

  @override
  State<DentistDashboard> createState() => _DentistDashboardState();
}

class _DentistDashboardState extends State<DentistDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, JobModel> _jobDetails = {};

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
      // Load user's dentist applications and related data
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.getMyDentistApplications(
        authProvider.userModel!.userId,
      );

      // Load job details for applications
      await _loadJobDetails(jobProvider.myApplications);
    }
  }

  Future<void> _loadJobDetails(List<JobApplicationModel> applications) async {
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
                  DentistWelcomeCard(user: user),
                  const SizedBox(height: 24),

                  // Quick Stats
                  DentistQuickStatsWidget(stats: stats),
                  const SizedBox(height: 24),

                  // Quick Actions
                  DentistQuickActions(
                    onAvailabilityTap: () => _showAvailabilityDialog(),
                  ),
                  const SizedBox(height: 24),

                  // Upcoming Appointments/Interviews
                  DentistUpcomingAppointments(
                    upcomingInterviews: upcomingInterviews,
                  ),
                  const SizedBox(height: 24),

                  // Recent Applications
                  DentistRecentApplications(
                    recentApplications: recentApplications,
                    jobDetails: _jobDetails,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAvailabilityDialog() {
    AvailabilityDialog.show(context);
  }
}
