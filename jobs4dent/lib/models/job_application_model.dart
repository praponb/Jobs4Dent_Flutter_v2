class JobApplicationModel {
  final String applicationId;
  final String jobId;
  final String applicantId;
  final String clinicId;
  final String applicantName;
  final String applicantEmail;
  final String? applicantPhone;
  final String? applicantProfilePhoto;
  final String coverLetter;
  final List<String> additionalDocuments; // URLs of uploaded documents
  final String
  status; // 'submitted', 'under_review', 'shortlisted', 'interview_scheduled', 'interview_completed', 'offered', 'hired', 'rejected'
  final DateTime appliedAt;
  final DateTime updatedAt;
  final String? notes; // Notes from clinic/HR
  final DateTime? interviewDate;
  final String? interviewLocation;
  final String? interviewNotes;
  final double? matchingScore;
  final Map<String, dynamic>?
  applicantProfile; // Snapshot of applicant's profile at time of application
  final String? jobTitle; // Job title for display purposes
  final String? clinicName; // Clinic name for display purposes

  JobApplicationModel({
    required this.applicationId,
    required this.jobId,
    required this.applicantId,
    required this.clinicId,
    required this.applicantName,
    required this.applicantEmail,
    this.applicantPhone,
    this.applicantProfilePhoto,
    required this.coverLetter,
    this.additionalDocuments = const [],
    this.status = 'submitted',
    required this.appliedAt,
    required this.updatedAt,
    this.notes,
    this.interviewDate,
    this.interviewLocation,
    this.interviewNotes,
    this.matchingScore,
    this.applicantProfile,
    this.jobTitle,
    this.clinicName,
  });

  factory JobApplicationModel.fromMap(Map<String, dynamic> map) {
    return JobApplicationModel(
      applicationId: map['applicationId'] ?? '',
      jobId: map['jobId'] ?? '',
      applicantId: map['applicantId'] ?? '',
      clinicId: map['clinicId'] ?? '',
      applicantName: map['applicantName'] ?? '',
      applicantEmail: map['applicantEmail'] ?? '',
      applicantPhone: map['applicantPhone'],
      applicantProfilePhoto: map['applicantProfilePhoto'],
      coverLetter: map['coverLetter'] ?? '',
      additionalDocuments: List<String>.from(map['additionalDocuments'] ?? []),
      status: map['status'] ?? 'submitted',
      appliedAt: DateTime.fromMillisecondsSinceEpoch(map['appliedAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      notes: map['notes'],
      interviewDate: map['interviewDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['interviewDate'])
          : null,
      interviewLocation: map['interviewLocation'],
      interviewNotes: map['interviewNotes'],
      matchingScore: map['matchingScore']?.toDouble(),
      applicantProfile: map['applicantProfile'],
      jobTitle: map['jobTitle'],
      clinicName: map['clinicName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'jobId': jobId,
      'applicantId': applicantId,
      'clinicId': clinicId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantPhone': applicantPhone,
      'applicantProfilePhoto': applicantProfilePhoto,
      'coverLetter': coverLetter,
      'additionalDocuments': additionalDocuments,
      'status': status,
      'appliedAt': appliedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'notes': notes,
      'interviewDate': interviewDate?.millisecondsSinceEpoch,
      'interviewLocation': interviewLocation,
      'interviewNotes': interviewNotes,
      'matchingScore': matchingScore,
      'applicantProfile': applicantProfile,
      'jobTitle': jobTitle,
      'clinicName': clinicName,
    };
  }

  JobApplicationModel copyWith({
    String? applicationId,
    String? jobId,
    String? applicantId,
    String? clinicId,
    String? applicantName,
    String? applicantEmail,
    String? applicantPhone,
    String? applicantProfilePhoto,
    String? coverLetter,
    List<String>? additionalDocuments,
    String? status,
    DateTime? appliedAt,
    DateTime? updatedAt,
    String? notes,
    DateTime? interviewDate,
    String? interviewLocation,
    String? interviewNotes,
    double? matchingScore,
    Map<String, dynamic>? applicantProfile,
    String? jobTitle,
    String? clinicName,
  }) {
    return JobApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      jobId: jobId ?? this.jobId,
      applicantId: applicantId ?? this.applicantId,
      clinicId: clinicId ?? this.clinicId,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      applicantProfilePhoto:
          applicantProfilePhoto ?? this.applicantProfilePhoto,
      coverLetter: coverLetter ?? this.coverLetter,
      additionalDocuments: additionalDocuments ?? this.additionalDocuments,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
      interviewNotes: interviewNotes ?? this.interviewNotes,
      matchingScore: matchingScore ?? this.matchingScore,
      applicantProfile: applicantProfile ?? this.applicantProfile,
      jobTitle: jobTitle ?? this.jobTitle,
      clinicName: clinicName ?? this.clinicName,
    );
  }

  String getStatusDisplayName() {
    switch (status) {
      case 'submitted':
        return 'ส่งใบสมัครแล้ว';
      case 'under_review':
        return 'กำลังพิจารณา';
      case 'shortlisted':
        return 'คัดเลือกแล้ว';
      case 'interview_scheduled':
        return 'นัดสัมภาษณ์แล้ว';
      case 'interview_completed':
        return 'สัมภาษณ์เสร็จสิ้น';
      case 'offered':
        return 'ได้รับข้อเสนองาน';
      case 'hired':
        return 'ได้งานแล้ว';
      case 'rejected':
        return 'ไม่ได้รับคัดเลือก';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  bool get isActive {
    return !['hired', 'rejected'].contains(status);
  }

  bool get isPending {
    return ['submitted', 'under_review'].contains(status);
  }

  bool get isInProgress {
    return [
      'shortlisted',
      'interview_scheduled',
      'interview_completed',
      'offered',
    ].contains(status);
  }

  bool get isCompleted {
    return ['hired', 'rejected'].contains(status);
  }
}
