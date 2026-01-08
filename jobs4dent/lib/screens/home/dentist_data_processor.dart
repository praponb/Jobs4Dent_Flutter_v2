import '../../models/job_application_model.dart';

/// Data processor for dentist dashboard metrics and data
class DentistDataProcessor {
  /// Calculate quick stats from user applications
  static DentistQuickStats calculateQuickStats(
    List<JobApplicationModel> applications,
  ) {
    final totalApplications = applications.length;
    final interviewsScheduled = applications.where((app) => 
        app.status == 'interview_scheduled').length;
    final offersReceived = applications.where((app) => 
        app.status == 'offer_made').length;
    final hired = applications.where((app) => 
        app.status == 'hired').length;

    return DentistQuickStats(
      totalApplications: totalApplications,
      interviewsScheduled: interviewsScheduled,
      offersReceived: offersReceived,
      hired: hired,
    );
  }

  /// Get upcoming interviews (scheduled interviews with future dates)
  static List<JobApplicationModel> getUpcomingInterviews(
    List<JobApplicationModel> applications,
    {int limit = 3}
  ) {
    final upcomingInterviews = applications
        .where((app) => app.status == 'interview_scheduled' && 
                       app.interviewDate != null &&
                       app.interviewDate!.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.interviewDate!.compareTo(b.interviewDate!));

    return upcomingInterviews.take(limit).toList();
  }

  /// Get recent applications within specified days
  static List<JobApplicationModel> getRecentApplications(
    List<JobApplicationModel> applications,
    {int daysBack = 30, int limit = 3}
  ) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
    final recentApplications = applications
        .where((app) => app.appliedAt.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

    return recentApplications.take(limit).toList();
  }

  /// Check if user has upcoming interviews
  static bool hasUpcomingInterviews(List<JobApplicationModel> applications) {
    return applications.any((app) => 
        app.status == 'interview_scheduled' && 
        app.interviewDate != null &&
        app.interviewDate!.isAfter(DateTime.now()));
  }

  /// Get applications by status
  static List<JobApplicationModel> getApplicationsByStatus(
    List<JobApplicationModel> applications,
    String status,
  ) {
    return applications.where((app) => app.status == status).toList();
  }

  /// Get application statistics for charts or analytics
  static Map<String, int> getApplicationStatusCounts(
    List<JobApplicationModel> applications,
  ) {
    final statusCounts = <String, int>{};
    
    for (var app in applications) {
      statusCounts[app.status] = (statusCounts[app.status] ?? 0) + 1;
    }
    
    return statusCounts;
  }

  /// Calculate success rate (hired / total applications)
  static double getSuccessRate(List<JobApplicationModel> applications) {
    if (applications.isEmpty) return 0.0;
    
    final hiredCount = applications.where((app) => app.status == 'hired').length;
    return (hiredCount / applications.length) * 100;
  }

  /// Get applications grouped by month for trend analysis
  static Map<int, int> getMonthlyApplicationTrend(
    List<JobApplicationModel> applications,
  ) {
    final monthlyData = <int, int>{};
    
    for (var app in applications) {
      final month = app.appliedAt.month;
      monthlyData[month] = (monthlyData[month] ?? 0) + 1;
    }
    
    return monthlyData;
  }
}

/// Data class for dentist quick stats
class DentistQuickStats {
  final int totalApplications;
  final int interviewsScheduled;
  final int offersReceived;
  final int hired;

  const DentistQuickStats({
    required this.totalApplications,
    required this.interviewsScheduled,
    required this.offersReceived,
    required this.hired,
  });

  /// Calculate success rate as percentage
  double get successRate {
    if (totalApplications == 0) return 0.0;
    return (hired / totalApplications) * 100;
  }

  /// Check if user has any activity
  bool get hasActivity {
    return totalApplications > 0;
  }
} 