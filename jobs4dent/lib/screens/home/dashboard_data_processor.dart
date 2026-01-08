import '../../models/job_model.dart';
import '../../models/assistant_job_model.dart';
import '../../models/job_application_model.dart';

/// Data processor for dashboard metrics and charts
class DashboardDataProcessor {
  /// Calculate key metrics from jobs and applications
  static DashboardMetrics calculateMetrics(
    List<JobModel> dentistJobs,
    List<AssistantJobModel> assistantJobs,
    List<JobApplicationModel> applications,
  ) {
    final activeDentistJobs = dentistJobs.where((job) => job.isActive).length;
    final activeAssistantJobs = assistantJobs
        .where((job) => job.isActive)
        .length;
    final activeJobs = activeDentistJobs + activeAssistantJobs;

    // Expired is based on dentist jobs only (assistant jobs have no deadline field)
    final expiredJobs = dentistJobs
        .where(
          (job) =>
              job.deadline != null && job.deadline!.isBefore(DateTime.now()),
        )
        .length;

    // Filled jobs = jobs (dentist + assistant) with at least one 'hired' application
    final filledDentistJobs = dentistJobs
        .where(
          (job) => applications.any(
            (app) => app.jobId == job.jobId && app.status == 'hired',
          ),
        )
        .length;
    final filledAssistantJobs = assistantJobs
        .where(
          (job) => applications.any(
            (app) => app.jobId == job.jobId && app.status == 'hired',
          ),
        )
        .length;
    final filledJobs = filledDentistJobs + filledAssistantJobs;

    final totalApplications = applications.length;

    return DashboardMetrics(
      activeJobs: activeJobs,
      totalApplications: totalApplications,
      filledJobs: filledJobs,
      expiredJobs: expiredJobs,
    );
  }

  /// Get applications for a specific job
  static List<JobApplicationModel> getApplicationsForJob(
    String jobId,
    List<JobApplicationModel> applications,
  ) {
    return applications.where((app) => app.jobId == jobId).toList();
  }

  /// Get recent applications within specified days
  static List<JobApplicationModel> getRecentApplications(
    List<JobApplicationModel> applications, {
    int daysBack = 7,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
    return applications
        .where((app) => app.appliedAt.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
  }

  /// Get active jobs (limited number for overview)
  static List<JobModel> getActiveJobsForOverview(
    List<JobModel> jobs, {
    int limit = 3,
  }) {
    return jobs.where((job) => job.isActive).take(limit).toList();
  }

  /// Get active assistant jobs (limited number for overview)
  static List<AssistantJobModel> getActiveAssistantJobsForOverview(
    List<AssistantJobModel> assistantJobs, {
    int limit = 3,
  }) {
    final activeJobs = assistantJobs
        .where((job) => job.isActive)
        .take(limit)
        .toList();
    return activeJobs;
  }

  /// Get applications for a specific assistant job
  static List<JobApplicationModel> getApplicationsForAssistantJob(
    String jobId,
    List<JobApplicationModel> applications,
  ) {
    return applications.where((app) => app.jobId == jobId).toList();
  }

  /// Process monthly applications data for chart
  static Map<int, int> getMonthlyApplicationsData(
    List<JobApplicationModel> applications,
  ) {
    final Map<int, int> monthlyData = {};

    for (var app in applications) {
      final month = app.appliedAt.month;
      monthlyData[month] = (monthlyData[month] ?? 0) + 1;
    }

    return monthlyData;
  }

  /// Get chart data points for applications chart (12 months)
  static List<ChartDataPoint> getApplicationsChartData(
    List<JobApplicationModel> applications,
  ) {
    final monthlyData = getMonthlyApplicationsData(applications);

    return List.generate(12, (index) {
      return ChartDataPoint(
        x: index.toDouble(),
        y: (monthlyData[index + 1] ?? 0).toDouble(),
      );
    });
  }

  /// Get limited branches for overview display
  static List<Map<String, dynamic>> getBranchesForOverview(
    List<Map<String, dynamic>>? branches, {
    int limit = 3,
  }) {
    if (branches == null || branches.isEmpty) return [];
    return branches.take(limit).toList();
  }
}

/// Data class for dashboard metrics
class DashboardMetrics {
  final int activeJobs;
  final int totalApplications;
  final int filledJobs;
  final int expiredJobs;

  const DashboardMetrics({
    required this.activeJobs,
    required this.totalApplications,
    required this.filledJobs,
    required this.expiredJobs,
  });
}

/// Data class for chart data points
class ChartDataPoint {
  final double x;
  final double y;

  const ChartDataPoint({required this.x, required this.y});
}
