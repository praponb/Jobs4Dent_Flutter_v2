import '../../models/job_model.dart';
import 'job_posting_constants.dart';

/// Utility functions for job posting screen
/// Contains helper methods for location management and form data handling
class JobPostingUtils {
  
  /// Get current location zones based on selected province
  static List<String> getCurrentLocationZones(String selectedProvince) {
    int provinceIndex = JobPostingConstants.thaiProvinceZones.indexOf(selectedProvince);
    if (provinceIndex >= 0 && provinceIndex < JobPostingConstants.thaiLocationZones.length) {
      final locationZones = JobPostingConstants.thaiLocationZones[provinceIndex];
      if (locationZones.isNotEmpty) {
        return locationZones;
      }
    }
    // Default to first zone if not found or empty
    return JobPostingConstants.thaiLocationZones.isNotEmpty && 
           JobPostingConstants.thaiLocationZones.first.isNotEmpty 
        ? JobPostingConstants.thaiLocationZones.first 
        : ['กรุงเทพฯ']; // Ultimate fallback
  }

  /// Get current train stations based on selected train line
  static List<String> getCurrentTrainStations(String selectedTrainLine) {
    int trainLineIndex = JobPostingConstants.thaiTrainLines.indexOf(selectedTrainLine);
    if (trainLineIndex >= 0 && trainLineIndex < JobPostingConstants.thaiTrainStations.length) {
      final trainStations = JobPostingConstants.thaiTrainStations[trainLineIndex];
      if (trainStations.isNotEmpty) {
        return trainStations;
      }
    }
    // Default to first station if not found or empty
    return JobPostingConstants.thaiTrainStations.isNotEmpty && 
           JobPostingConstants.thaiTrainStations.first.isNotEmpty 
        ? JobPostingConstants.thaiTrainStations.first 
        : ['ไม่ใกล้รถไฟฟ้า']; // Ultimate fallback
  }

  /// Get valid location zone - ensures the selected zone is available for the province
  static String getValidLocationZone(String selectedProvince, String currentSelection) {
    final availableLocations = getCurrentLocationZones(selectedProvince);
    if (availableLocations.contains(currentSelection)) {
      return currentSelection;
    }
    // If current selection is not valid, return first option
    if (availableLocations.isNotEmpty) {
      return availableLocations.first;
    }
    // Ultimate fallback
    return 'กรุงเทพฯ';
  }

  /// Get valid train station - ensures the selected station is available for the train line
  static String getValidTrainStation(String selectedTrainLine, String currentSelection) {
    final availableStations = getCurrentTrainStations(selectedTrainLine);
    if (availableStations.contains(currentSelection)) {
      return currentSelection;
    }
    // If current selection is not valid, return first option
    if (availableStations.isNotEmpty) {
      return availableStations.first;
    }
    // Ultimate fallback
    return 'ไม่ใกล้รถไฟฟ้า';
  }

  /// Initialize form data from existing job (for editing)
  static Map<String, dynamic> initializeFormFromJob(JobModel job) {
    return {
      'title': job.title,
      'description': job.description,
      'jobCategory': job.jobCategory,
      'experienceLevel': job.experienceLevel,
      'salaryType': job.salaryType,
      'province': job.province,
      'city': job.city,
      'trainLine': job.trainLine,
      'trainStation': job.trainStation,
      'minSalary': job.minSalary?.toString() ?? '',
      'perks': job.perks ?? '',
      'workingDays': job.workingDays ?? '',
      'workingHours': job.workingHours ?? '',
      'additionalRequirements': job.additionalRequirements ?? '',
      'workingType': JobPostingConstants.workingTypes.first,
    };
  }

  /// Validate and get proper location selection for editing
  static Map<String, String> validateLocationForEditing(JobModel job) {
    String selectedProvince = job.province;
    String selectedCity = job.city;
    
    // Ensure province exists
    if (!JobPostingConstants.thaiProvinceZones.contains(selectedProvince)) {
      selectedProvince = JobPostingConstants.thaiProvinceZones.first;
    }
    
    // Ensure city is valid for the province
    final availableLocations = getCurrentLocationZones(selectedProvince);
    if (!availableLocations.contains(selectedCity)) {
      selectedCity = availableLocations.first;
    }
    
    return {
      'province': selectedProvince,
      'city': selectedCity,
    };
  }

  /// Validate and get proper train selection for editing
  static Map<String, String> validateTrainForEditing(JobModel job) {
    String selectedTrainLine = job.trainLine ?? 'ไม่ใกล้รถไฟฟ้า';
    String selectedTrainStation = job.trainStation ?? 'ไม่ใกล้รถไฟฟ้า';
    
    // Ensure train line exists
    if (!JobPostingConstants.thaiTrainLines.contains(selectedTrainLine)) {
      selectedTrainLine = JobPostingConstants.thaiTrainLines.first;
    }
    
    // Ensure station is valid for the train line
    final availableStations = getCurrentTrainStations(selectedTrainLine);
    if (!availableStations.contains(selectedTrainStation)) {
      selectedTrainStation = availableStations.first;
    }
    
    return {
      'trainLine': selectedTrainLine,
      'trainStation': selectedTrainStation,
    };
  }

  /// Create JobModel from form data
  static JobModel createJobFromFormData({
    required String jobId,
    required String clinicId,
    required String clinicName,
    required String title,
    required String description,
    required String jobCategory,
    required String experienceLevel,
    required String salaryType,
    required String province,
    required String city,
    required String trainLine,
    required String trainStation,
    String? minSalary,
    String? perks,
    String? workingDays,
    String? workingHours,
    String? additionalRequirements,
    String? selectedWorkingType,
    DateTime? existingCreatedAt,
  }) {
    final now = DateTime.now();
    
    return JobModel(
      jobId: jobId,
      clinicId: clinicId,
      clinicName: clinicName,
      title: title.trim(),
      description: description.trim(),
      jobCategory: jobCategory,
      experienceLevel: experienceLevel,
      salaryType: salaryType,
      minSalary: minSalary != null && minSalary.isNotEmpty 
          ? minSalary.trim() 
          : null,
      perks: perks != null && perks.trim().isNotEmpty 
          ? perks.trim() 
          : null,
      province: province,
      city: city,
      trainLine: trainLine != 'ไม่ใกล้รถไฟฟ้า' ? trainLine : null,
      trainStation: trainStation != 'ไม่ใกล้รถไฟฟ้า' ? trainStation : null,
      workingDays: _getWorkingDays(workingDays, selectedWorkingType),
      workingHours: workingHours != null && workingHours.trim().isNotEmpty 
          ? workingHours.trim() 
          : null,
      additionalRequirements: additionalRequirements != null && 
                             additionalRequirements.trim().isNotEmpty 
          ? additionalRequirements.trim() 
          : null,
      createdAt: existingCreatedAt ?? now,
      updatedAt: now,
    );
  }

  /// Helper to get working days from text input or selected type
  static String? _getWorkingDays(String? workingDaysText, String? selectedWorkingType) {
    if (workingDaysText != null && workingDaysText.trim().isNotEmpty) {
      return workingDaysText.trim();
    }
    
    if (selectedWorkingType != null && selectedWorkingType.isNotEmpty) {
      return selectedWorkingType;
    }
    
    return null;
  }

  /// Validate form data before submission
  static Map<String, String> validateFormData({
    required String title,
    required String description,
    String? minSalary,
  }) {
    Map<String, String> errors = {};
    
    if (title.trim().isEmpty) {
      errors['title'] = 'ต้องระบุหัวข้อ';
    }
    
    if (description.trim().isEmpty) {
      errors['description'] = 'ต้องระบุรายละเอียดงาน';
    }
    
    if (minSalary != null && minSalary.isNotEmpty) {
      final parsedSalary = double.tryParse(minSalary);
      if (parsedSalary == null) {
        errors['minSalary'] = 'กรุณาใส่ตัวเลขที่ถูกต้อง';
      } else if (parsedSalary < 0) {
        errors['minSalary'] = 'เงินเดือนต้องเป็นจำนวนเงินที่ถูกต้อง';
      }
    }
    
    return errors;
  }

  /// Get default form values for new job posting
  static Map<String, dynamic> getDefaultFormValues() {
    return {
      'jobCategory': 'ทันตแพทย์ทั่วไป',
      'experienceLevel': 'ไม่มีประสบการณ์',
      'salaryType': '50:50',
      'province': JobPostingConstants.thaiProvinceZones.first,
      'city': JobPostingConstants.thaiLocationZones.first.first,
      'trainLine': JobPostingConstants.thaiTrainLines.last, // 'ไม่ใกล้รถไฟฟ้า'
      'trainStation': JobPostingConstants.thaiTrainStations.last.first, // 'ไม่ใกล้รถไฟฟ้า'
      'workingType': JobPostingConstants.workingTypes.first,
    };
  }

  /// Check if train line/station should be displayed (not "ไม่ใกล้รถไฟฟ้า")
  static bool shouldDisplayTrainInfo(String trainLine, String trainStation) {
    return trainLine != 'ไม่ใกล้รถไฟฟ้า' && trainStation != 'ไม่ใกล้รถไฟฟ้า';
  }

  /// Format working days for display
  static String formatWorkingDaysForDisplay(String? workingDays) {
    if (workingDays == null || workingDays.isEmpty) {
      return 'ไม่ระบุ';
    }
    return workingDays;
  }

  /// Format salary for display
  static String formatSalaryForDisplay(double? salary) {
    if (salary == null) {
      return 'ไม่ระบุ';
    }
    return '${salary.toStringAsFixed(0)} บาท/วัน';
  }
} 