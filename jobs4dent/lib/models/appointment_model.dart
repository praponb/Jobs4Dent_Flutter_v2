import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentType {
  interview,
  jobDiscussion,
  consultation,
  other,
}

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  rescheduled,
}

class AppointmentModel {
  final String appointmentId;
  final String jobId;
  final String clinicId;
  final String clinicName;
  final String applicantId;
  final String applicantName;
  final String title;
  final String description;
  final DateTime scheduledDateTime;
  final Duration duration;
  final AppointmentType type;
  final AppointmentStatus status;
  final String location;
  final bool isVirtual;
  final String? virtualMeetingLink;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final List<String> participants;
  final bool reminderSent;
  final DateTime? reminderSentAt;

  AppointmentModel({
    required this.appointmentId,
    required this.jobId,
    required this.clinicId,
    required this.clinicName,
    required this.applicantId,
    required this.applicantName,
    required this.title,
    required this.description,
    required this.scheduledDateTime,
    required this.duration,
    required this.type,
    required this.status,
    required this.location,
    required this.isVirtual,
    this.virtualMeetingLink,
    this.additionalInfo,
    required this.createdAt,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.participants,
    this.reminderSent = false,
    this.reminderSentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'jobId': jobId,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'title': title,
      'description': description,
      'scheduledDateTime': Timestamp.fromDate(scheduledDateTime),
      'duration': duration.inMinutes,
      'type': type.name,
      'status': status.name,
      'location': location,
      'isVirtual': isVirtual,
      'virtualMeetingLink': virtualMeetingLink,
      'additionalInfo': additionalInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'participants': participants,
      'reminderSent': reminderSent,
      'reminderSentAt': reminderSentAt != null ? Timestamp.fromDate(reminderSentAt!) : null,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      appointmentId: map['appointmentId'] ?? '',
      jobId: map['jobId'] ?? '',
      clinicId: map['clinicId'] ?? '',
      clinicName: map['clinicName'] ?? '',
      applicantId: map['applicantId'] ?? '',
      applicantName: map['applicantName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      scheduledDateTime: (map['scheduledDateTime'] as Timestamp).toDate(),
      duration: Duration(minutes: map['duration'] ?? 60),
      type: AppointmentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AppointmentType.interview,
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      location: map['location'] ?? '',
      isVirtual: map['isVirtual'] ?? false,
      virtualMeetingLink: map['virtualMeetingLink'],
      additionalInfo: map['additionalInfo'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      confirmedAt: map['confirmedAt'] != null ? (map['confirmedAt'] as Timestamp).toDate() : null,
      cancelledAt: map['cancelledAt'] != null ? (map['cancelledAt'] as Timestamp).toDate() : null,
      cancellationReason: map['cancellationReason'],
      participants: List<String>.from(map['participants'] ?? []),
      reminderSent: map['reminderSent'] ?? false,
      reminderSentAt: map['reminderSentAt'] != null ? (map['reminderSentAt'] as Timestamp).toDate() : null,
    );
  }

  AppointmentModel copyWith({
    String? appointmentId,
    String? jobId,
    String? clinicId,
    String? clinicName,
    String? applicantId,
    String? applicantName,
    String? title,
    String? description,
    DateTime? scheduledDateTime,
    Duration? duration,
    AppointmentType? type,
    AppointmentStatus? status,
    String? location,
    bool? isVirtual,
    String? virtualMeetingLink,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    List<String>? participants,
    bool? reminderSent,
    DateTime? reminderSentAt,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      jobId: jobId ?? this.jobId,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      isVirtual: isVirtual ?? this.isVirtual,
      virtualMeetingLink: virtualMeetingLink ?? this.virtualMeetingLink,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      participants: participants ?? this.participants,
      reminderSent: reminderSent ?? this.reminderSent,
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case AppointmentType.interview:
        return 'Interview';
      case AppointmentType.jobDiscussion:
        return 'Job Discussion';
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.other:
        return 'Other';
    }
  }

  bool get isUpcoming {
    return scheduledDateTime.isAfter(DateTime.now()) && 
           status != AppointmentStatus.cancelled &&
           status != AppointmentStatus.completed;
  }

  bool get isPast {
    return scheduledDateTime.isBefore(DateTime.now());
  }

  bool get canBeConfirmed {
    return status == AppointmentStatus.pending && isUpcoming;
  }

  bool get canBeCancelled {
    return (status == AppointmentStatus.pending || status == AppointmentStatus.confirmed) && isUpcoming;
  }

  bool get canBeRescheduled {
    return (status == AppointmentStatus.pending || status == AppointmentStatus.confirmed) && isUpcoming;
  }
} 