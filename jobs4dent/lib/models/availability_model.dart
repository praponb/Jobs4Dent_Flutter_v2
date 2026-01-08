import 'package:cloud_firestore/cloud_firestore.dart';

enum AvailabilityType {
  available,
  busy,
  unavailable,
  preferred,
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
}

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final AvailabilityType type;
  final String? note;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.type,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type.name,
      'note': note,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      type: AvailabilityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AvailabilityType.available,
      ),
      note: map['note'],
    );
  }

  Duration get duration => endTime.difference(startTime);

  bool overlaps(TimeSlot other) {
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }

  bool contains(DateTime time) {
    return time.isAfter(startTime) && time.isBefore(endTime);
  }
}

class AvailabilityModel {
  final String availabilityId;
  final String userId;
  final String userName;
  final DateTime date;
  final List<TimeSlot> timeSlots;
  final RecurrenceType recurrence;
  final DateTime? recurrenceEndDate;
  final List<int>? daysOfWeek; // 1-7, Monday to Sunday
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final Map<String, dynamic>? preferences;

  AvailabilityModel({
    required this.availabilityId,
    required this.userId,
    required this.userName,
    required this.date,
    required this.timeSlots,
    this.recurrence = RecurrenceType.none,
    this.recurrenceEndDate,
    this.daysOfWeek,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'availabilityId': availabilityId,
      'userId': userId,
      'userName': userName,
      'date': Timestamp.fromDate(date),
      'timeSlots': timeSlots.map((slot) => slot.toMap()).toList(),
      'recurrence': recurrence.name,
      'recurrenceEndDate': recurrenceEndDate != null ? Timestamp.fromDate(recurrenceEndDate!) : null,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
      'preferences': preferences,
    };
  }

  factory AvailabilityModel.fromMap(Map<String, dynamic> map) {
    return AvailabilityModel(
      availabilityId: map['availabilityId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      timeSlots: (map['timeSlots'] as List<dynamic>?)
          ?.map((slot) => TimeSlot.fromMap(slot))
          .toList() ?? [],
      recurrence: RecurrenceType.values.firstWhere(
        (e) => e.name == map['recurrence'],
        orElse: () => RecurrenceType.none,
      ),
      recurrenceEndDate: map['recurrenceEndDate'] != null 
          ? (map['recurrenceEndDate'] as Timestamp).toDate() 
          : null,
      daysOfWeek: map['daysOfWeek'] != null 
          ? List<int>.from(map['daysOfWeek']) 
          : null,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      notes: map['notes'],
      preferences: map['preferences'],
    );
  }

  AvailabilityModel copyWith({
    String? availabilityId,
    String? userId,
    String? userName,
    DateTime? date,
    List<TimeSlot>? timeSlots,
    RecurrenceType? recurrence,
    DateTime? recurrenceEndDate,
    List<int>? daysOfWeek,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    Map<String, dynamic>? preferences,
  }) {
    return AvailabilityModel(
      availabilityId: availabilityId ?? this.availabilityId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      timeSlots: timeSlots ?? this.timeSlots,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      preferences: preferences ?? this.preferences,
    );
  }

  List<TimeSlot> getAvailableSlots() {
    return timeSlots.where((slot) => slot.type == AvailabilityType.available).toList();
  }

  List<TimeSlot> getBusySlots() {
    return timeSlots.where((slot) => slot.type == AvailabilityType.busy).toList();
  }

  bool isAvailableAt(DateTime time) {
    return timeSlots.any((slot) => 
        slot.type == AvailabilityType.available && slot.contains(time));
  }

  bool isBusyAt(DateTime time) {
    return timeSlots.any((slot) => 
        (slot.type == AvailabilityType.busy || slot.type == AvailabilityType.unavailable) && 
        slot.contains(time));
  }

  Duration getTotalAvailableTime() {
    return getAvailableSlots().fold(
      Duration.zero,
      (total, slot) => total + slot.duration,
    );
  }
} 