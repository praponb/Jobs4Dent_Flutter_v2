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
    'ทันตแพทย์ทั่วไป GP',
    'ทันตแพทย์จัดฟัน',
    'ทันตแพทย์ฟันปลอม',
    'ทันตแพทย์รักษารากฟัน',
    'ทันตแพทย์เฉพาะทางรากเทียม',
    'ทันตแพทย์เฉพาะทางศัลย์',
    'ทันตแพทย์รักษาโรคเหงือก',
    'ทันตแพทย์รักษาเด็ก',
    'ทันตแพทย์แม็กซิลโลเฟเชียล',
    'ทันตแพทย์ผ่าตัดขากรรไกร',
  ];

  // Experience Levels
  static const List<String> experienceLevels = [
    'ไม่มีประสบการณ์',
    '6 เดือน - 12 เดือน',
    '1 ปี',
    '2 ปี',
    '3 ปี',
    '4 ปี',
    '5 ปี',
    '6 ปี',
    '7 ปี',
    '8 ปี',
    '9 ปี',
    '10 ปี',
    '10 ปีขึ้นไป',
  ];

  // Salary Types
  static const List<String> salaryTypes = [
    '50:50',
    '60:40',
    '70:30',
    '80:20',
    '45:55',
    '40:60',
    '30:70',
  ];


  // Application Statuses
  static const List<String> applicationStatuses = [
    'ส่งแล้ว',
    'อยู่ระหว่างพิจารณา',
    'ผ่านเข้ารอบ',
    'นัดสัมภาษณ์แล้ว',
    'สัมภาษณ์เสร็จสิ้น',
    'ได้รับข้อเสนอ',
    'รับเข้าทำงาน',
    'ปฏิเสธ',
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
      _setError('การโพสต์งานไม่สำเร็จ: $e');
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
      _setError('การอัปเดตงานไม่สำเร็จ: $e');
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
      _setError('การลบงานไม่สำเร็จ: $e');
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
    String? jobCategory,
    String? experienceLevel,
    double? minSalary,
    double? maxSalary,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRemote,
    bool? isUrgent,
    String? userId, // For matching calculation
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Use a simple query that only requires a basic composite index
      // This avoids the need for complex composite indexes for every filter combination
      Query query = _firestore.collection('jobPostings')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(100); // Increase limit to ensure we have enough results after filtering

      final querySnapshot = await query.get();

      _jobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Apply all filters client-side to avoid composite index issues
      if (keyword != null && keyword.isNotEmpty) {
        _jobs = _jobs.where((job) =>
            job.title.toLowerCase().contains(keyword.toLowerCase()) ||
            job.description.toLowerCase().contains(keyword.toLowerCase()) ||
            job.clinicName.toLowerCase().contains(keyword.toLowerCase())).toList();
      }

      if (province != null && province.isNotEmpty) {
        _jobs = _jobs.where((job) => job.province == province).toList();
      }
      
      if (city != null && city.isNotEmpty) {
        _jobs = _jobs.where((job) => job.city == city).toList();
      }
      
      if (jobCategory != null && jobCategory.isNotEmpty) {
        _jobs = _jobs.where((job) => job.jobCategory == jobCategory).toList();
      }
      
      if (experienceLevel != null && experienceLevel.isNotEmpty) {
        _jobs = _jobs.where((job) => job.experienceLevel == experienceLevel).toList();
      }
      
      if (isRemote != null) {
        _jobs = _jobs.where((job) => job.isRemote == isRemote).toList();
      }
      
      if (isUrgent != null) {
        _jobs = _jobs.where((job) => job.isUrgent == isUrgent).toList();
      }

      if (minSalary != null) {
        _jobs = _jobs.where((job) => job.minSalary != null && job.minSalary! >= minSalary).toList();
      }

      if (maxSalary != null) {
        _jobs = _jobs.where((job) => job.maxSalary != null && job.maxSalary! <= maxSalary).toList();
      }

      // if (requiredSkills != null && requiredSkills.isNotEmpty) {
      //   _jobs = _jobs.where((job) =>
      //       requiredSkills.any((skill) => job.requiredSkills.contains(skill))).toList();
      // }

      // if (requiredSpecialties != null && requiredSpecialties.isNotEmpty) {
      //   _jobs = _jobs.where((job) =>
      //       requiredSpecialities.any((specialty) => job.requiredSpecialties.contains(specialty))).toList();
      // }

      if (startDate != null) {
        _jobs = _jobs.where((job) =>
            job.startDate == null || job.startDate!.isAfter(startDate) || job.startDate!.isAtSameMomentAs(startDate)).toList();
      }

      if (endDate != null) {
        _jobs = _jobs.where((job) =>
            job.endDate == null || job.endDate!.isBefore(endDate) || job.endDate!.isAtSameMomentAs(endDate)).toList();
      }

      // Limit results to 50 after filtering
      if (_jobs.length > 50) {
        _jobs = _jobs.take(50).toList();
      }

      // Calculate matching scores if userId is provided
      if (userId != null) {
        await _calculateMatchingScores(userId);
      }

      notifyListeners();
    } catch (e) {
      _setError('การค้นหางานไม่สำเร็จ: $e');
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
        _setError('ไม่พบงาน');
        return false;
      }

      final job = JobModel.fromMap(jobDoc.data()!);

      // Get applicant details
      final userDoc = await _firestore.collection('users').doc(applicantId).get();
      if (!userDoc.exists) {
        _setError('ไม่พบผู้ใช้');
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
        _setError('คุณได้สมัครงานนี้แล้ว');
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
      _setError('การสมัครงานไม่สำเร็จ: $e');
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
      _setError('การดึงงานที่โพสต์ไม่สำเร็จ: $e');
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
      _setError('การดึงใบสมัครไม่สำเร็จ: $e');
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
      _setError('การดึงผู้สมัครไม่สำเร็จ: $e');
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
      _setError('การอัปเดตสถานะใบสมัครไม่สำเร็จ: $e');
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
      _setError('การดึงรายละเอียดงานไม่สำเร็จ: $e');
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
      _setError('การโหลดใบสมัครไม่สำเร็จ: $e');
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
      _setError('การโหลดงานที่โพสต์ไม่สำเร็จ: $e');
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
      _setError('การโหลดผู้สมัครไม่สำเร็จ: $e');
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
      _setError('การส่งใบสมัครไม่สำเร็จ: $e');
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
      _setError('การโหลดใบสมัครงานไม่สำเร็จ: $e');
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
      _setError('การโหลดใบสมัครผู้ใช้ไม่สำเร็จ: $e');
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
      _setError('การอัปเดตสถานะใบสมัครไม่สำเร็จ: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
} 