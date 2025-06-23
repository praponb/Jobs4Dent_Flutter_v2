class UserModel {
  final String userId;
  final String email;
  final String userName;
  final String? profilePhotoUrl;
  final bool isDentist; // True for Dentist, False for Clinic Owner
  final String userType; // 'dentist', 'assistant', 'clinic', 'seller', 'sales', 'admin'
  final DateTime createdAt;
  final DateTime updatedAt;
  
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
  
  UserModel({
    required this.userId,
    required this.email,
    required this.userName,
    this.profilePhotoUrl,
    required this.isDentist,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
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
    );
  }
} 