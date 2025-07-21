import 'package:flutter/material.dart';

/// Availability section widget for dentist dashboard
class DentistAvailabilitySection extends StatelessWidget {
  final VoidCallback? onManageTap;

  const DentistAvailabilitySection({
    super.key,
    this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'สถานะความพร้อม',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: onManageTap,
              child: const Text('จัดการ'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  const Text(
                    'พร้อมทำงาน',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'คุณพร้อมสำหรับโอกาสงานใหม่',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AvailabilityItem(
                      label: 'ประเภทงานที่ต้องการ',
                      value: 'เต็มเวลา, บางเวลา',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _AvailabilityItem(
                      label: 'การกำหนดพื้นที่ปฏิบัติงาน',
                      value: 'กรุงเทพฯ และจังหวัดใกล้เคียง',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual availability item widget
class _AvailabilityItem extends StatelessWidget {
  final String label;
  final String value;

  const _AvailabilityItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Availability management dialog
class AvailabilityDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('จัดการความพร้อม'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ฟังก์ชันการจัดการสถานะความพร้อมจะพัฒนาให้ใช้งานได้เร็วๆ นี้'),
            SizedBox(height: 16),
            Text('ฟีเจอร์ที่จะรวม:'),
            Text('• ตั้งสถานะพร้อม/ไม่พร้อม'),
            Text('• จัดการค่าเลือกการทำงาน'),
            Text('• ตั้งค่าเลือกสถานที่'),
            Text('• เชื่อมต่อปฏิทิน'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Note: Availability management screen pending implementation
            },
            child: const Text('จัดการ'),
          ),
        ],
      ),
    );
  }
} 