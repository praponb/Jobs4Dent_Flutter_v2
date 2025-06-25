import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/job_application_model.dart';
import '../models/user_model.dart';

class JobProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<JobModel> _jobs = [];
  List<JobModel> _myPostedJobs = [];
  List<JobApplicationModel> _myApplications = [];
  List<JobApplicationModel> _applicantsForMyJobs = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<JobModel> get jobs => _jobs;
  List<JobModel> get myPostedJobs => _myPostedJobs;
  List<JobApplicationModel> get myApplications => _myApplications;
  List<JobApplicationModel> get userApplications => _myApplications; // Alias for dashboard
  List<JobApplicationModel> get applicantsForMyJobs => _applicantsForMyJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Job Categories
  static const List<String> jobCategories = [
    'General Dentist',
    'Dental Hygienist',
    'Dental Assistant',
    'Orthodontic Assistant',
    'Oral Surgery Assistant',
    'Endodontic Assistant',
    'Periodontic Assistant',
    'Pediatric Dental Assistant',
    'X-ray Technician',
    'Dental Lab Technician',
    'Receptionist',
    'Office Manager',
    'Treatment Coordinator',
    'Insurance Coordinator',
    'Sterilization Technician',
  ];

  // Job Types
  static const List<String> jobTypes = [
    'full-time',
    'part-time',
    'freelance',
    'locum',
  ];

  // Experience Levels
  static const List<String> experienceLevels = [
    'entry',
    'mid',
    'senior',
  ];

  // Salary Types
  static const List<String> salaryTypes = [
    'monthly',
    'daily',
    'hourly',
    'case-based',
  ];

  // Application Statuses
  static const List<String> applicationStatuses = [
    'submitted',
    'under_review',
    'shortlisted',
    'interview_scheduled',
    'interview_completed',
    'offered',
    'hired',
    'rejected',
  ];

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Post a new job (for clinics)
  Future<bool> postJob(JobModel job) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('jobPostings').doc(job.jobId).set(job.toMap());
      
      // Add to local list
      _myPostedJobs.insert(0, job);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to post job: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing job
  Future<bool> updateJob(JobModel updatedJob) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('jobPostings').doc(updatedJob.jobId).update(
        updatedJob.copyWith(updatedAt: DateTime.now()).toMap(),
      );
      
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
      return true;
    } catch (e) {
      _setError('Failed to update job: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a job
  Future<bool> deleteJob(String jobId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('jobPostings').doc(jobId).delete();
      
      // Remove from local lists
      _myPostedJobs.removeWhere((job) => job.jobId == jobId);
      _jobs.removeWhere((job) => job.jobId == jobId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete job: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search jobs with filters
  Future<void> searchJobs({
    String? keyword,
    String? province,
    String? city,
    String? jobType,
    String? jobCategory,
    String? experienceLevel,
    double? minSalary,
    double? maxSalary,
    List<String>? requiredSkills,
    List<String>? requiredSpecialties,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRemote,
    bool? isUrgent,
    String? userId, // For matching calculation
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      Query query = _firestore.collection('jobPostings')
          .where('isActive', isEqualTo: true);

      // Apply filters
      if (province != null && province.isNotEmpty) {
        query = query.where('province', isEqualTo: province);
      }
      
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      
      if (jobType != null && jobType.isNotEmpty) {
        query = query.where('jobType', isEqualTo: jobType);
      }
      
      if (jobCategory != null && jobCategory.isNotEmpty) {
        query = query.where('jobCategory', isEqualTo: jobCategory);
      }
      
      if (experienceLevel != null && experienceLevel.isNotEmpty) {
        query = query.where('experienceLevel', isEqualTo: experienceLevel);
      }
      
      if (isRemote != null) {
        query = query.where('isRemote', isEqualTo: isRemote);
      }
      
      if (isUrgent != null) {
        query = query.where('isUrgent', isEqualTo: isUrgent);
      }

      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _jobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Apply additional filters that can't be done in Firestore
      if (keyword != null && keyword.isNotEmpty) {
        _jobs = _jobs.where((job) =>
            job.title.toLowerCase().contains(keyword.toLowerCase()) ||
            job.description.toLowerCase().contains(keyword.toLowerCase()) ||
            job.clinicName.toLowerCase().contains(keyword.toLowerCase())).toList();
      }

      if (minSalary != null) {
        _jobs = _jobs.where((job) => job.minSalary != null && job.minSalary! >= minSalary).toList();
      }

      if (maxSalary != null) {
        _jobs = _jobs.where((job) => job.maxSalary != null && job.maxSalary! <= maxSalary).toList();
      }

      if (requiredSkills != null && requiredSkills.isNotEmpty) {
        _jobs = _jobs.where((job) =>
            requiredSkills.any((skill) => job.requiredSkills.contains(skill))).toList();
      }

      if (requiredSpecialties != null && requiredSpecialties.isNotEmpty) {
        _jobs = _jobs.where((job) =>
            requiredSpecialties.any((specialty) => job.requiredSpecialties.contains(specialty))).toList();
      }

      if (startDate != null) {
        _jobs = _jobs.where((job) =>
            job.startDate == null || job.startDate!.isAfter(startDate) || job.startDate!.isAtSameMomentAs(startDate)).toList();
      }

      if (endDate != null) {
        _jobs = _jobs.where((job) =>
            job.endDate == null || job.endDate!.isBefore(endDate) || job.endDate!.isAtSameMomentAs(endDate)).toList();
      }

      // Calculate matching scores if userId is provided
      if (userId != null) {
        await _calculateMatchingScores(userId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to search jobs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Calculate matching scores for jobs based on user profile
  Future<void> _calculateMatchingScores(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final user = UserModel.fromMap(userDoc.data()!);
      
      for (int i = 0; i < _jobs.length; i++) {
        final job = _jobs[i];
        double score = 0.0;
        int factors = 0;

        // Location matching (30% weight)
        if (user.workLocationPreference?.contains(job.province) ?? false) {
          score += 30;
        }
        factors++;

        // Skills matching (25% weight)
        if (user.skills != null && user.skills!.isNotEmpty && job.requiredSkills.isNotEmpty) {
          final matchingSkills = user.skills!.where((skill) => job.requiredSkills.contains(skill)).length;
          score += (matchingSkills / job.requiredSkills.length) * 25;
        }
        factors++;

        // Specialties matching (25% weight)
        if (user.specialties != null && user.specialties!.isNotEmpty && job.requiredSpecialties.isNotEmpty) {
          final matchingSpecialties = user.specialties!.where((specialty) => job.requiredSpecialties.contains(specialty)).length;
          score += (matchingSpecialties / job.requiredSpecialties.length) * 25;
        }
        factors++;

        // Experience matching (20% weight)
        if (job.minExperienceYears != null && user.yearsOfExperience != null) {
          final userExperience = int.tryParse(user.yearsOfExperience!) ?? 0;
          if (userExperience >= job.minExperienceYears!) {
            score += 20;
          } else {
            score += (userExperience / job.minExperienceYears!) * 20;
          }
        }
        factors++;

        _jobs[i] = job.copyWith(matchingScore: factors > 0 ? score / factors : 0);
      }

      // Sort by matching score
      _jobs.sort((a, b) => (b.matchingScore ?? 0).compareTo(a.matchingScore ?? 0));
    } catch (e) {
      debugPrint('Error calculating matching scores: $e');
    }
  }

  // Apply to a job
  Future<bool> applyToJob({
    required String jobId,
    required String applicantId,
    required String coverLetter,
    List<String>? additionalDocuments,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Get job details
      final jobDoc = await _firestore.collection('jobPostings').doc(jobId).get();
      if (!jobDoc.exists) {
        _setError('Job not found');
        return false;
      }

      final job = JobModel.fromMap(jobDoc.data()!);

      // Get applicant details
      final userDoc = await _firestore.collection('users').doc(applicantId).get();
      if (!userDoc.exists) {
        _setError('User not found');
        return false;
      }

      final user = UserModel.fromMap(userDoc.data()!);

      // Check if already applied
      final existingApplication = await _firestore
          .collection('job_applications')
          .where('jobId', isEqualTo: jobId)
          .where('applicantId', isEqualTo: applicantId)
          .limit(1)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        _setError('You have already applied to this job');
        return false;
      }

      // Create application
      final applicationId = _firestore.collection('job_applications').doc().id;
      final application = JobApplicationModel(
        applicationId: applicationId,
        jobId: jobId,
        applicantId: applicantId,
        clinicId: job.clinicId,
        applicantName: user.userName,
        applicantEmail: user.email,
        applicantPhone: user.phoneNumber,
        applicantProfilePhoto: user.profilePhotoUrl,
        coverLetter: coverLetter,
        additionalDocuments: additionalDocuments ?? [],
        appliedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        applicantProfile: user.toMap(),
      );

      await _firestore.collection('job_applications').doc(applicationId).set(application.toMap());

      // Update job application count
      await _firestore.collection('jobPostings').doc(jobId).update({
        'applicationCount': FieldValue.increment(1),
        'applicationIds': FieldValue.arrayUnion([applicationId]),
      });

      // Add to local list
      _myApplications.insert(0, application);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to apply to job: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get my posted jobs (for clinics)
  Future<void> getMyPostedJobs(String clinicId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('jobPostings')
          .where('clinicId', isEqualTo: clinicId)
          .orderBy('createdAt', descending: true)
          .get();

      _myPostedJobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch posted jobs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get my applications (for dentists/assistants)
  Future<void> getMyApplications(String applicantId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('job_applications')
          .where('applicantId', isEqualTo: applicantId)
          .orderBy('appliedAt', descending: true)
          .get();

      _myApplications = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch applications: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get applicants for my jobs (for clinics)
  Future<void> getApplicantsForMyJobs(String clinicId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('job_applications')
          .where('clinicId', isEqualTo: clinicId)
          .orderBy('appliedAt', descending: true)
          .get();

      _applicantsForMyJobs = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch applicants: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update application status (for clinics)
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

      final updateData = {
        'status': newStatus,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (notes != null) updateData['notes'] = notes;
      if (interviewDate != null) updateData['interviewDate'] = interviewDate.millisecondsSinceEpoch;
      if (interviewLocation != null) updateData['interviewLocation'] = interviewLocation;

      await _firestore.collection('job_applications').doc(applicationId).update(updateData);

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

      return true;
    } catch (e) {
      _setError('Failed to update application status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get job by ID
  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await _firestore.collection('jobPostings').doc(jobId).get();
      if (doc.exists) {
        return JobModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      _setError('Failed to fetch job details: $e');
      return null;
    }
  }

  // Clear data
  void clearData() {
    _jobs.clear();
    _myPostedJobs.clear();
    _myApplications.clear();
    _applicantsForMyJobs.clear();
    _error = null;
    notifyListeners();
  }

  // Load user's applications (for dentists/assistants)
  Future<void> loadUserApplications(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('applications')
          .where('applicantId', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)
          .get();

      _myApplications = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap({
                ...doc.data(),
                'applicationId': doc.id,
              }))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load applications: $e');
      debugPrint('Error loading user applications: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load clinic's posted jobs
  Future<void> loadMyPostedJobs(String clinicId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('jobPostings')
          .where('clinicId', isEqualTo: clinicId)
          .orderBy('createdAt', descending: true)
          .get();

      _myPostedJobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap({
                ...doc.data(),
                'jobId': doc.id,
              }))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load posted jobs: $e');
      debugPrint('Error loading posted jobs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load applicants for clinic's jobs
  Future<void> loadApplicantsForMyJobs(String clinicId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('applications')
          .where('clinicId', isEqualTo: clinicId)
          .orderBy('appliedAt', descending: true)
          .get();

      _applicantsForMyJobs = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap({
                ...doc.data(),
                'applicationId': doc.id,
              }))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load applicants: $e');
      debugPrint('Error loading applicants: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Submit job application with new structure
  Future<bool> submitApplication({
    required String jobId,
    required String applicantId,
    required String clinicId,
    required JobApplicationModel application,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final applicationId = application.applicationId;

      // Store application under jobPosting
      await _firestore
          .collection('jobPostings')
          .doc(jobId)
          .collection('applications')
          .doc(applicationId)
          .set(application.toMap());

      // Store application under user for easy access
      await _firestore
          .collection('users')
          .doc(applicantId)
          .collection('applications')
          .doc(applicationId)
          .set(application.toMap());

      // Update job application count
      await _firestore.collection('jobPostings').doc(jobId).update({
        'applicationCount': FieldValue.increment(1),
        'applicationIds': FieldValue.arrayUnion([applicationId]),
      });

      return true;
    } catch (e) {
      _setError('Failed to submit application: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load applications for a specific job (for clinics)
  Future<void> loadJobApplications(String jobId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('jobPostings')
          .doc(jobId)
          .collection('applications')
          .orderBy('appliedAt', descending: true)
          .get();

      _applicantsForMyJobs = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap({
                ...doc.data(),
                'applicationId': doc.id,
              }))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load job applications: $e');
      debugPrint('Error loading job applications: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user applications from user sub-collection (new structure)
  Future<void> loadUserApplicationsFromUserCollection(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('applications')
          .orderBy('appliedAt', descending: true)
          .get();

      _myApplications = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap({
                ...doc.data(),
                'applicationId': doc.id,
              }))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load user applications: $e');
      debugPrint('Error loading user applications: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update application status in both locations (new structure)
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

      final updateData = {
        'status': newStatus,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (notes != null) updateData['notes'] = notes;
      if (interviewDate != null) updateData['interviewDate'] = interviewDate.millisecondsSinceEpoch;
      if (interviewLocation != null) updateData['interviewLocation'] = interviewLocation;

      // Update in jobPostings sub-collection
      await _firestore
          .collection('jobPostings')
          .doc(jobId)
          .collection('applications')
          .doc(applicationId)
          .update(updateData);

      // Update in users sub-collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('applications')
          .doc(applicationId)
          .update(updateData);

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

      return true;
    } catch (e) {
      _setError('Failed to update application status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
} 