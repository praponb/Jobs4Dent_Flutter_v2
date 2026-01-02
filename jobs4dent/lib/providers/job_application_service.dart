import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/job_application_model.dart';
import '../models/user_model.dart';

/// Service class for job application management
class JobApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Apply to a job
  Future<bool> applyToJob({
    required String jobId,
    required String applicantId,
    required String coverLetter,
    List<String>? additionalDocuments,
  }) async {
    try {
      // Get job details
      final jobDoc = await _firestore
          .collection('job_posts_dentist')
          .doc(jobId)
          .get();
      if (!jobDoc.exists) {
        throw Exception('ไม่พบงาน');
      }

      final job = JobModel.fromMap(jobDoc.data()!);

      // Get applicant details
      final userDoc = await _firestore
          .collection('users')
          .doc(applicantId)
          .get();
      if (!userDoc.exists) {
        throw Exception('ไม่พบผู้ใช้');
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
        throw Exception('คุณได้สมัครงานนี้แล้ว');
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

      await _firestore
          .collection('job_applications')
          .doc(applicationId)
          .set(application.toMap());

      // Update job application count
      await _firestore.collection('job_posts_dentist').doc(jobId).update({
        'applicationCount': FieldValue.increment(1),
        'applicationIds': FieldValue.arrayUnion([applicationId]),
      });

      return true;
    } catch (e) {
      throw Exception('การสมัครงานไม่สำเร็จ: $e');
    }
  }

  /// Get my applications (for dentists/assistants)
  Future<List<JobApplicationModel>> getMyApplications(
    String applicantId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('job_applications')
          .where('applicantId', isEqualTo: applicantId)
          .get();

      final applications = querySnapshot.docs
          .map((doc) => JobApplicationModel.fromMap(doc.data()))
          .toList();

      // Sort by appliedAt in descending order
      applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

      return applications;
    } catch (e) {
      throw Exception('การดึงใบสมัครไม่สำเร็จ: $e');
    }
  }

  /// Get my assistant job applications
  Future<List<JobApplicationModel>> getMyAssistantApplications(
    String applicantId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('job_applications_assistant')
          .where('applicantId', isEqualTo: applicantId)
          .get();

      final applications = querySnapshot.docs
          .map(
            (doc) => JobApplicationModel.fromMap({
              ...doc.data(),
              'applicationId': doc.id,
            }),
          )
          .toList();

      // Sort by appliedAt in descending order locally
      applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

      return applications;
    } catch (e) {
      throw Exception('การดึงใบสมัครงานผู้ช่วยทันตแพทย์ไม่สำเร็จ: $e');
    }
  }

  /// Get applicants for my jobs (for clinics) - fetches from both dentist and assistant collections
  Future<List<JobApplicationModel>> getApplicantsForMyJobs(
    String clinicId,
  ) async {
    try {
      // Fetch from both collections in parallel
      final dentistQuery = _firestore
          .collection('job_applications_dentist')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      final assistantQuery = _firestore
          .collection('job_applications_assistant')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      // Wait for both queries to complete
      final results = await Future.wait([dentistQuery, assistantQuery]);
      final dentistSnapshot = results[0];
      final assistantSnapshot = results[1];

      // Process dentist applications
      final dentistApplicants = dentistSnapshot.docs
          .map(
            (doc) => JobApplicationModel.fromMap({
              ...doc.data(),
              'applicationId': doc.id,
            }),
          )
          .toList();

      // Process assistant applications
      final assistantApplicants = assistantSnapshot.docs
          .map(
            (doc) => JobApplicationModel.fromMap({
              ...doc.data(),
              'applicationId': doc.id,
            }),
          )
          .toList();

      // Combine both lists
      final allApplicants = [...dentistApplicants, ...assistantApplicants];

      // Sort by appliedAt in descending order
      allApplicants.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

      return allApplicants;
    } catch (e) {
      throw Exception('การดึงผู้สมัครไม่สำเร็จ: $e');
    }
  }

  /// Get assistant job applicants for my jobs (for clinics) - only assistant applications
  Future<List<JobApplicationModel>> getAssistantApplicantsForMyJobs(
    String clinicId,
  ) async {
    try {
      final assistantQuery = await _firestore
          .collection('job_applications_assistant')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      final assistantApplicants = assistantQuery.docs
          .map(
            (doc) => JobApplicationModel.fromMap({
              ...doc.data(),
              'applicationId': doc.id,
            }),
          )
          .toList();

      // Sort by appliedAt in descending order
      assistantApplicants.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

      return assistantApplicants;
    } catch (e) {
      throw Exception('การดึงผู้สมัครงานผู้ช่วยทันตแพทย์ไม่สำเร็จ: $e');
    }
  }

  /// Update application status (for clinics) - tries both collections
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String newStatus,
    String? notes,
    DateTime? interviewDate,
    String? interviewLocation,
    String? collectionName,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }
      if (interviewDate != null) {
        updateData['interviewDate'] = interviewDate.millisecondsSinceEpoch;
      }
      if (interviewLocation != null) {
        updateData['interviewLocation'] = interviewLocation;
      }

      // If collection name is provided, use it directly to avoid permission errors
      if (collectionName != null) {
        try {
          await _firestore
              .collection(collectionName)
              .doc(applicationId)
              .update(updateData);
          return true;
        } catch (e) {
          throw Exception('ไม่พบใบสมัครในระบบ ($collectionName)');
        }
      }

      // Try to update in dentist applications collection first
      try {
        await _firestore
            .collection('job_applications_dentist')
            .doc(applicationId)
            .update(updateData);
        return true;
      } catch (e) {
        // If not found in dentist collection, try assistant collection
        try {
          await _firestore
              .collection('job_applications_assistant')
              .doc(applicationId)
              .update(updateData);
          return true;
        } catch (e2) {
          // If not found in either collection, throw error
          throw Exception('ไม่พบใบสมัครในระบบ');
        }
      }
    } catch (e) {
      throw Exception('การอัปเดตสถานะใบสมัครไม่สำเร็จ: $e');
    }
  }

  /// Load applications for a specific job (for clinics)
  Future<List<JobApplicationModel>> loadJobApplications(String jobId) async {
    try {
      final querySnapshot = await _firestore
          .collection('job_posts_dentist')
          .doc(jobId)
          .collection('applications')
          .orderBy('appliedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => JobApplicationModel.fromMap({
              ...doc.data(),
              'applicationId': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('การโหลดใบสมัครงานไม่สำเร็จ: $e');
    }
  }

  /// Load user applications from user sub-collection (new structure)
  Future<List<JobApplicationModel>> loadUserApplicationsFromUserCollection(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('applications')
          .orderBy('appliedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => JobApplicationModel.fromMap({
              ...doc.data(),
              'applicationId': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('การโหลดใบสมัครจากคอลเลกชันผู้ใช้ไม่สำเร็จ: $e');
    }
  }

  /// Update application status in both locations (new structure)
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
      final updateData = {
        'status': newStatus,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }
      if (interviewDate != null) {
        updateData['interviewDate'] = interviewDate.millisecondsSinceEpoch;
      }
      if (interviewLocation != null) {
        updateData['interviewLocation'] = interviewLocation;
      }

      // Update in job_posts_dentist sub-collection
      await _firestore
          .collection('job_posts_dentist')
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

      return true;
    } catch (e) {
      throw Exception('การอัปเดตสถานะใบสมัครไม่สำเร็จ: $e');
    }
  }

  /// Submit application using new structure (stores in both job and user collections)
  Future<bool> submitApplication({
    required String jobId,
    required String applicantId,
    required JobApplicationModel application,
  }) async {
    try {
      final applicationId = application.applicationId;

      // Store application under jobPosting
      await _firestore
          .collection('job_posts_dentist')
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
      await _firestore.collection('job_posts_dentist').doc(jobId).update({
        'applicationCount': FieldValue.increment(1),
        'applicationIds': FieldValue.arrayUnion([applicationId]),
      });

      return true;
    } catch (e) {
      throw Exception('การส่งใบสมัครไม่สำเร็จ: $e');
    }
  }

  /// Get my dentist job applications
  Future<List<JobApplicationModel>> getMyDentistApplications(
    String applicantId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('job_applications_dentist')
          .where('applicantId', isEqualTo: applicantId)
          .get();

      final applications = querySnapshot.docs
          .map(
            (doc) => JobApplicationModel.fromMap({
              ...doc.data(),
              'applicationId': doc.id,
            }),
          )
          .toList();

      // Sort by appliedAt in descending order locally
      applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

      return applications;
    } catch (e) {
      throw Exception('การดึงใบสมัครงานทันตแพทย์ไม่สำเร็จ: $e');
    }
  }
}
