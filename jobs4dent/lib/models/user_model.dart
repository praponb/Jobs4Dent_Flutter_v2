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
  
  // Profile fields
  final String? phoneNumber;
  final String? address;
  final List<String>? skills;
  final List<String>? workLocationPreference;
  final Map<String, dynamic>? availability;
  final List<String>? education;
  final List<String>? experience;
  final String? clinicName;
  final String? clinicAddress;
  final List<String>? serviceTypes;
  
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
      education: List<String>.from(map['education'] ?? []),
      experience: List<String>.from(map['experience'] ?? []),
      clinicName: map['clinicName'],
      clinicAddress: map['clinicAddress'],
      serviceTypes: List<String>.from(map['serviceTypes'] ?? []),
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
    List<String>? education,
    List<String>? experience,
    String? clinicName,
    String? clinicAddress,
    List<String>? serviceTypes,
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
      isActive: isActive ?? this.isActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
} 