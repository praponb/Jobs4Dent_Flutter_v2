import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';

/// Service class for job search functionality
class JobSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search jobs with filters
  Future<List<JobModel>> searchJobs({
    String? keyword,
    String? province,
    String? jobCategory,
    String? experienceLevel,
    String? minSalary,
    String? userId, // For matching calculation
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
      // Use a simple query to get newest 50 jobs by highest ID
      // Order by jobId descending to get newest posts first
      Query query = _firestore.collection('job_posts_dentist')
          .where('isActive', isEqualTo: true)
          .orderBy('jobId', descending: true)
          .limit(50); // Get only 50 newest jobs directly from Firebase

      final querySnapshot = await query.get();

      List<JobModel> jobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Apply all filters client-side to avoid composite index issues
      if (keyword != null && keyword.isNotEmpty) {
        jobs = jobs.where((job) =>
            job.title.toLowerCase().contains(keyword.toLowerCase()) ||
            job.description.toLowerCase().contains(keyword.toLowerCase()) ||
            job.clinicName.toLowerCase().contains(keyword.toLowerCase())).toList();
      }

      if (province != null && province.isNotEmpty) {
        jobs = jobs.where((job) => job.province == province).toList();
      }
      
      if (jobCategory != null && jobCategory.isNotEmpty) {
        jobs = jobs.where((job) => job.jobCategory == jobCategory).toList();
      }
      
      if (experienceLevel != null && experienceLevel.isNotEmpty) {
        jobs = jobs.where((job) => job.experienceLevel == experienceLevel).toList();
      }

      if (minSalary != null && minSalary.isNotEmpty) {
        final minSalaryNum = double.tryParse(minSalary);
        if (minSalaryNum != null) {
          jobs = jobs.where((job) {
            if (job.minSalary == null || job.minSalary!.isEmpty) return false;
            final jobSalary = double.tryParse(job.minSalary!);
            return jobSalary != null && jobSalary >= minSalaryNum;
          }).toList();
        }
      }

      if (title != null && title.isNotEmpty) {
        jobs = jobs.where((job) => job.title.toLowerCase().contains(title.toLowerCase())).toList();
      }

      if (description != null && description.isNotEmpty) {
        jobs = jobs.where((job) => job.description.toLowerCase().contains(description.toLowerCase())).toList();
      }

      if (minExperienceYears != null && minExperienceYears.isNotEmpty) {
        final minExpNum = int.tryParse(minExperienceYears);
        if (minExpNum != null) {
          jobs = jobs.where((job) {
            if (job.minExperienceYears == null || job.minExperienceYears!.isEmpty) return false;
            final jobExp = int.tryParse(job.minExperienceYears!);
            return jobExp != null && jobExp >= minExpNum;
          }).toList();
        }
      }

      if (salaryType != null && salaryType.isNotEmpty) {
        jobs = jobs.where((job) => job.salaryType == salaryType).toList();
      }

      if (perks != null && perks.isNotEmpty) {
        jobs = jobs.where((job) => job.perks != null && job.perks!.toLowerCase().contains(perks.toLowerCase())).toList();
      }

      if (city != null && city.isNotEmpty) {
        jobs = jobs.where((job) => job.city == city).toList();
      }

      if (trainLine != null && trainLine.isNotEmpty) {
        jobs = jobs.where((job) => job.trainLine != null && job.trainLine == trainLine).toList();
      }

      if (trainStation != null && trainStation.isNotEmpty) {
        jobs = jobs.where((job) => job.trainStation != null && job.trainStation == trainStation).toList();
      }

      if (workingDays != null && workingDays.isNotEmpty) {
        jobs = jobs.where((job) => job.workingDays != null && 
                                   job.workingDays!.toLowerCase().contains(workingDays.toLowerCase())).toList();
      }

      if (workingHours != null && workingHours.isNotEmpty) {
        jobs = jobs.where((job) => job.workingHours != null && 
                                   job.workingHours!.toLowerCase().contains(workingHours.toLowerCase())).toList();
      }

      if (additionalRequirements != null && additionalRequirements.isNotEmpty) {
        jobs = jobs.where((job) => job.additionalRequirements != null && 
                                   job.additionalRequirements!.toLowerCase().contains(additionalRequirements.toLowerCase())).toList();
      }

      // No need to limit here since we already got 50 from Firebase

      // Calculate matching scores if userId is provided
      if (userId != null) {
        jobs = await calculateMatchingScores(jobs, userId);
      }

      return jobs;
    } catch (e) {
      throw Exception('การค้นหางานไม่สำเร็จ: $e');
    }
  }

  /// Search jobs with filters - Alternative approach without composite indexes
  Future<List<JobModel>> searchJobsAlternative({
    String? keyword,
    String? province,
    String? jobCategory,
    String? experienceLevel,
    String? minSalary,
    String? userId, // For matching calculation
  }) async {
    try {
      // Use the simplest query to get newest 50 jobs by highest ID
      Query query = _firestore.collection('job_posts_dentist')
          .where('isActive', isEqualTo: true)
          .orderBy('jobId', descending: true)
          .limit(50);

      final querySnapshot = await query.get();

      List<JobModel> jobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Apply all filters client-side
      if (keyword != null && keyword.isNotEmpty) {
        jobs = jobs.where((job) =>
            job.title.toLowerCase().contains(keyword.toLowerCase()) ||
            job.description.toLowerCase().contains(keyword.toLowerCase()) ||
            job.clinicName.toLowerCase().contains(keyword.toLowerCase())).toList();
      }

      if (province != null && province.isNotEmpty) {
        jobs = jobs.where((job) => job.province == province).toList();
      }
      
      if (jobCategory != null && jobCategory.isNotEmpty) {
        jobs = jobs.where((job) => job.jobCategory == jobCategory).toList();
      }
      
      if (experienceLevel != null && experienceLevel.isNotEmpty) {
        jobs = jobs.where((job) => job.experienceLevel == experienceLevel).toList();
      }

      if (minSalary != null && minSalary.isNotEmpty) {
        final minSalaryNum = double.tryParse(minSalary);
        if (minSalaryNum != null) {
          jobs = jobs.where((job) {
            if (job.minSalary == null || job.minSalary!.isEmpty) return false;
            final jobSalary = double.tryParse(job.minSalary!);
            return jobSalary != null && jobSalary >= minSalaryNum;
          }).toList();
        }
      }

      // No need to limit here since we already got 50 from Firebase

      // Calculate matching scores if userId is provided
      if (userId != null) {
        jobs = await calculateMatchingScores(jobs, userId);
      }

      return jobs;
    } catch (e) {
      throw Exception('การค้นหางานไม่สำเร็จ: $e');
    }
  }

  /// Calculate matching scores for jobs based on user profile
  Future<List<JobModel>> calculateMatchingScores(List<JobModel> jobs, String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return jobs;

      final user = UserModel.fromMap(userDoc.data()!);
      
      for (int i = 0; i < jobs.length; i++) {
        final job = jobs[i];
        double score = 0.0;
        int factors = 0;

        // Location matching (30% weight)
        if (user.workLocationPreference?.contains(job.province) ?? false) {
          score += 30;
        }
        factors++;

        // Experience matching (20% weight)
        if (job.minExperienceYears != null && job.minExperienceYears!.isNotEmpty && user.yearsOfExperience != null) {
          final userExperience = int.tryParse(user.yearsOfExperience!) ?? 0;
          final jobMinExp = int.tryParse(job.minExperienceYears!) ?? 0;
          if (userExperience >= jobMinExp) {
            score += 20;
          } else if (jobMinExp > 0) {
            score += (userExperience / jobMinExp) * 20;
          }
        }
        factors++;

        jobs[i] = job.copyWith(matchingScore: factors > 0 ? score / factors : 0);
      }

      // Sort by matching score
      jobs.sort((a, b) => (b.matchingScore ?? 0).compareTo(a.matchingScore ?? 0));
      return jobs;
    } catch (e) {
      debugPrint('Error calculating matching scores: $e');
      return jobs;
    }
  }
} 