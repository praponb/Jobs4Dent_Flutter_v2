import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/assistant_job_model.dart';
import '../models/job_application_model.dart';
import 'job_constants.dart';
import 'job_management_service.dart';
import 'job_search_service.dart';
import 'job_application_service.dart';
import 'job_ai_service.dart';

class JobProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Services
  final JobManagementService _jobManagementService = JobManagementService();
  final JobSearchService _jobSearchService = JobSearchService();
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final JobAIService _jobAIService = JobAIService();
  
  List<JobModel> _jobs = [];
  List<JobModel> _myPostedJobs = [];
  List<AssistantJobModel> _myPostedAssistantJobs = [];
  List<JobApplicationModel> _myApplications = [];
  List<JobApplicationModel> _applicantsForMyJobs = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _lastSearchCriteria;
  Map<String, dynamic>? _savedAdvancedSearchState;

  // Getters
  List<JobModel> get jobs => _jobs;
  List<JobModel> get myPostedJobs => _myPostedJobs;
  List<AssistantJobModel> get myPostedAssistantJobs => _myPostedAssistantJobs;
  List<JobApplicationModel> get myApplications => _myApplications;
  List<JobApplicationModel> get userApplications => _myApplications; // Alias for dashboard
  List<JobApplicationModel> get applicantsForMyJobs => _applicantsForMyJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get lastSearchCriteria => _lastSearchCriteria;
  Map<String, dynamic>? get savedAdvancedSearchState => _savedAdvancedSearchState;

  // Static constants from JobConstants
  static List<String> get jobCategories => JobConstants.jobCategories;
  static List<String> get experienceLevels => JobConstants.experienceLevels;
  static List<String> get salaryTypes => JobConstants.salaryTypes;
  static List<String> get applicationStatuses => JobConstants.applicationStatuses;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Job Management Methods
  Future<bool> postJob(JobModel job) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _jobManagementService.postJob(job);
      
      if (success) {
        _myPostedJobs.insert(0, job);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateJob(JobModel updatedJob) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _jobManagementService.updateJob(updatedJob);
      
      if (success) {
        // Update local lists
        final index = _myPostedJobs.indexWhere((job) => job.jobId == updatedJob.jobId);
        if (index != -1) {
          _myPostedJobs[index] = updatedJob;
        }
        
        final jobIndex = _jobs.indexWhere((job) => job.jobId == updatedJob.jobId);
        if (jobIndex != -1) {
          _jobs[jobIndex] = updatedJob;
        }
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteJob(String jobId) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _jobManagementService.deleteJob(jobId);
      
      if (success) {
        _myPostedJobs.removeWhere((job) => job.jobId == jobId);
        _jobs.removeWhere((job) => job.jobId == jobId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getMyPostedJobs(String clinicId) async {
    try {
      _setLoading(true);
      _setError(null);

      _myPostedJobs = await _jobManagementService.getMyPostedJobs(clinicId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getMyPostedAssistantJobs(String clinicId) async {
    try {
      _setLoading(true);
      _setError(null);

      debugPrint('Loading assistant jobs for clinic ID: $clinicId');
      
      // Query assistant jobs from Firestore
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection('job_posts_assistant')
            .where('clinicId', isEqualTo: clinicId)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (indexError) {
        debugPrint('Index error, falling back to query without orderBy: $indexError');
        // Fallback: Query without orderBy if index doesn't exist
        querySnapshot = await _firestore
            .collection('job_posts_assistant')
            .where('clinicId', isEqualTo: clinicId)
            .get();
      }

      final assistantJobs = <AssistantJobModel>[];
      
      for (var doc in querySnapshot.docs) {
        try {
          final jobData = doc.data() as Map<String, dynamic>;
          // Add document ID to the data if it's missing
          jobData['jobId'] = jobData['jobId'] ?? doc.id;
          final job = AssistantJobModel.fromMap(jobData);
          assistantJobs.add(job);
        } catch (parseError) {
          debugPrint('Error parsing assistant job document ${doc.id}: $parseError');
          // Continue with other documents instead of failing entirely
        }
      }

      // Sort jobs by createdAt if we used the fallback query
      if (querySnapshot.docs.isNotEmpty) {
        assistantJobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      _myPostedAssistantJobs = assistantJobs;
      debugPrint('Loaded ${assistantJobs.length} assistant jobs for clinic $clinicId');
      for (var job in assistantJobs) {
        debugPrint('Assistant Job: ${job.jobId}, Title: ${job.titlePost}, Active: ${job.isActive}');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error in getMyPostedAssistantJobs: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<JobModel?> getJobById(String jobId) async {
    try {
      return await _jobManagementService.getJobById(jobId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Search Methods
  Future<void> searchJobs({
    String? keyword,
    String? province,
    String? jobCategory,
    String? experienceLevel,
    String? minSalary,
    String? userId,
    String? title,
    String? description,
    String? minExperienceYears,
    String? salaryType,
    String? perks,
    String? city,
    String? trainLine,
    String? trainStation,
    String? workingDays,
    String? workingHours,
    String? additionalRequirements,
    String? startDate,
    String? endDate,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Build search criteria for display purposes
      final searchCriteria = <String, dynamic>{};
      if (keyword != null && keyword.trim().isNotEmpty) {
        searchCriteria['keyword'] = keyword.trim();
      }
      if (province != null && province.trim().isNotEmpty) {
        searchCriteria['province'] = province.trim();
      }
      if (jobCategory != null && jobCategory.trim().isNotEmpty) {
        searchCriteria['jobCategory'] = jobCategory.trim();
      }
      if (experienceLevel != null && experienceLevel.trim().isNotEmpty) {
        searchCriteria['experienceLevel'] = experienceLevel.trim();
      }
      if (minSalary != null) {
        searchCriteria['minSalary'] = minSalary;
      }
      // Store the search criteria for display purposes
      _lastSearchCriteria = Map<String, dynamic>.from(searchCriteria);

      _jobs = await _jobSearchService.searchJobs(
        keyword: keyword,
        province: province,
        jobCategory: jobCategory,
        experienceLevel: experienceLevel,
        minSalary: minSalary,
        userId: userId,
        title: title,
        description: description,
        minExperienceYears: minExperienceYears,
        salaryType: salaryType,
        perks: perks,
        city: city,
        trainLine: trainLine,
        trainStation: trainStation,
        workingDays: workingDays,
        workingHours: workingHours,
        additionalRequirements: additionalRequirements,
        startDate: startDate,
        endDate: endDate,
      );

      // Jobs are already sorted by ID (newest first) from Firebase query
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchJobsAlternative({
    String? keyword,
    String? province,
    String? jobCategory,
    String? experienceLevel,
    String? minSalary,
    String? userId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _jobs = await _jobSearchService.searchJobsAlternative(
        keyword: keyword,
        province: province,
        jobCategory: jobCategory,
        experienceLevel: experienceLevel,
        minSalary: minSalary,
        userId: userId,
      );

      // Jobs are already sorted by ID (newest first) from Firebase query
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Application Methods
  Future<bool> applyToJob({
    required String jobId,
    required String applicantId,
    required String coverLetter,
    List<String>? additionalDocuments,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _jobApplicationService.applyToJob(
        jobId: jobId,
        applicantId: applicantId,
        coverLetter: coverLetter,
        additionalDocuments: additionalDocuments,
      );

      if (success) {
        // Refresh applications
        await getMyApplications(applicantId);
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getMyApplications(String applicantId) async {
    try {
      _setLoading(true);
      _setError(null);

      _myApplications = await _jobApplicationService.getMyApplications(applicantId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getApplicantsForMyJobs(String clinicId) async {
    try {
      _setLoading(true);
      _setError(null);

      _applicantsForMyJobs = await _jobApplicationService.getApplicantsForMyJobs(clinicId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String newStatus,
    String? notes,
    DateTime? interviewDate,
    String? interviewLocation,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _jobApplicationService.updateApplicationStatus(
        applicationId: applicationId,
        newStatus: newStatus,
        notes: notes,
        interviewDate: interviewDate,
        interviewLocation: interviewLocation,
      );

      if (success) {
        // Update local list
        final index = _applicantsForMyJobs.indexWhere((app) => app.applicationId == applicationId);
        if (index != -1) {
          _applicantsForMyJobs[index] = _applicantsForMyJobs[index].copyWith(
            status: newStatus,
            notes: notes,
            interviewDate: interviewDate,
            interviewLocation: interviewLocation,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadJobApplications(String jobId) async {
    try {
      _setLoading(true);
      _setError(null);

      _applicantsForMyJobs = await _jobApplicationService.loadJobApplications(jobId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserApplicationsFromUserCollection(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      _myApplications = await _jobApplicationService.loadUserApplicationsFromUserCollection(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateApplicationStatusNewStructure({
    required String jobId,
    required String userId,
    required String applicationId,
    required String newStatus,
    String? notes,
    DateTime? interviewDate,
    String? interviewLocation,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _jobApplicationService.updateApplicationStatusNewStructure(
        jobId: jobId,
        userId: userId,
        applicationId: applicationId,
        newStatus: newStatus,
        notes: notes,
        interviewDate: interviewDate,
        interviewLocation: interviewLocation,
      );

      if (success) {
        // Update local list
        final index = _applicantsForMyJobs.indexWhere((app) => app.applicationId == applicationId);
        if (index != -1) {
          _applicantsForMyJobs[index] = _applicantsForMyJobs[index].copyWith(
            status: newStatus,
            notes: notes,
            interviewDate: interviewDate,
            interviewLocation: interviewLocation,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitApplication({
    required String jobId,
    required String applicantId,
    required JobApplicationModel application,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _jobApplicationService.submitApplication(
        jobId: jobId,
        applicantId: applicantId,
        application: application,
      );

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // AI Methods
  Future<List<JobModel>> searchJobsByDayHours(String searchQuery) async {
    try {
      return await _jobAIService.searchJobsByDayHours(searchQuery);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  Future<void> searchJobsWithAI({
    String? keyword,
    String? province,
    String? city,
    String? jobCategory,
    String? experienceLevel,
    String? salaryType,
    String? minSalary,
    String? maxSalary,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRemote,
    bool? isUrgent,
    String? trainLine,
    String? trainStation,
    List<String>? workingDays,
    String? workingHours,
    String? additionalRequirements,
    String? workingType,
    String? userId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Get newest 1000 active jobs by highest ID
      Query query = _firestore.collection('job_posts_dentist')
          .where('isActive', isEqualTo: true)
          .orderBy('jobId', descending: true)
          .limit(1000);

      final querySnapshot = await query.get();
      final allJobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      if (allJobs.isEmpty) {
        _jobs = [];
        notifyListeners();
        return;
      }

      // Build search criteria from non-empty fields only
      final searchCriteria = <String, dynamic>{};
      
      if (keyword != null && keyword.trim().isNotEmpty) {
        searchCriteria['keyword'] = keyword.trim();
      }
      if (province != null && province.trim().isNotEmpty) {
        searchCriteria['province'] = province.trim();
      }
      if (city != null && city.trim().isNotEmpty) {
        searchCriteria['city'] = city.trim();
      }
      if (jobCategory != null && jobCategory.trim().isNotEmpty) {
        searchCriteria['jobCategory'] = jobCategory.trim();
      }
      if (experienceLevel != null && experienceLevel.trim().isNotEmpty) {
        searchCriteria['experienceLevel'] = experienceLevel.trim();
      }
      if (salaryType != null && salaryType.trim().isNotEmpty) {
        searchCriteria['salaryType'] = salaryType.trim();
      }
      if (minSalary != null) {
        searchCriteria['minSalary'] = minSalary;
      }
      if (maxSalary != null) {
        searchCriteria['maxSalary'] = maxSalary;
      }
      if (startDate != null) {
        searchCriteria['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        searchCriteria['endDate'] = endDate.toIso8601String();
      }
      if (isRemote == true) {
        searchCriteria['isRemote'] = isRemote;
      }
      if (isUrgent == true) {
        searchCriteria['isUrgent'] = isUrgent;
      }
      if (trainLine != null && trainLine.trim().isNotEmpty && trainLine != 'ไม่ใกล้รถไฟฟ้า') {
        searchCriteria['trainLine'] = trainLine.trim();
      }
      if (trainStation != null && trainStation.trim().isNotEmpty && trainStation != 'ไม่ใกล้รถไฟฟ้า') {
        searchCriteria['trainStation'] = trainStation.trim();
      }
      if (workingDays != null && workingDays.isNotEmpty) {
        searchCriteria['workingDays'] = workingDays;
      }
      if (workingHours != null && workingHours.trim().isNotEmpty) {
        searchCriteria['workingHours'] = workingHours.trim();
      }
      if (additionalRequirements != null && additionalRequirements.trim().isNotEmpty) {
        searchCriteria['additionalRequirements'] = additionalRequirements.trim();
      }
      if (workingType != null && workingType.trim().isNotEmpty) {
        searchCriteria['workingType'] = workingType.trim();
      }

      // Store the search criteria for display purposes
      _lastSearchCriteria = Map<String, dynamic>.from(searchCriteria);

      _jobs = await _jobAIService.searchJobsWithAI(
        allJobs: allJobs,
        keyword: keyword,
        province: province,
        city: city,
        jobCategory: jobCategory,
        experienceLevel: experienceLevel,
        salaryType: salaryType,
        minSalary: minSalary,
        maxSalary: maxSalary,
        startDate: startDate,
        endDate: endDate,
        isRemote: isRemote,
        isUrgent: isUrgent,
        trainLine: trainLine,
        trainStation: trainStation,
        workingDays: workingDays,
        workingHours: workingHours,
        additionalRequirements: additionalRequirements,
        workingType: workingType,
      );
      
      // Calculate matching scores if userId is provided
      if (userId != null) {
        _jobs = await _jobSearchService.calculateMatchingScores(_jobs, userId);
      }

      // Jobs are already sorted by ID (newest first) from Firebase query
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Clear data
  void clearData() {
    _jobs.clear();
    _myPostedJobs.clear();
    _myPostedAssistantJobs.clear();
    _myApplications.clear();
    _applicantsForMyJobs.clear();
    _error = null;
    _lastSearchCriteria = null;
    _savedAdvancedSearchState = null;
    notifyListeners();
  }

  // Legacy method aliases for backward compatibility
  Future<void> loadMyPostedJobs(String clinicId) async {
    return getMyPostedJobs(clinicId);
  }

  Future<void> loadMyPostedAssistantJobs(String clinicId) async {
    return getMyPostedAssistantJobs(clinicId);
  }

  Future<void> loadApplicantsForMyJobs(String clinicId) async {
    return getApplicantsForMyJobs(clinicId);
  }

  Future<void> loadUserApplications(String userId) async {
    return getMyApplications(userId);
  }

  // Utility Methods
  List<String> getFormattedSearchCriteria() {
    if (_lastSearchCriteria == null || _lastSearchCriteria!.isEmpty) {
      return [];
    }

    final List<String> criteria = [];
    
    _lastSearchCriteria!.forEach((key, value) {
      String displayText = '';
      
      switch (key) {
        case 'keyword':
          displayText = 'คำค้นหา: $value';
          break;
        case 'province':
          displayText = 'พื้นที่: $value';
          break;
        case 'jobCategory':
          displayText = 'หมวดงาน: $value';
          break;
        case 'experienceLevel':
          displayText = 'ประสบการณ์: $value';
          break;
        case 'minSalary':
          displayText = 'ประกันรายได้ขั้นต่ำ: ${value.toString()} บาท';
          break;
        case 'maxSalary':
          displayText = 'เงินเดือนขั้นต่ำ: ${value.toString()} บาท';
          break;
      }
      
      if (displayText.isNotEmpty) {
        criteria.add(displayText);
      }
    });
    
    return criteria;
  }

  // Save advanced search form state
  void saveAdvancedSearchState({
    String? keyword,
    int? selectedProvinceZoneIndex,
    String? selectedLocation,
    String? selectedJobCategory,
    String? selectedExperienceLevel,
    String? selectedSalaryType,
    String? minSalary,
    String? maxSalary,
    int? selectedTrainLineIndex,
    String? selectedTrainStation,
    String? selectedWorkingType,
    List<String>? selectedWorkingDays,
    String? workingHours,
    DateTime? startDate,
    DateTime? endDate,
    String? additionalRequirements,
  }) {
    _savedAdvancedSearchState = {
      'keyword': keyword,
      'selectedProvinceZoneIndex': selectedProvinceZoneIndex,
      'selectedLocation': selectedLocation,
      'selectedJobCategory': selectedJobCategory,
      'selectedExperienceLevel': selectedExperienceLevel,
      'selectedSalaryType': selectedSalaryType,
      'minSalary': minSalary,
      'maxSalary': maxSalary,
      'selectedTrainLineIndex': selectedTrainLineIndex,
      'selectedTrainStation': selectedTrainStation,
      'selectedWorkingType': selectedWorkingType,
      'selectedWorkingDays': selectedWorkingDays,
      'workingHours': workingHours,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'additionalRequirements': additionalRequirements,
    };
  }

  // Clear advanced search state
  void clearAdvancedSearchState() {
    _savedAdvancedSearchState = null;
  }

  // Report a job as inappropriate
  Future<void> reportJob(String jobId) async {
    try {
      await _firestore.collection('job_posts_dentist').doc(jobId).update({
        'reported': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update local state if the job is in the current list
      final index = _jobs.indexWhere((job) => job.jobId == jobId);
      if (index != -1) {
        _jobs[index] = _jobs[index].copyWith(reported: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error reporting job: $e');
      rethrow;
    }
  }
} 