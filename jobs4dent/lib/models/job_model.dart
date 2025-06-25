class JobModel {
  final String jobId;
  final String clinicId;
  final String clinicName;
  final String? branchId;
  final String? branchName;
  final String? branchAddress;
  final String title;
  final String description;
  final String jobType; // 'full-time', 'part-time', 'freelance', 'locum'
  final String jobCategory;
  final List<String> requiredSkills;
  final List<String> requiredSpecialties;
  final String experienceLevel; // 'entry', 'mid', 'senior'
  final int? minExperienceYears;
  
  // Salary Information
  final String salaryType; // 'monthly', 'daily', 'case-based', 'hourly'
  final double? minSalary;
  final double? maxSalary;
  final String? salaryDetails;
  final String? benefits;
  final String? perks;
  
  // Location Information
  final String province;
  final String city;
  final String? address;
  final double? latitude;
  final double? longitude;
  
  // Time Information
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? workingDays; // ['monday', 'tuesday', etc.]
  final String? workingHours; // e.g., "9:00 AM - 6:00 PM"
  final bool isUrgent;
  final bool isRemote;
  
  // Requirements
  final List<String>? requiredCertifications;
  final List<String>? requiredLanguages;
  final String? additionalRequirements;
  final bool travelRequired;
  final List<String>? requiredSoftware;
  
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
    this.branchId,
    this.branchName,
    this.branchAddress,
    required this.title,
    required this.description,
    required this.jobType,
    required this.jobCategory,
    this.requiredSkills = const [],
    this.requiredSpecialties = const [],
    required this.experienceLevel,
    this.minExperienceYears,
    required this.salaryType,
    this.minSalary,
    this.maxSalary,
    this.salaryDetails,
    this.benefits,
    this.perks,
    required this.province,
    required this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.startDate,
    this.endDate,
    this.workingDays,
    this.workingHours,
    this.isUrgent = false,
    this.isRemote = false,
    this.requiredCertifications,
    this.requiredLanguages,
    this.additionalRequirements,
    this.travelRequired = false,
    this.requiredSoftware,
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
      branchId: map['branchId'],
      branchName: map['branchName'],
      branchAddress: map['branchAddress'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      jobType: map['jobType'] ?? 'full-time',
      jobCategory: map['jobCategory'] ?? '',
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      requiredSpecialties: List<String>.from(map['requiredSpecialties'] ?? []),
      experienceLevel: map['experienceLevel'] ?? 'entry',
      minExperienceYears: map['minExperienceYears'],
      salaryType: map['salaryType'] ?? 'monthly',
      minSalary: map['minSalary']?.toDouble(),
      maxSalary: map['maxSalary']?.toDouble(),
      salaryDetails: map['salaryDetails'],
      benefits: map['benefits'],
      perks: map['perks'],
      province: map['province'] ?? '',
      city: map['city'] ?? '',
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      startDate: map['startDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endDate']) : null,
      workingDays: List<String>.from(map['workingDays'] ?? []),
      workingHours: map['workingHours'],
      isUrgent: map['isUrgent'] ?? false,
      isRemote: map['isRemote'] ?? false,
      requiredCertifications: List<String>.from(map['requiredCertifications'] ?? []),
      requiredLanguages: List<String>.from(map['requiredLanguages'] ?? []),
      additionalRequirements: map['additionalRequirements'],
      travelRequired: map['travelRequired'] ?? false,
      requiredSoftware: List<String>.from(map['requiredSoftware'] ?? []),
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
      'branchId': branchId,
      'branchName': branchName,
      'branchAddress': branchAddress,
      'title': title,
      'description': description,
      'jobType': jobType,
      'jobCategory': jobCategory,
      'requiredSkills': requiredSkills,
      'requiredSpecialties': requiredSpecialties,
      'experienceLevel': experienceLevel,
      'minExperienceYears': minExperienceYears,
      'salaryType': salaryType,
      'minSalary': minSalary,
      'maxSalary': maxSalary,
      'salaryDetails': salaryDetails,
      'benefits': benefits,
      'perks': perks,
      'province': province,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'isUrgent': isUrgent,
      'isRemote': isRemote,
      'requiredCertifications': requiredCertifications,
      'requiredLanguages': requiredLanguages,
      'additionalRequirements': additionalRequirements,
      'travelRequired': travelRequired,
      'requiredSoftware': requiredSoftware,
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
    String? branchId,
    String? branchName,
    String? branchAddress,
    String? title,
    String? description,
    String? jobType,
    String? jobCategory,
    List<String>? requiredSkills,
    List<String>? requiredSpecialties,
    String? experienceLevel,
    int? minExperienceYears,
    String? salaryType,
    double? minSalary,
    double? maxSalary,
    String? salaryDetails,
    String? benefits,
    String? perks,
    String? province,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? workingDays,
    String? workingHours,
    bool? isUrgent,
    bool? isRemote,
    List<String>? requiredCertifications,
    List<String>? requiredLanguages,
    String? additionalRequirements,
    bool? travelRequired,
    List<String>? requiredSoftware,
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
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      branchAddress: branchAddress ?? this.branchAddress,
      title: title ?? this.title,
      description: description ?? this.description,
      jobType: jobType ?? this.jobType,
      jobCategory: jobCategory ?? this.jobCategory,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      requiredSpecialties: requiredSpecialties ?? this.requiredSpecialties,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      minExperienceYears: minExperienceYears ?? this.minExperienceYears,
      salaryType: salaryType ?? this.salaryType,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      salaryDetails: salaryDetails ?? this.salaryDetails,
      benefits: benefits ?? this.benefits,
      perks: perks ?? this.perks,
      province: province ?? this.province,
      city: city ?? this.city,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      isUrgent: isUrgent ?? this.isUrgent,
      isRemote: isRemote ?? this.isRemote,
      requiredCertifications: requiredCertifications ?? this.requiredCertifications,
      requiredLanguages: requiredLanguages ?? this.requiredLanguages,
      additionalRequirements: additionalRequirements ?? this.additionalRequirements,
      travelRequired: travelRequired ?? this.travelRequired,
      requiredSoftware: requiredSoftware ?? this.requiredSoftware,
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