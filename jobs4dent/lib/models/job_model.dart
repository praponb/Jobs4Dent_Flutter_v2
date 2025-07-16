class JobModel {
  final String jobId;
  final String clinicId;
  final String clinicName;
  final String title;
  final String description;
  final String jobCategory;
  final String experienceLevel;
  final int? minExperienceYears;
  
  // Salary Information
  final String salaryType;
  final double? minSalary;
  final String? perks;
  
  // Location Information  
  final String province;
  final String city;
  final String? trainLine;
  final String? trainStation;
  
  // Time Information
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? workingDays;
  final String? workingHours;
  
  // Requirements
  final String? additionalRequirements;
  
  // Application Information
  final List<String> applicationIds;
  final int applicationCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deadline;
  
  // Matching Score (for search results)
  final double? matchingScore;

  JobModel({
    required this.jobId,
    required this.clinicId,
    required this.clinicName,
    required this.title,
    required this.description,
    required this.jobCategory,
    required this.experienceLevel,
    this.minExperienceYears,
    required this.salaryType,
    this.minSalary,
    this.perks,
    required this.province,
    required this.city,
    this.trainLine,
    this.trainStation,
    this.startDate,
    this.endDate,
    this.workingDays,
    this.workingHours,
    this.additionalRequirements,
    this.applicationIds = const [],
    this.applicationCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deadline,
    this.matchingScore,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      jobId: map['jobId'] ?? '',
      clinicId: map['clinicId'] ?? '',
      clinicName: map['clinicName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      jobCategory: map['jobCategory'] ?? '',
      experienceLevel: map['experienceLevel'] ?? '1',
      minExperienceYears: map['minExperienceYears'],
      salaryType: map['salaryType'] ?? '50:50',
      minSalary: map['minSalary']?.toDouble(),
      perks: map['perks'],
      province: map['province'] ?? '',
      city: map['city'] ?? '',
      trainLine: map['trainLine'],
      trainStation: map['trainStation'],
      startDate: map['startDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endDate']) : null,
      workingDays: List<String>.from(map['workingDays'] ?? []),
      workingHours: map['workingHours'],
      additionalRequirements: map['additionalRequirements'],
      applicationIds: List<String>.from(map['applicationIds'] ?? []),
      applicationCount: map['applicationCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      deadline: map['deadline'] != null ? DateTime.fromMillisecondsSinceEpoch(map['deadline']) : null,
      matchingScore: map['matchingScore']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'title': title,
      'description': description,
      'jobCategory': jobCategory,
      'experienceLevel': experienceLevel,
      'minExperienceYears': minExperienceYears,
      'salaryType': salaryType,
      'minSalary': minSalary,
      'perks': perks,
      'province': province,
      'city': city,
      'trainLine': trainLine,
      'trainStation': trainStation,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'additionalRequirements': additionalRequirements,
      'applicationIds': applicationIds,
      'applicationCount': applicationCount,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'deadline': deadline?.millisecondsSinceEpoch,
      'matchingScore': matchingScore,
    };
  }

  JobModel copyWith({
    String? jobId,
    String? clinicId,
    String? clinicName,
    String? title,
    String? description,
    String? jobCategory,
    String? experienceLevel,
    int? minExperienceYears,
    String? salaryType,
    double? minSalary,
    String? perks,
    String? province,
    String? city,
    String? trainLine,
    String? trainStation,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? workingDays,
    String? workingHours,
    String? additionalRequirements,
    List<String>? applicationIds,
    int? applicationCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deadline,
    double? matchingScore,
  }) {
    return JobModel(
      jobId: jobId ?? this.jobId,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      title: title ?? this.title,
      description: description ?? this.description,
      jobCategory: jobCategory ?? this.jobCategory,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      minExperienceYears: minExperienceYears ?? this.minExperienceYears,
      salaryType: salaryType ?? this.salaryType,
      minSalary: minSalary ?? this.minSalary,
      perks: perks ?? this.perks,
      province: province ?? this.province,
      city: city ?? this.city,
      trainLine: trainLine ?? this.trainLine,
      trainStation: trainStation ?? this.trainStation,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      additionalRequirements: additionalRequirements ?? this.additionalRequirements,
      applicationIds: applicationIds ?? this.applicationIds,
      applicationCount: applicationCount ?? this.applicationCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deadline: deadline ?? this.deadline,
      matchingScore: matchingScore ?? this.matchingScore,
    );
  }
} 