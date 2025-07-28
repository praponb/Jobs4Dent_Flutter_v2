class UserModel {
  final String userId;
  final String email;
  final String userName;
  final String? profilePhotoUrl;
  final bool isDentist; // True for Dentist, False for Clinic Owner
  final String userType; // 'dentist', 'assistant', 'clinic', 'seller', 'sales', 'admin'
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Authentication fields
  final bool isEmailVerified;
  final String authProvider; // 'email', 'google', 'apple', etc.
  
  // Role and permissions
  final List<String> roles; // Multiple roles support
  final String currentRole; // Currently active role
  final Map<String, dynamic>? permissions; // Role-based permissions
  
  // Sub-user support
  final String? parentUserId; // For sub-users, references parent account
  final bool isMainAccount; // True for main accounts, false for sub-users
  final List<String>? subUserIds; // For main accounts, list of sub-user IDs
  final String? branchName; // For sub-users, the branch they represent
  final String? branchAddress; // For sub-users, branch address
  
  // Job Application Information fields
  final String? educationLevel; // วุฒิการศึกษา
  final String? jobType; // ประเภทงานที่ต้องการ
  final double? minSalary; // รายได้ที่ต้องการขั้นต่ำ (บาท/เดือน)
  final String? maxSalary; // รายได้ที่ต้องการสูงสุด (บาท/เดือน)
  final String? jobReadiness; // ความพร้อมในการเริ่มงาน
  
  // Enhanced Profile fields
  final String? phoneNumber;
  final String? address;
  final List<String>? skills;
  final List<String>? workLocationPreference;
  final Map<String, dynamic>? availability;
  final List<Map<String, dynamic>>? education; // Enhanced education with institution, year, degree
  final List<Map<String, dynamic>>? experience; // Enhanced experience with details
  final String? clinicName;
  final String? clinicAddress;
  final List<String>? serviceTypes;
  
  // New Enhanced Fields for Profile Management
  
  // For Dentists/Assistants
  final List<String>? specialties; // Areas of expertise
  final List<String>? certifications; // Professional certifications
  final List<String>? documentUrls; // URLs of uploaded documents (licenses, CV, etc.)
  final String? currentPosition; // Current job position
  final String? yearsOfExperience; // Years of professional experience
  final List<String>? languages; // Languages spoken
  
  // For Clinics
  final String? website; // Clinic website
  final String? description; // Clinic overview/description
  final Map<String, String>? operatingHours; // Operating hours by day
  final List<String>? clinicPhotos; // URLs of clinic photos
  final List<Map<String, dynamic>>? branches; // Branch information
  final String? licenseNumber; // Clinic license number
  final String? establishedYear; // Year clinic was established
  
  // For Sales
  final List<String>? responsibilityAreas; // Areas/regions of responsibility
  final String? salesTerritory; // Sales territory
  final String? managerUserId; // ID of reporting manager
  
  // For Admin
  final bool? isSuperAdmin; // Super admin privileges
  final List<String>? managedUserTypes; // User types this admin can manage
  
  // Account status
  final bool isActive;
  final bool isProfileComplete;
  final DateTime? lastLoginAt;
  
  // Verification System
  final String verificationStatus; // 'unverified', 'pending', 'verified', 'rejected'
  final List<String>? verificationDocuments; // URLs of uploaded verification documents
  final int? verificationDocumentCounts; // Number of documents in verificationDocuments array
  final String? verificationRejectionReason; // Reason for rejection if status is 'rejected'
  final DateTime? verificationSubmittedAt; // When documents were submitted
  final DateTime? verificationReviewedAt; // When documents were reviewed
  final String? reviewedByAdminId; // Admin who reviewed the documents
  
  // Dentist Mini-Resume
  final String? educationInstitute; // University/Institution where graduated from dental school
  final String? educationSpecialist; // Institution for specialist dentistry education (if any)
  final int? experienceYears; // Years of experience after graduation
  final List<String>? coreCompetencies; // Procedures/treatments they can perform
  final List<String>? counterSkills; // Counter/reception skills
  final List<String>? softwareSkills; // Software skills
  final List<String>? eqSkills; // Emotional and social skills
  final List<String>? workLimitations; // Procedures they prefer not to do
  
  UserModel({
    required this.userId,
    required this.email,
    required this.userName,
    this.profilePhotoUrl,
    required this.isDentist,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.authProvider = 'email',
    this.roles = const [],
    required this.currentRole,
    this.permissions,
    this.parentUserId,
    this.isMainAccount = true,
    this.subUserIds,
    this.branchName,
    this.branchAddress,
    this.educationLevel,
    this.jobType,
    this.minSalary,
    this.maxSalary,
    this.jobReadiness,
    this.phoneNumber,
    this.address,
    this.skills,
    this.workLocationPreference,
    this.availability,
    this.education,
    this.experience,
    this.clinicName,
    this.clinicAddress,
    this.serviceTypes,
    this.specialties,
    this.certifications,
    this.documentUrls,
    this.currentPosition,
    this.yearsOfExperience,
    this.languages,
    this.website,
    this.description,
    this.operatingHours,
    this.clinicPhotos,
    this.branches,
    this.licenseNumber,
    this.establishedYear,
    this.responsibilityAreas,
    this.salesTerritory,
    this.managerUserId,
    this.isSuperAdmin,
    this.managedUserTypes,
    this.isActive = true,
    this.isProfileComplete = false,
    this.lastLoginAt,
    this.verificationStatus = 'unverified',
    this.verificationDocuments,
    this.verificationDocumentCounts,
    this.verificationRejectionReason,
    this.verificationSubmittedAt,
    this.verificationReviewedAt,
    this.reviewedByAdminId,
    this.educationInstitute,
    this.educationSpecialist,
    this.experienceYears,
    this.coreCompetencies,
    this.counterSkills,
    this.softwareSkills,
    this.eqSkills,
    this.workLimitations,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      userName: map['userName'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
      isDentist: map['isDentist'] ?? false,
      userType: map['userType'] ?? 'dentist',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isEmailVerified: map['isEmailVerified'] ?? false,
      authProvider: map['authProvider'] ?? 'email',
      roles: List<String>.from(map['roles'] ?? []),
      currentRole: map['currentRole'] ?? '',
      permissions: map['permissions'],
      parentUserId: map['parentUserId'],
      isMainAccount: map['isMainAccount'] ?? true,
      subUserIds: List<String>.from(map['subUserIds'] ?? []),
      branchName: map['branchName'],
      branchAddress: map['branchAddress'],
      educationLevel: map['educationLevel'],
      jobType: map['jobType'],
      minSalary: map['minSalary']?.toDouble(),
      maxSalary: map['maxSalary']?.toString(),
      jobReadiness: map['jobReadiness'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      skills: List<String>.from(map['skills'] ?? []),
      workLocationPreference: List<String>.from(map['workLocationPreference'] ?? []),
      availability: map['availability'],
      education: List<Map<String, dynamic>>.from(map['education'] ?? []),
      experience: List<Map<String, dynamic>>.from(map['experience'] ?? []),
      clinicName: map['clinicName'],
      clinicAddress: map['clinicAddress'],
      serviceTypes: List<String>.from(map['serviceTypes'] ?? []),
      specialties: List<String>.from(map['specialties'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      documentUrls: List<String>.from(map['documentUrls'] ?? []),
      currentPosition: map['currentPosition'],
      yearsOfExperience: map['yearsOfExperience'],
      languages: List<String>.from(map['languages'] ?? []),
      website: map['website'],
      description: map['description'],
      operatingHours: Map<String, String>.from(map['operatingHours'] ?? {}),
      clinicPhotos: List<String>.from(map['clinicPhotos'] ?? []),
      branches: List<Map<String, dynamic>>.from(map['branches'] ?? []),
      licenseNumber: map['licenseNumber'],
      establishedYear: map['establishedYear'],
      responsibilityAreas: List<String>.from(map['responsibilityAreas'] ?? []),
      salesTerritory: map['salesTerritory'],
      managerUserId: map['managerUserId'],
      isSuperAdmin: map['isSuperAdmin'],
      managedUserTypes: List<String>.from(map['managedUserTypes'] ?? []),
      isActive: map['isActive'] ?? true,
      isProfileComplete: map['isProfileComplete'] ?? false,
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt']) : null,
      verificationStatus: map['verificationStatus'] ?? 'unverified',
      verificationDocuments: List<String>.from(map['verificationDocuments'] ?? []),
      verificationDocumentCounts: map['verificationDocumentCounts'],
      verificationRejectionReason: map['verificationRejectionReason'],
      verificationSubmittedAt: map['verificationSubmittedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['verificationSubmittedAt']) : null,
      verificationReviewedAt: map['verificationReviewedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['verificationReviewedAt']) : null,
      reviewedByAdminId: map['reviewedByAdminId'],
      educationInstitute: map['educationInstitute'],
      educationSpecialist: map['educationSpecialist'],
      experienceYears: map['experienceYears'],
      coreCompetencies: List<String>.from(map['coreCompetencies'] ?? []),
      counterSkills: List<String>.from(map['counterSkills'] ?? []),
      softwareSkills: List<String>.from(map['softwareSkills'] ?? []),
      eqSkills: List<String>.from(map['eqSkills'] ?? []),
      workLimitations: List<String>.from(map['workLimitations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'userName': userName,
      'profilePhotoUrl': profilePhotoUrl,
      'isDentist': isDentist,
      'userType': userType,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isEmailVerified': isEmailVerified,
      'authProvider': authProvider,
      'roles': roles,
      'currentRole': currentRole,
      'permissions': permissions,
      'parentUserId': parentUserId,
      'isMainAccount': isMainAccount,
      'subUserIds': subUserIds,
      'branchName': branchName,
      'branchAddress': branchAddress,
      'educationLevel': educationLevel,
      'jobType': jobType,
      'minSalary': minSalary,
      'maxSalary': maxSalary,
      'jobReadiness': jobReadiness,
      'phoneNumber': phoneNumber,
      'address': address,
      'skills': skills,
      'workLocationPreference': workLocationPreference,
      'availability': availability,
      'education': education,
      'experience': experience,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'serviceTypes': serviceTypes,
      'specialties': specialties,
      'certifications': certifications,
      'documentUrls': documentUrls,
      'currentPosition': currentPosition,
      'yearsOfExperience': yearsOfExperience,
      'languages': languages,
      'website': website,
      'description': description,
      'operatingHours': operatingHours,
      'clinicPhotos': clinicPhotos,
      'branches': branches,
      'licenseNumber': licenseNumber,
      'establishedYear': establishedYear,
      'responsibilityAreas': responsibilityAreas,
      'salesTerritory': salesTerritory,
      'managerUserId': managerUserId,
      'isSuperAdmin': isSuperAdmin,
      'managedUserTypes': managedUserTypes,
      'isActive': isActive,
      'isProfileComplete': isProfileComplete,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'verificationStatus': verificationStatus,
      'verificationDocuments': verificationDocuments,
      'verificationDocumentCounts': verificationDocumentCounts,
      'verificationRejectionReason': verificationRejectionReason,
      'verificationSubmittedAt': verificationSubmittedAt?.millisecondsSinceEpoch,
      'verificationReviewedAt': verificationReviewedAt?.millisecondsSinceEpoch,
      'reviewedByAdminId': reviewedByAdminId,
      'educationInstitute': educationInstitute,
      'educationSpecialist': educationSpecialist,
      'experienceYears': experienceYears,
      'coreCompetencies': coreCompetencies,
      'counterSkills': counterSkills,
      'softwareSkills': softwareSkills,
      'eqSkills': eqSkills,
      'workLimitations': workLimitations,
    };
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? userName,
    String? profilePhotoUrl,
    bool? isDentist,
    String? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? authProvider,
    List<String>? roles,
    String? currentRole,
    Map<String, dynamic>? permissions,
    String? parentUserId,
    bool? isMainAccount,
    List<String>? subUserIds,
    String? branchName,
    String? branchAddress,
    String? educationLevel,
    String? jobType,
    double? minSalary,
    String? maxSalary,
    String? jobReadiness,
    String? phoneNumber,
    String? address,
    List<String>? skills,
    List<String>? workLocationPreference,
    Map<String, dynamic>? availability,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? experience,
    String? clinicName,
    String? clinicAddress,
    List<String>? serviceTypes,
    List<String>? specialties,
    List<String>? certifications,
    List<String>? documentUrls,
    String? currentPosition,
    String? yearsOfExperience,
    List<String>? languages,
    String? website,
    String? description,
    Map<String, String>? operatingHours,
    List<String>? clinicPhotos,
    List<Map<String, dynamic>>? branches,
    String? licenseNumber,
    String? establishedYear,
    List<String>? responsibilityAreas,
    String? salesTerritory,
    String? managerUserId,
    bool? isSuperAdmin,
    List<String>? managedUserTypes,
    bool? isActive,
    bool? isProfileComplete,
    DateTime? lastLoginAt,
    String? verificationStatus,
    List<String>? verificationDocuments,
    int? verificationDocumentCounts,
    String? verificationRejectionReason,
    DateTime? verificationSubmittedAt,
    DateTime? verificationReviewedAt,
    String? reviewedByAdminId,
    String? educationInstitute,
    String? educationSpecialist,
    int? experienceYears,
    List<String>? coreCompetencies,
    List<String>? counterSkills,
    List<String>? softwareSkills,
    List<String>? eqSkills,
    List<String>? workLimitations,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isDentist: isDentist ?? this.isDentist,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      authProvider: authProvider ?? this.authProvider,
      roles: roles ?? this.roles,
      currentRole: currentRole ?? this.currentRole,
      permissions: permissions ?? this.permissions,
      parentUserId: parentUserId ?? this.parentUserId,
      isMainAccount: isMainAccount ?? this.isMainAccount,
      subUserIds: subUserIds ?? this.subUserIds,
      branchName: branchName ?? this.branchName,
      branchAddress: branchAddress ?? this.branchAddress,
      educationLevel: educationLevel ?? this.educationLevel,
      jobType: jobType ?? this.jobType,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      jobReadiness: jobReadiness ?? this.jobReadiness,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      skills: skills ?? this.skills,
      workLocationPreference: workLocationPreference ?? this.workLocationPreference,
      availability: availability ?? this.availability,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      specialties: specialties ?? this.specialties,
      certifications: certifications ?? this.certifications,
      documentUrls: documentUrls ?? this.documentUrls,
      currentPosition: currentPosition ?? this.currentPosition,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      languages: languages ?? this.languages,
      website: website ?? this.website,
      description: description ?? this.description,
      operatingHours: operatingHours ?? this.operatingHours,
      clinicPhotos: clinicPhotos ?? this.clinicPhotos,
      branches: branches ?? this.branches,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      establishedYear: establishedYear ?? this.establishedYear,
      responsibilityAreas: responsibilityAreas ?? this.responsibilityAreas,
      salesTerritory: salesTerritory ?? this.salesTerritory,
      managerUserId: managerUserId ?? this.managerUserId,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      managedUserTypes: managedUserTypes ?? this.managedUserTypes,
      isActive: isActive ?? this.isActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDocuments: verificationDocuments ?? this.verificationDocuments,
      verificationDocumentCounts: verificationDocumentCounts ?? this.verificationDocumentCounts,
      verificationRejectionReason: verificationRejectionReason ?? this.verificationRejectionReason,
      verificationSubmittedAt: verificationSubmittedAt ?? this.verificationSubmittedAt,
      verificationReviewedAt: verificationReviewedAt ?? this.verificationReviewedAt,
      reviewedByAdminId: reviewedByAdminId ?? this.reviewedByAdminId,
      educationInstitute: educationInstitute ?? this.educationInstitute,
      educationSpecialist: educationSpecialist ?? this.educationSpecialist,
      experienceYears: experienceYears ?? this.experienceYears,
      coreCompetencies: coreCompetencies ?? this.coreCompetencies,
      counterSkills: counterSkills ?? this.counterSkills,
      softwareSkills: softwareSkills ?? this.softwareSkills,
      eqSkills: eqSkills ?? this.eqSkills,
      workLimitations: workLimitations ?? this.workLimitations,
    );
  }
} 