import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
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
      // Load user's applications and related data
      await Provider.of<JobProvider>(
        context,
        listen: false,
      ).loadUserApplications(authProvider.userModel!.userId);
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
