import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment_model.dart';
import '../models/availability_model.dart';

class AppointmentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<AppointmentModel> _appointments = [];
  List<AvailabilityModel> _availability = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AppointmentModel> get appointments => _appointments;
  List<AvailabilityModel> get availability => _availability;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AppointmentModel> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where((apt) => apt.scheduledDateTime.isAfter(now) && 
                       apt.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  }

  List<AppointmentModel> get todayAppointments {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _appointments
        .where((apt) => apt.scheduledDateTime.isAfter(startOfDay) && 
                       apt.scheduledDateTime.isBefore(endOfDay) &&
                       apt.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load appointments for a user
  Future<void> loadAppointments(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('participants', arrayContains: userId)
          .orderBy('scheduledDateTime', descending: true)
          .get();

      _appointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromMap({
                ...doc.data(),
                'appointmentId': doc.id,
              }))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load appointments: $e');
      debugPrint('Error loading appointments: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new appointment
  Future<bool> createAppointment({
    required String jobId,
    required String clinicId,
    required String clinicName,
    required String applicantId,
    required String applicantName,
    required String title,
    required String description,
    required DateTime scheduledDateTime,
    required Duration duration,
    required AppointmentType type,
    required String location,
    required bool isVirtual,
    String? virtualMeetingLink,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final appointmentId = const Uuid().v4();
      
      final appointment = AppointmentModel(
        appointmentId: appointmentId,
        jobId: jobId,
        clinicId: clinicId,
        clinicName: clinicName,
        applicantId: applicantId,
        applicantName: applicantName,
        title: title,
        description: description,
        scheduledDateTime: scheduledDateTime,
        duration: duration,
        type: type,
        status: AppointmentStatus.pending,
        location: location,
        isVirtual: isVirtual,
        virtualMeetingLink: virtualMeetingLink,
        additionalInfo: additionalInfo,
        createdAt: DateTime.now(),
        participants: [clinicId, applicantId],
      );

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .set(appointment.toMap());

      _appointments.insert(0, appointment);
      notifyListeners();

      // Send notification to applicant
      await _sendAppointmentNotification(appointment, 'created');

      return true;
    } catch (e) {
      _setError('Failed to create appointment: $e');
      debugPrint('Error creating appointment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Confirm an appointment
  Future<bool> confirmAppointment(String appointmentId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.confirmed.name,
        'confirmedAt': Timestamp.fromDate(DateTime.now()),
      });

      final index = _appointments.indexWhere((apt) => apt.appointmentId == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: AppointmentStatus.confirmed,
          confirmedAt: DateTime.now(),
        );
        notifyListeners();

        // Send confirmation notification
        await _sendAppointmentNotification(_appointments[index], 'confirmed');
      }

      return true;
    } catch (e) {
      _setError('Failed to confirm appointment: $e');
      debugPrint('Error confirming appointment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel an appointment
  Future<bool> cancelAppointment(String appointmentId, String reason) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.cancelled.name,
        'cancelledAt': Timestamp.fromDate(DateTime.now()),
        'cancellationReason': reason,
      });

      final index = _appointments.indexWhere((apt) => apt.appointmentId == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: AppointmentStatus.cancelled,
          cancelledAt: DateTime.now(),
          cancellationReason: reason,
        );
        notifyListeners();

        // Send cancellation notification
        await _sendAppointmentNotification(_appointments[index], 'cancelled');
      }

      return true;
    } catch (e) {
      _setError('Failed to cancel appointment: $e');
      debugPrint('Error cancelling appointment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reschedule an appointment
  Future<bool> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
    Duration newDuration,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'scheduledDateTime': Timestamp.fromDate(newDateTime),
        'duration': newDuration.inMinutes,
        'status': AppointmentStatus.rescheduled.name,
      });

      final index = _appointments.indexWhere((apt) => apt.appointmentId == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          scheduledDateTime: newDateTime,
          duration: newDuration,
          status: AppointmentStatus.rescheduled,
        );
        notifyListeners();

        // Send reschedule notification
        await _sendAppointmentNotification(_appointments[index], 'rescheduled');
      }

      return true;
    } catch (e) {
      _setError('Failed to reschedule appointment: $e');
      debugPrint('Error rescheduling appointment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load availability for a user
  Future<void> loadAvailability(String userId, DateTime startDate, DateTime endDate) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await _firestore
          .collection('availability')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('isActive', isEqualTo: true)
          .get();

      _availability = querySnapshot.docs
          .map((doc) => AvailabilityModel.fromMap({
                ...doc.data(),
                'availabilityId': doc.id,
              }))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load availability: $e');
      debugPrint('Error loading availability: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set user availability
  Future<bool> setAvailability({
    required String userId,
    required String userName,
    required DateTime date,
    required List<TimeSlot> timeSlots,
    RecurrenceType recurrence = RecurrenceType.none,
    DateTime? recurrenceEndDate,
    List<int>? daysOfWeek,
    String? notes,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final availabilityId = const Uuid().v4();
      
      final availability = AvailabilityModel(
        availabilityId: availabilityId,
        userId: userId,
        userName: userName,
        date: date,
        timeSlots: timeSlots,
        recurrence: recurrence,
        recurrenceEndDate: recurrenceEndDate,
        daysOfWeek: daysOfWeek,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: notes,
        preferences: preferences,
      );

      await _firestore
          .collection('availability')
          .doc(availabilityId)
          .set(availability.toMap());

      _availability.add(availability);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to set availability: $e');
      debugPrint('Error setting availability: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update availability
  Future<bool> updateAvailability(
    String availabilityId,
    List<TimeSlot> timeSlots,
    String? notes,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore
          .collection('availability')
          .doc(availabilityId)
          .update({
        'timeSlots': timeSlots.map((slot) => slot.toMap()).toList(),
        'notes': notes,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final index = _availability.indexWhere((avail) => avail.availabilityId == availabilityId);
      if (index != -1) {
        _availability[index] = _availability[index].copyWith(
          timeSlots: timeSlots,
          notes: notes,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to update availability: $e');
      debugPrint('Error updating availability: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if a time slot is available
  bool isTimeSlotAvailable(String userId, DateTime startTime, DateTime endTime) {
    final userAvailability = _availability
        .where((avail) => avail.userId == userId)
        .toList();

    for (final availability in userAvailability) {
      for (final slot in availability.timeSlots) {
        if (slot.type == AvailabilityType.available &&
            startTime.isAfter(slot.startTime) &&
            endTime.isBefore(slot.endTime)) {
          return true;
        }
      }
    }

    return false;
  }

  // Get available time slots for a user on a specific date
  List<TimeSlot> getAvailableSlots(String userId, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final userAvailability = _availability
        .where((avail) => avail.userId == userId &&
                         avail.date.isAfter(dayStart.subtract(const Duration(days: 1))) &&
                         avail.date.isBefore(dayEnd))
        .toList();

    List<TimeSlot> availableSlots = [];
    for (final availability in userAvailability) {
      availableSlots.addAll(availability.getAvailableSlots());
    }

    return availableSlots;
  }

  // Send appointment notification (placeholder)
  Future<void> _sendAppointmentNotification(
    AppointmentModel appointment,
    String action,
  ) async {
            // Note: Notification system integration pending
    // This could integrate with Firebase Cloud Messaging, email service, etc.
    debugPrint('Notification: Appointment $action for ${appointment.title}');
  }

  // Get appointments for a specific date
  List<AppointmentModel> getAppointmentsForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _appointments
        .where((apt) => apt.scheduledDateTime.isAfter(dayStart) &&
                       apt.scheduledDateTime.isBefore(dayEnd) &&
                       apt.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  }

  // Get appointments by status
  List<AppointmentModel> getAppointmentsByStatus(AppointmentStatus status) {
    return _appointments
        .where((apt) => apt.status == status)
        .toList()
      ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  }

  // Clear all data
  void clearData() {
    _appointments.clear();
    _availability.clear();
    _error = null;
    notifyListeners();
  }
} 