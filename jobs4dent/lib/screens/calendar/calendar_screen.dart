import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../models/availability_model.dart';
import '../../models/user_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import 'appointment_detail_screen.dart';
// import 'availability_setup_screen.dart'; // TODO: Complete availability setup screen

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    if (authProvider.userModel != null) {
      await appointmentProvider.loadAppointments(authProvider.userModel!.userId);
      await appointmentProvider.loadAvailability(
        authProvider.userModel!.userId,
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now().add(const Duration(days: 90)),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showCalendarSettings(),
          ),
        ],
      ),
      body: Consumer2<AppointmentProvider, AuthProvider>(
        builder: (context, appointmentProvider, authProvider, child) {
          if (_isLoading || appointmentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.userModel;
          if (user == null) {
            return const Center(child: Text('Please log in to view calendar'));
          }

          return Column(
            children: [
              _buildCalendarHeader(),
              _buildCalendar(appointmentProvider),
              _buildSelectedDayInfo(appointmentProvider, user),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.today, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedDay = DateTime.now();
                    _focusedDay = DateTime.now();
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.view_agenda, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _calendarFormat = _calendarFormat == CalendarFormat.month
                        ? CalendarFormat.week
                        : CalendarFormat.month;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(AppointmentProvider appointmentProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: TableCalendar<AppointmentModel>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: (day) => appointmentProvider.getAppointmentsForDate(day),
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF1976D2)),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF1976D2)),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: Colors.red),
          holidayTextStyle: const TextStyle(color: Colors.red),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF1976D2),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF1976D2).withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildSelectedDayInfo(AppointmentProvider appointmentProvider, UserModel user) {
    final appointments = appointmentProvider.getAppointmentsForDate(_selectedDay);
    final availability = appointmentProvider.availability
        .where((avail) => avail.userId == user.userId && 
                         isSameDay(avail.date, _selectedDay))
        .toList();

    return Expanded(
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: appointments.isEmpty && availability.isEmpty
                  ? _buildEmptyDayMessage()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (appointments.isNotEmpty) ...[
                            _buildSectionHeader('Appointments', Icons.event),
                            const SizedBox(height: 8),
                            ...appointments.map((appointment) => 
                                _buildAppointmentCard(appointment)),
                            const SizedBox(height: 16),
                          ],
                          if (availability.isNotEmpty) ...[
                            _buildSectionHeader('Availability', Icons.schedule),
                            const SizedBox(height: 8),
                            ...availability.map((avail) => 
                                _buildAvailabilityCard(avail)),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDayMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No events for this day',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add availability',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1976D2)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(appointment.status),
          child: Icon(
            _getStatusIcon(appointment.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          appointment.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('HH:mm').format(appointment.scheduledDateTime)} - '
              '${DateFormat('HH:mm').format(appointment.scheduledDateTime.add(appointment.duration))}',
            ),
            Text(
              appointment.isVirtual ? 'Virtual Meeting' : appointment.location,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            appointment.statusDisplayName,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getStatusColor(appointment.status).withValues(alpha: 0.2),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AppointmentDetailScreen(appointment: appointment),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailabilityCard(AvailabilityModel availability) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.schedule, color: Colors.white, size: 20),
        ),
        title: Text(
          'Available Time Slots (${availability.timeSlots.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Total: ${_formatDuration(availability.getTotalAvailableTime())}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: availability.timeSlots.map((slot) {
          return ListTile(
            dense: true,
            leading: Icon(
              _getAvailabilityIcon(slot.type),
              color: _getAvailabilityColor(slot.type),
              size: 20,
            ),
            title: Text(
              '${DateFormat('HH:mm').format(slot.startTime)} - '
              '${DateFormat('HH:mm').format(slot.endTime)}',
            ),
            subtitle: slot.note != null ? Text(slot.note!) : null,
            trailing: Chip(
              label: Text(
                _getAvailabilityTypeName(slot.type),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getAvailabilityColor(slot.type).withValues(alpha: 0.2),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddOptionsDialog(),
      backgroundColor: const Color(0xFF1976D2),
      icon: const Icon(Icons.add),
      label: const Text('Add'),
    );
  }

  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Calendar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFF1976D2)),
              title: const Text('Set Availability'),
              subtitle: const Text('Mark when you\'re available'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Availability setup coming soon!')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.event, color: Color(0xFF1976D2)),
              title: const Text('Create Appointment'),
              subtitle: const Text('Schedule a meeting'),
              onTap: () {
                Navigator.of(context).pop();
                _showCreateAppointmentDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAppointmentDialog() {
    // This would typically navigate to an appointment creation screen
    // For now, we'll show a simple dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Appointment'),
        content: const Text('This feature will be available when integrated with job applications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCalendarSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show weekends'),
              value: true,
              onChanged: (value) {
                // Implement weekend visibility toggle
              },
            ),
            SwitchListTile(
              title: const Text('24-hour format'),
              value: true,
              onChanged: (value) {
                // Implement time format toggle
              },
            ),
            ListTile(
              title: const Text('Notification settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to notification settings
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.rescheduled:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.completed:
        return Icons.done_all;
      case AppointmentStatus.rescheduled:
        return Icons.update;
    }
  }

  Color _getAvailabilityColor(AvailabilityType type) {
    switch (type) {
      case AvailabilityType.available:
        return Colors.green;
      case AvailabilityType.busy:
        return Colors.red;
      case AvailabilityType.unavailable:
        return Colors.grey;
      case AvailabilityType.preferred:
        return Colors.blue;
    }
  }

  IconData _getAvailabilityIcon(AvailabilityType type) {
    switch (type) {
      case AvailabilityType.available:
        return Icons.check_circle;
      case AvailabilityType.busy:
        return Icons.access_time;
      case AvailabilityType.unavailable:
        return Icons.block;
      case AvailabilityType.preferred:
        return Icons.star;
    }
  }

  String _getAvailabilityTypeName(AvailabilityType type) {
    switch (type) {
      case AvailabilityType.available:
        return 'Available';
      case AvailabilityType.busy:
        return 'Busy';
      case AvailabilityType.unavailable:
        return 'Unavailable';
      case AvailabilityType.preferred:
        return 'Preferred';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
} 