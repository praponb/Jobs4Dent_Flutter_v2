import 'package:flutter/material.dart';
import '../../providers/job_provider.dart';
import 'job_posting_constants.dart';

/// Helper class to manage advanced search form state and logic
class AdvancedSearchFormHelper {
  // Text Controllers
  final TextEditingController keywordController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController trainLineController = TextEditingController();
  final TextEditingController trainStationController = TextEditingController();
  final TextEditingController minSalaryController = TextEditingController();
  final TextEditingController maxSalaryController = TextEditingController();
  final TextEditingController workingHoursController = TextEditingController();
  final TextEditingController additionalRequirementsController = TextEditingController();
  
  // Dropdown selections
  String? selectedJobCategory;
  String? selectedExperienceLevel;
  String? selectedSalaryType;
  String? selectedWorkingType;
  
  // Date selections
  DateTime? startDate;
  DateTime? endDate;
  
  // Multi-select options
  final List<String> selectedWorkingDays = [];
  
  // Hierarchical selections
  int? selectedProvinceZoneIndex;
  String? selectedLocation;
  int? selectedTrainLineIndex;
  String? selectedTrainStation;

  /// Dispose all text controllers
  void dispose() {
    keywordController.dispose();
    provinceController.dispose();
    cityController.dispose();
    trainLineController.dispose();
    trainStationController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    workingHoursController.dispose();
    additionalRequirementsController.dispose();
  }

  /// Load saved search state from job provider
  void loadSavedSearchState(JobProvider jobProvider) {
    final savedState = jobProvider.savedAdvancedSearchState;
    
    if (savedState != null) {
      // Restore text controllers
      keywordController.text = savedState['keyword'] ?? '';
      minSalaryController.text = savedState['minSalary'] ?? '';
      maxSalaryController.text = savedState['maxSalary'] ?? '';
      workingHoursController.text = savedState['workingHours'] ?? '';
      additionalRequirementsController.text = savedState['additionalRequirements'] ?? '';
      
      // Restore dropdown selections
      selectedJobCategory = savedState['selectedJobCategory'];
      selectedExperienceLevel = savedState['selectedExperienceLevel'];
      selectedSalaryType = savedState['selectedSalaryType'];
      selectedWorkingType = savedState['selectedWorkingType'];
      
      // Restore location selections
      selectedProvinceZoneIndex = savedState['selectedProvinceZoneIndex'];
      selectedLocation = savedState['selectedLocation'];
      
      // Restore train selections
      selectedTrainLineIndex = savedState['selectedTrainLineIndex'];
      selectedTrainStation = savedState['selectedTrainStation'];
      
      // Restore working days
      final workingDays = savedState['selectedWorkingDays'];
      if (workingDays != null && workingDays is List) {
        selectedWorkingDays.clear();
        selectedWorkingDays.addAll(List<String>.from(workingDays));
      }
      
      // Restore dates
      if (savedState['startDate'] != null) {
        startDate = DateTime.parse(savedState['startDate']);
      }
      if (savedState['endDate'] != null) {
        endDate = DateTime.parse(savedState['endDate']);
      }
      
      // Update controllers based on selections
      _updateControllersFromSelections();
    }
  }

  /// Update text controllers based on dropdown selections
  void _updateControllersFromSelections() {
    if (selectedProvinceZoneIndex != null) {
      provinceController.text = JobPostingConstants.thaiProvinceZones[selectedProvinceZoneIndex!];
    }
    if (selectedLocation != null) {
      cityController.text = selectedLocation!;
    }
    if (selectedTrainLineIndex != null) {
      trainLineController.text = JobPostingConstants.thaiTrainLines[selectedTrainLineIndex!];
    }
    if (selectedTrainStation != null) {
      trainStationController.text = selectedTrainStation!;
    }
  }

  /// Handle province zone selection change
  void onProvinceZoneChanged(int? value, VoidCallback setState) {
    selectedProvinceZoneIndex = value;
    selectedLocation = null; // Reset location when province changes
    provinceController.text = value != null ? JobPostingConstants.thaiProvinceZones[value] : '';
    cityController.clear();
    setState();
  }

  /// Handle location selection change
  void onLocationChanged(String? value, VoidCallback setState) {
    selectedLocation = value;
    cityController.text = value ?? '';
    setState();
  }

  /// Handle train line selection change
  void onTrainLineChanged(int? value, VoidCallback setState) {
    selectedTrainLineIndex = value;
    selectedTrainStation = null; // Reset station when line changes
    trainLineController.text = value != null ? JobPostingConstants.thaiTrainLines[value] : '';
    trainStationController.clear();
    setState();
  }

  /// Handle train station selection change
  void onTrainStationChanged(String? value, VoidCallback setState) {
    selectedTrainStation = value;
    trainStationController.text = value ?? '';
    setState();
  }

  /// Handle working day toggle
  void onWorkingDayToggled(String day, bool selected, VoidCallback setState) {
    if (selected) {
      selectedWorkingDays.add(day);
    } else {
      selectedWorkingDays.remove(day);
    }
    setState();
  }

  /// Save current state to job provider and perform search
  void saveStateAndSearch(JobProvider jobProvider, String? userId) {
    // Save current search form state
    jobProvider.saveAdvancedSearchState(
      keyword: keywordController.text,
      selectedProvinceZoneIndex: selectedProvinceZoneIndex,
      selectedLocation: selectedLocation,
      selectedJobCategory: selectedJobCategory,
      selectedExperienceLevel: selectedExperienceLevel,
      selectedSalaryType: selectedSalaryType,
      minSalary: minSalaryController.text,
      maxSalary: maxSalaryController.text,
      selectedTrainLineIndex: selectedTrainLineIndex,
      selectedTrainStation: selectedTrainStation,
      selectedWorkingType: selectedWorkingType,
      selectedWorkingDays: selectedWorkingDays,
      workingHours: workingHoursController.text,
      startDate: startDate,
      endDate: endDate,
      additionalRequirements: additionalRequirementsController.text,
    );
    
    // Perform AI-powered search
    jobProvider.searchJobsWithAI(
      keyword: keywordController.text.trim().isEmpty ? null : keywordController.text.trim(),
      province: selectedProvinceZoneIndex != null ? JobPostingConstants.thaiProvinceZones[selectedProvinceZoneIndex!] : null,
      city: selectedLocation,
      jobCategory: selectedJobCategory,
      experienceLevel: selectedExperienceLevel,
      salaryType: selectedSalaryType,
      minSalary: minSalaryController.text.trim().isEmpty ? null : minSalaryController.text.trim(),
      maxSalary: maxSalaryController.text.trim().isEmpty ? null : maxSalaryController.text.trim(),
      startDate: startDate,
      endDate: endDate,
      trainLine: selectedTrainLineIndex != null ? JobPostingConstants.thaiTrainLines[selectedTrainLineIndex!] : null,
      trainStation: selectedTrainStation,
      workingDays: selectedWorkingDays.isEmpty ? null : selectedWorkingDays,
      workingHours: workingHoursController.text.trim().isEmpty ? null : workingHoursController.text.trim(),
      additionalRequirements: additionalRequirementsController.text.trim().isEmpty ? null : additionalRequirementsController.text.trim(),
      workingType: selectedWorkingType,
      userId: userId,
    );
  }

  /// Clear all form fields and selections
  void clearAllFilters(JobProvider jobProvider, VoidCallback setState) {
    // Clear saved state in provider
    jobProvider.clearAdvancedSearchState();
    
    // Clear text controllers
    keywordController.clear();
    provinceController.clear();
    cityController.clear();
    trainLineController.clear();
    trainStationController.clear();
    minSalaryController.clear();
    maxSalaryController.clear();
    workingHoursController.clear();
    additionalRequirementsController.clear();
    
    // Clear dropdown selections
    selectedJobCategory = null;
    selectedExperienceLevel = null;
    selectedSalaryType = null;
    selectedWorkingType = null;
    
    // Clear date selections
    startDate = null;
    endDate = null;
    
    // Clear multi-select
    selectedWorkingDays.clear();
    
    // Clear hierarchical selections
    selectedProvinceZoneIndex = null;
    selectedLocation = null;
    selectedTrainLineIndex = null;
    selectedTrainStation = null;
    
    setState();
  }

  /// Show date picker
  Future<void> selectDate({
    required BuildContext context,
    required bool isStartDate,
    required VoidCallback setState,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? startDate : endDate) ?? DateTime.now(),
      firstDate: isStartDate ? DateTime.now() : (startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      if (isStartDate) {
        startDate = date;
      } else {
        endDate = date;
      }
      setState();
    }
  }
} 