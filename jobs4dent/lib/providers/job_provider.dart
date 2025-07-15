import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

      await _firestore.collection('job_posts').doc(job.jobId).set(job.toMap());
      
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

      await _firestore.collection('job_posts').doc(updatedJob.jobId).update(
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

      await _firestore.collection('job_posts').doc(jobId).delete();
      
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
    String? salaryType,
    double? minSalary,
    double? maxSalary,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRemote,
    bool? isUrgent,
    String? trainLine,
    String? trainStation,
    List<String>? workingDays,
    String? workingHours,
    String? additionalRequirements,
    String? userId, // For matching calculation
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Use a simple query without composite index requirements
      // Only filter by isActive and do all other filtering client-side
      Query query = _firestore.collection('job_posts')
          .where('isActive', isEqualTo: true)
          .limit(500); // Increase limit to get more results for client-side filtering

      final querySnapshot = await query.get();

      _jobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Sort by createdAt descending (client-side)
      _jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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

      if (startDate != null) {
        _jobs = _jobs.where((job) =>
            job.startDate == null || job.startDate!.isAfter(startDate) || job.startDate!.isAtSameMomentAs(startDate)).toList();
      }

      if (endDate != null) {
        _jobs = _jobs.where((job) =>
            job.endDate == null || job.endDate!.isBefore(endDate) || job.endDate!.isAtSameMomentAs(endDate)).toList();
      }

      // Filter by salary type
      if (salaryType != null && salaryType.isNotEmpty) {
        _jobs = _jobs.where((job) => job.salaryType == salaryType).toList();
      }

      // Filter by train line
      if (trainLine != null && trainLine.isNotEmpty) {
        _jobs = _jobs.where((job) => job.trainLine == trainLine).toList();
      }

      // Filter by train station
      if (trainStation != null && trainStation.isNotEmpty) {
        _jobs = _jobs.where((job) => job.trainStation != null && 
                                   job.trainStation!.toLowerCase().contains(trainStation.toLowerCase())).toList();
      }

      // Filter by working days
      if (workingDays != null && workingDays.isNotEmpty) {
        _jobs = _jobs.where((job) => job.workingDays != null && 
                                   workingDays.any((day) => job.workingDays!.contains(day))).toList();
      }

      // Filter by working hours
      if (workingHours != null && workingHours.isNotEmpty) {
        _jobs = _jobs.where((job) => job.workingHours != null && 
                                   job.workingHours!.toLowerCase().contains(workingHours.toLowerCase())).toList();
      }

      // Filter by additional requirements
      if (additionalRequirements != null && additionalRequirements.isNotEmpty) {
        _jobs = _jobs.where((job) => job.additionalRequirements != null && 
                                   job.additionalRequirements!.toLowerCase().contains(additionalRequirements.toLowerCase())).toList();
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

  // Search jobs with filters - Alternative approach without composite indexes
  Future<void> searchJobsAlternative({
    String? keyword,
    String? province,
    String? city,
    String? jobCategory,
    String? experienceLevel,
    String? salaryType,
    double? minSalary,
    double? maxSalary,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRemote,
    bool? isUrgent,
    String? trainLine,
    String? trainStation,
    List<String>? workingDays,
    String? workingHours,
    String? additionalRequirements,
    String? userId, // For matching calculation
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Use the simplest possible query - no composite indexes required
      Query query = _firestore.collection('job_posts').limit(1000);

      final querySnapshot = await query.get();

      _jobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by isActive first (client-side)
      _jobs = _jobs.where((job) => job.isActive).toList();

      // Sort by createdAt descending (client-side)
      _jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply all filters client-side
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

      if (startDate != null) {
        _jobs = _jobs.where((job) =>
            job.startDate == null || job.startDate!.isAfter(startDate) || job.startDate!.isAtSameMomentAs(startDate)).toList();
      }

      if (endDate != null) {
        _jobs = _jobs.where((job) =>
            job.endDate == null || job.endDate!.isBefore(endDate) || job.endDate!.isAtSameMomentAs(endDate)).toList();
      }

      // Filter by salary type
      if (salaryType != null && salaryType.isNotEmpty) {
        _jobs = _jobs.where((job) => job.salaryType == salaryType).toList();
      }

      // Filter by train line
      if (trainLine != null && trainLine.isNotEmpty) {
        _jobs = _jobs.where((job) => job.trainLine == trainLine).toList();
      }

      // Filter by train station
      if (trainStation != null && trainStation.isNotEmpty) {
        _jobs = _jobs.where((job) => job.trainStation != null && 
                                   job.trainStation!.toLowerCase().contains(trainStation.toLowerCase())).toList();
      }

      // Filter by working days
      if (workingDays != null && workingDays.isNotEmpty) {
        _jobs = _jobs.where((job) => job.workingDays != null && 
                                   workingDays.any((day) => job.workingDays!.contains(day))).toList();
      }

      // Filter by working hours
      if (workingHours != null && workingHours.isNotEmpty) {
        _jobs = _jobs.where((job) => job.workingHours != null && 
                                   job.workingHours!.toLowerCase().contains(workingHours.toLowerCase())).toList();
      }

      // Filter by additional requirements
      if (additionalRequirements != null && additionalRequirements.isNotEmpty) {
        _jobs = _jobs.where((job) => job.additionalRequirements != null && 
                                   job.additionalRequirements!.toLowerCase().contains(additionalRequirements.toLowerCase())).toList();
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
      final jobDoc = await _firestore.collection('job_posts').doc(jobId).get();
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
      await _firestore.collection('job_posts').doc(jobId).update({
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
          .collection('job_posts')
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
          .get();

      _myApplications = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap(doc.data()))
          .toList();
      
      // Sort by appliedAt in descending order on the client side
      _myApplications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

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
          .get();

      _applicantsForMyJobs = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap(doc.data()))
          .toList();
      
      // Sort by appliedAt in descending order on the client side
      _applicantsForMyJobs.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

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
      final doc = await _firestore.collection('job_posts').doc(jobId).get();
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
          .get();

      _myApplications = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap({
                ...doc.data(),
                'applicationId': doc.id,
              }))
          .toList();
      
      // Sort by appliedAt in descending order on the client side
      _myApplications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

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
          .collection('job_posts')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      _myPostedJobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap({
                ...doc.data(),
                'jobId': doc.id,
              }))
          .toList();

      // Sort by createdAt in descending order on the client side
      _myPostedJobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
          .get();

      _applicantsForMyJobs = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap({
                ...doc.data(),
                'applicationId': doc.id,
              }))
          .toList();
      
      // Sort by appliedAt in descending order on the client side
      _applicantsForMyJobs.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

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
          .collection('job_posts')
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
      await _firestore.collection('job_posts').doc(jobId).update({
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
          .collection('job_posts')
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

      // Update in job_posts sub-collection
      await _firestore
          .collection('job_posts')
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

  // Search jobs by working days and hours using Gemini AI
  Future<List<JobModel>> searchJobsByDayHours(String searchQuery) async {
    try {
      // First, get all active jobs
      final query = _firestore.collection('job_posts')
          .where('isActive', isEqualTo: true)
          .limit(500);

      final querySnapshot = await query.get();
      final allJobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data()))
          .toList();

      // Filter jobs that have workingDays or workingHours
      final jobsWithSchedule = allJobs.where((job) => 
        (job.workingDays != null && job.workingDays!.isNotEmpty) ||
        (job.workingHours != null && job.workingHours!.isNotEmpty)
      ).toList();

      if (jobsWithSchedule.isEmpty) {
        return [];
      }

            // Use Gemini API to analyze the search query and match with job schedules
      final apiKey = dotenv.env['GOOGLE_AI_STUDIO_APIKEY_AEK'] ?? '';
      
      if (apiKey.isEmpty) {
        throw Exception('Google AI Studio API key not found. Please check your .env file.');
      }
      
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: dotenv.env['GOOGLE_AI_STUDIO_APIKEY_AEK'] ?? '',
      );

      // Prepare the data for Gemini
      final jobScheduleData = jobsWithSchedule.map((job) {
        final workingDays = job.workingDays?.join(', ') ?? '';
        final workingHours = job.workingHours ?? '';
        return {
          'jobId': job.jobId,
          'title': job.title,
          'clinicName': job.clinicName,
          'workingDays': workingDays,
          'workingHours': workingHours,
        };
      }).toList();

      final prompt = '''
You are an AI assistant helping to match job seekers with jobs based on their preferred working days and hours.

User's search query: "$searchQuery"

Job schedule data:
${jobScheduleData.map((job) => 'Job ID: ${job['jobId']}, Title: ${job['title']}, Clinic: ${job['clinicName']}, Working Days: ${job['workingDays']}, Working Hours: ${job['workingHours']}').join('\n')}

Please analyze the user's search query and return ONLY the Job IDs that match the user's requirements. Consider:
1. Day preferences (Monday-Sunday, weekdays, weekends)
2. Time preferences (morning, afternoon, evening, specific hours)
3. Flexible matching (e.g., if user wants "weekdays" match Monday-Friday)
4. Thai language understanding (วันจันทร์=Monday, วันอังคาร=Tuesday, etc.)

Return only the matching Job IDs in this exact format:
MATCHING_JOB_IDS: [jobId1, jobId2, jobId3]

If no jobs match, return:
MATCHING_JOB_IDS: []
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      // Parse the response to extract job IDs
      final matchingJobIds = _parseGeminiResponse(responseText);

      // Filter the original jobs based on matching IDs
      final matchingJobs = jobsWithSchedule.where((job) =>
        matchingJobIds.contains(job.jobId)
      ).toList();

      // Sort by creation date (newest first)
      matchingJobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return matchingJobs;
    } catch (e) {
      if (kDebugMode) {
        print('Error in searchJobsByDayHours: $e');
      }
      throw Exception('การค้นหาด้วย AI ไม่สำเร็จ: $e');
    }
  }

  List<String> _parseGeminiResponse(String responseText) {
    try {
      final regex = RegExp(r'MATCHING_JOB_IDS:\s*\[(.*?)\]');
      final match = regex.firstMatch(responseText);
      
      if (match != null) {
        final jobIdsString = match.group(1) ?? '';
        if (jobIdsString.trim().isEmpty) {
          return [];
        }
        
        return jobIdsString
            .split(',')
            .map((id) => id.trim().replaceAll('"', '').replaceAll("'", ''))
            .where((id) => id.isNotEmpty)
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Gemini response: $e');
      }
      return [];
    }
  }
} 