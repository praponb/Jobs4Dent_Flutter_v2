import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

/// Service class for job CRUD operations
class JobManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Post a new job (for clinics)
  Future<bool> postJob(JobModel job) async {
    try {
      await _firestore.collection('job_posts').doc(job.jobId).set(job.toMap());
      return true;
    } catch (e) {
      throw Exception('การโพสต์งานไม่สำเร็จ: $e');
    }
  }

  /// Update an existing job
  Future<bool> updateJob(JobModel updatedJob) async {
    try {
      await _firestore.collection('job_posts').doc(updatedJob.jobId).update(
        updatedJob.copyWith(updatedAt: DateTime.now()).toMap(),
      );
      return true;
    } catch (e) {
      throw Exception('การอัปเดตงานไม่สำเร็จ: $e');
    }
  }

  /// Delete a job
  Future<bool> deleteJob(String jobId) async {
    try {
      await _firestore.collection('job_posts').doc(jobId).delete();
      return true;
    } catch (e) {
      throw Exception('การลบงานไม่สำเร็จ: $e');
    }
  }

  /// Get my posted jobs (for clinics)
  Future<List<JobModel>> getMyPostedJobs(String clinicId) async {
    try {
      final querySnapshot = await _firestore
          .collection('job_posts')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      final jobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data()))
          .toList();
      
      // Sort by createdAt descending on the client side to avoid composite index
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return jobs;
    } catch (e) {
      throw Exception('การดึงงานที่โพสต์ไม่สำเร็จ: $e');
    }
  }

  /// Get job by ID
  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await _firestore.collection('job_posts').doc(jobId).get();
      if (doc.exists) {
        return JobModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('การดึงรายละเอียดงานไม่สำเร็จ: $e');
    }
  }
} 