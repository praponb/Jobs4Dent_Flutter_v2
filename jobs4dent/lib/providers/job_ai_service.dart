import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/job_model.dart';

/// Service class for AI-powered job search and matching functionality
class JobAIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search jobs by working days and hours using Gemini AI
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
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      // Prepare the data for Gemini
      final jobScheduleData = jobsWithSchedule.map((job) {
        final workingDays = job.workingDays ?? '';
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

  /// AI-powered search using Gemini 1.5 Flash
  Future<List<JobModel>> searchJobsWithAI({
    required List<JobModel> allJobs,
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
  }) async {
    try {
      if (allJobs.isEmpty) {
        return [];
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

      // If no search criteria provided, return all jobs sorted by date
      if (searchCriteria.isEmpty) {
        final sortedJobs = List<JobModel>.from(allJobs);
        sortedJobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return sortedJobs;
      }

      // Use Gemini AI for intelligent matching
      return await _performAISearch(allJobs, searchCriteria);
    } catch (e) {
      throw Exception('การค้นหางานด้วย AI ไม่สำเร็จ: $e');
    }
  }

  /// Perform AI search using Gemini
  Future<List<JobModel>> _performAISearch(List<JobModel> allJobs, Map<String, dynamic> searchCriteria) async {
    try {
      final apiKey = dotenv.env['GOOGLE_AI_STUDIO_APIKEY_AEK'] ?? '';
      
      if (apiKey.isEmpty) {
        throw Exception('Google AI Studio API key not found. Please check your .env file.');
      }
      
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // Prepare job data for AI analysis
      final jobData = allJobs.map((job) {
        return {
          'jobId': job.jobId,
          'title': job.title,
          'description': job.description,
          'clinicName': job.clinicName,
          'jobCategory': job.jobCategory,
          'experienceLevel': job.experienceLevel,
          'salaryType': job.salaryType,
          'minSalary': job.minSalary?.toString() ?? '',
          'province': job.province,
          'city': job.city,
          'trainLine': job.trainLine ?? '',
          'trainStation': job.trainStation ?? '',
          'workingDays': job.workingDays ?? '',
          'workingHours': job.workingHours ?? '',
          'additionalRequirements': job.additionalRequirements ?? '',
          'perks': job.perks ?? '',
        };
      }).toList();

      final prompt = '''
You are an intelligent job matching AI assistant for a dental job platform in Thailand. Your task is to analyze user search criteria and match them with available job posts.

User's Search Criteria:
${searchCriteria.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n')}

Available Job Posts:
${jobData.map((job) => '''
Job ID: ${job['jobId']}
Title: ${job['title']}
Description: ${job['description']}
Clinic: ${job['clinicName']}
Category: ${job['jobCategory']}
Experience: ${job['experienceLevel']}
Salary Type: ${job['salaryType']}
Min Salary: ${job['minSalary']}
Province: ${job['province']}
City: ${job['city']}
Train Line: ${job['trainLine']}
Train Station: ${job['trainStation']}
Working Days: ${job['workingDays']}
Working Hours: ${job['workingHours']}
Additional Requirements: ${job['additionalRequirements']}
Perks: ${job['perks']}
---''').join('\n')}

Please analyze the search criteria and match them intelligently with the job posts. Consider:

1. **Semantic Matching**: Match meaning, not just exact text
2. **Location Intelligence**: Understand Thai location hierarchy and nearby areas
3. **Salary Flexibility**: Consider salary ranges and types (ประจำ, part-time, etc.)
4. **Schedule Matching**: Match working days and hours flexibly
5. **Experience Level**: Match based on required vs. available experience
6. **Transport Access**: Consider train line proximity and accessibility
7. **Job Category**: Match specialties and general practice appropriately
8. **Language Understanding**: Understand Thai dental terminology and job descriptions

**Matching Rules**:
- If keyword is provided, search across title, description, clinic name, and all text fields
- Location matching should consider hierarchy (zone > province > city)
- Salary matching should be flexible (if user wants 3000+, show jobs with min salary >= 3000)
- Experience should be inclusive (if user has 2 years, show jobs requiring 0-2 years)
- Working type matching (ประจำ = full-time, part-time = part-time)
- Train line proximity should be considered for location matching

Return ONLY the Job IDs that match the search criteria, ranked by relevance.

Format your response as:
MATCHING_JOB_IDS: [jobId1, jobId2, jobId3, ...]

If no jobs match, return:
MATCHING_JOB_IDS: []
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      // Parse the response to extract job IDs
      final matchingJobIds = _parseGeminiResponse(responseText);

      // Filter and sort the matching jobs
      final matchingJobs = allJobs.where((job) => matchingJobIds.contains(job.jobId)).toList();
      
      // Sort by creation date (newest first) while preserving AI ranking for similar dates
      matchingJobs.sort((a, b) {
        final aIndex = matchingJobIds.indexOf(a.jobId);
        final bIndex = matchingJobIds.indexOf(b.jobId);
        
        // If both jobs are close in AI ranking, sort by date
        if ((aIndex - bIndex).abs() <= 2) {
          return b.createdAt.compareTo(a.createdAt);
        }
        
        // Otherwise preserve AI ranking
        return aIndex.compareTo(bIndex);
      });

      return matchingJobs;
    } catch (e) {
      if (kDebugMode) {
        print('Error in AI search: $e');
      }
      throw Exception('AI search failed: $e');
    }
  }

  /// Parse Gemini response to extract job IDs
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