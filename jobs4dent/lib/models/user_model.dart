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
    );
  }
} 