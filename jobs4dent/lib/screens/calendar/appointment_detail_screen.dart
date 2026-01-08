import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late AppointmentModel _appointment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appointment.title),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_appointment.canBeCancelled || _appointment.canBeRescheduled)
            PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                if (_appointment.canBeRescheduled)
                  const PopupMenuItem(
                    value: 'reschedule',
                    child: ListTile(
                      leading: Icon(Icons.schedule),
                      title: Text('เลื่อนนัด'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                if (_appointment.canBeCancelled)
                  const PopupMenuItem(
                    value: 'cancel',
                    child: ListTile(
                      leading: Icon(Icons.cancel, color: Colors.red),
                      title: Text('ยกเลิก', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildDetails(),
                  _buildParticipants(),
                  if (_appointment.isVirtual) _buildVirtualMeetingInfo(),
                  _buildActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Icon(
                  _getTypeIcon(_appointment.type),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _appointment.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _appointment.typeDisplayName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(_appointment.status).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(_appointment.status),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _appointment.statusDisplayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายละเอียด',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.access_time,
              title: 'วันที่และเวลา',
              content: DateFormat('EEEE, MMMM d, yyyy').format(_appointment.scheduledDateTime),
              subtitle: '${DateFormat('h:mm a').format(_appointment.scheduledDateTime)} - '
                       '${DateFormat('h:mm a').format(_appointment.scheduledDateTime.add(_appointment.duration))}',
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.schedule,
              title: 'ระยะเวลา',
              content: _formatDuration(_appointment.duration),
            ),
            const Divider(),
            _buildDetailRow(
              icon: _appointment.isVirtual ? Icons.videocam : Icons.location_on,
              title: 'สถานที่',
              content: _appointment.isVirtual ? 'การประชุมออนไลน์' : _appointment.location,
              subtitle: _appointment.isVirtual ? 'การประชุมทางวิดีโอออนไลน์' : null,
            ),
            if (_appointment.description.isNotEmpty) ...[
              const Divider(),
              _buildDetailRow(
                icon: Icons.description,
                title: 'คำอธิบาย',
                content: _appointment.description,
              ),
            ],
            if (_appointment.cancellationReason != null) ...[
              const Divider(),
              _buildDetailRow(
                icon: Icons.info_outline,
                title: 'เหตุผลในการยกเลิก',
                content: _appointment.cancellationReason!,
                isError: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
    bool isError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isError ? Colors.red : const Color(0xFF1976D2),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isError ? Colors.red : Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipants() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ผู้เข้าร่วม',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1976D2),
                child: Icon(Icons.business, color: Colors.white),
              ),
              title: Text(_appointment.clinicName),
              subtitle: const Text('คลินิก'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(_appointment.applicantName),
              subtitle: const Text('ผู้สมัคร'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualMeetingInfo() {
    if (!_appointment.isVirtual || _appointment.virtualMeetingLink == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.videocam, color: Color(0xFF1976D2)),
                SizedBox(width: 8),
                Text(
                  'การประชุมออนไลน์',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.video_call,
                    size: 48,
                    color: Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _appointment.virtualMeetingLink!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1976D2),
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _launchMeetingLink(),
                    icon: const Icon(Icons.launch),
                    label: const Text('เข้าร่วมประชุม'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.userModel;
    
    if (currentUser == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_appointment.canBeConfirmed && 
              currentUser.userId == _appointment.applicantId) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmAppointment(),
                icon: const Icon(Icons.check_circle),
                                  label: const Text('ยืนยันนัดหมาย'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (_appointment.canBeRescheduled) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rescheduleAppointment(),
                    icon: const Icon(Icons.schedule),
                    label: const Text('เลื่อนเวลา'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (_appointment.canBeCancelled) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelAppointment(),
                    icon: const Icon(Icons.cancel),
                    label: const Text('ยกเลิก'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'reschedule':
        _rescheduleAppointment();
        break;
      case 'cancel':
        _cancelAppointment();
        break;
    }
  }

  Future<void> _confirmAppointment() async {
    setState(() => _isLoading = true);
    
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await appointmentProvider.confirmAppointment(_appointment.appointmentId);
    
    setState(() => _isLoading = false);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยืนยันนัดหมายเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appointmentProvider.error ?? 'ยืนยันนัดหมายไม่สำเร็จ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rescheduleAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลื่อนเวลานัดหมาย'),
        content: const Text('ฟีเจอร์นี้จะพร้อมใช้งานเร็วๆ นี้ คุณสามารถติดต่อคลินิกโดยตรงเพื่อเลื่อนเวลา'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
                          child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยกเลิกนัดหมาย'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการยกเลิกนัดหมายนี้? การกระทำนี้ไม่สามารถยกเลิกได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
                          child: const Text('เก็บไว้'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showCancellationReasonDialog();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ยกเลิกนัดหมาย'),
          ),
        ],
      ),
    );
  }

  void _showCancellationReasonDialog() {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เหตุผลการยกเลิก'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'โปรดระบุเหตุผลในการยกเลิก...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('กลับ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performCancellation(reasonController.text.trim());
            },
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('ยกเลิกนัดหมาย'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCancellation(String reason) async {
    setState(() => _isLoading = true);
    
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await appointmentProvider.cancelAppointment(
      _appointment.appointmentId,
      reason.isEmpty ? 'ไม่ได้ระบุเหตุผล' : reason,
    );
    
    setState(() => _isLoading = false);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยกเลิกนัดหมายเรียบร้อยแล้ว'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appointmentProvider.error ?? 'ยกเลิกนัดหมายไม่สำเร็จ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchMeetingLink() async {
    if (_appointment.virtualMeetingLink == null) return;
    
    final uri = Uri.parse(_appointment.virtualMeetingLink!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถเปิดลิงก์การประชุมได้'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getTypeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.interview:
        return Icons.psychology;
      case AppointmentType.jobDiscussion:
        return Icons.work;
      case AppointmentType.consultation:
        return Icons.medical_services;
      case AppointmentType.other:
        return Icons.event;
    }
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