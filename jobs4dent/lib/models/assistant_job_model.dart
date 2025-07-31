class AssistantJobModel {
  final String jobId;
  final String clinicId;
  final String clinicNameAndBranch;
  final String titlePost;
  final List<String> skillAssistant;
  final String workType; // Part-time or Full-time
  
  // Part-time specific fields
  final List<DateTime>? workDayPartTime;
  final String? paymentTermPartTime;
  final String? payPerDayPartTime;
  final String? payPerHourPartTime;
  
  // Full-time specific fields
  final String? salaryFullTime;
  final String? totalIncomeFullTime;
  final String? dayOffFullTime;
  final String? workTimeStart;
  final String? workTimeEnd;
  final String? perk;
  
  // System fields
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int applicationCount;
  final List<String> applicationIds;

  AssistantJobModel({
    required this.jobId,
    required this.clinicId,
    required this.clinicNameAndBranch,
    required this.titlePost,
    required this.skillAssistant,
    required this.workType,
    this.workDayPartTime,
    this.paymentTermPartTime,
    this.payPerDayPartTime,
    this.payPerHourPartTime,
    this.salaryFullTime,
    this.totalIncomeFullTime,
    this.dayOffFullTime,
    this.workTimeStart,
    this.workTimeEnd,
    this.perk,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.applicationCount = 0,
    this.applicationIds = const [],
  });

  factory AssistantJobModel.fromMap(Map<String, dynamic> map) {
    return AssistantJobModel(
      jobId: map['jobId'] ?? '',
      clinicId: map['clinicId'] ?? '',
      clinicNameAndBranch: map['clinicNameAndBranch'] ?? '',
      titlePost: map['titlePost'] ?? '',
      skillAssistant: List<String>.from(map['skillAssistant'] ?? []),
      workType: map['workType'] ?? '',
      workDayPartTime: map['workDayPartTime'] != null 
          ? (map['workDayPartTime'] as List)
              .map<DateTime>((timestamp) {
                try {
                  if (timestamp is int) {
                    return DateTime.fromMillisecondsSinceEpoch(timestamp);
                  } else if (timestamp.toString().contains('Timestamp')) {
                    return timestamp.toDate();
                  }
                  return DateTime.now();
                } catch (e) {
                  return DateTime.now();
                }
              })
              .toList()
          : null,
      paymentTermPartTime: map['paymentTermPartTime'],
      payPerDayPartTime: map['payPerDayPartTime'],
      payPerHourPartTime: map['payPerHourPartTime'],
      salaryFullTime: map['salaryFullTime'],
      totalIncomeFullTime: map['totalIncomeFullTime'],
      dayOffFullTime: map['dayOffFullTime'],
      workTimeStart: map['workTimeStart'],
      workTimeEnd: map['workTimeEnd'],
      perk: map['perk'],
      isActive: map['isActive'] ?? true,
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(map['updatedAt']) ?? DateTime.now(),
      applicationCount: map['applicationCount'] ?? 0,
      applicationIds: List<String>.from(map['applicationIds'] ?? []),
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return null;
      if (timestamp is DateTime) return timestamp;
      if (timestamp.toString().contains('Timestamp')) {
        return timestamp.toDate();
      }
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'clinicId': clinicId,
      'clinicNameAndBranch': clinicNameAndBranch,
      'titlePost': titlePost,
      'skillAssistant': skillAssistant,
      'workType': workType,
      'workDayPartTime': workDayPartTime?.map((date) => date.millisecondsSinceEpoch).toList(),
      'paymentTermPartTime': paymentTermPartTime,
      'payPerDayPartTime': payPerDayPartTime,
      'payPerHourPartTime': payPerHourPartTime,
      'salaryFullTime': salaryFullTime,
      'totalIncomeFullTime': totalIncomeFullTime,
      'dayOffFullTime': dayOffFullTime,
      'workTimeStart': workTimeStart,
      'workTimeEnd': workTimeEnd,
      'perk': perk,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'applicationCount': applicationCount,
      'applicationIds': applicationIds,
    };
  }

  AssistantJobModel copyWith({
    String? jobId,
    String? clinicId,
    String? clinicNameAndBranch,
    String? titlePost,
    List<String>? skillAssistant,
    String? workType,
    List<DateTime>? workDayPartTime,
    String? paymentTermPartTime,
    String? payPerDayPartTime,
    String? payPerHourPartTime,
    String? salaryFullTime,
    String? totalIncomeFullTime,
    String? dayOffFullTime,
    String? workTimeStart,
    String? workTimeEnd,
    String? perk,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? applicationCount,
    List<String>? applicationIds,
  }) {
    return AssistantJobModel(
      jobId: jobId ?? this.jobId,
      clinicId: clinicId ?? this.clinicId,
      clinicNameAndBranch: clinicNameAndBranch ?? this.clinicNameAndBranch,
      titlePost: titlePost ?? this.titlePost,
      skillAssistant: skillAssistant ?? this.skillAssistant,
      workType: workType ?? this.workType,
      workDayPartTime: workDayPartTime ?? this.workDayPartTime,
      paymentTermPartTime: paymentTermPartTime ?? this.paymentTermPartTime,
      payPerDayPartTime: payPerDayPartTime ?? this.payPerDayPartTime,
      payPerHourPartTime: payPerHourPartTime ?? this.payPerHourPartTime,
      salaryFullTime: salaryFullTime ?? this.salaryFullTime,
      totalIncomeFullTime: totalIncomeFullTime ?? this.totalIncomeFullTime,
      dayOffFullTime: dayOffFullTime ?? this.dayOffFullTime,
      workTimeStart: workTimeStart ?? this.workTimeStart,
      workTimeEnd: workTimeEnd ?? this.workTimeEnd,
      perk: perk ?? this.perk,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicationCount: applicationCount ?? this.applicationCount,
      applicationIds: applicationIds ?? this.applicationIds,
    );
  }
} 