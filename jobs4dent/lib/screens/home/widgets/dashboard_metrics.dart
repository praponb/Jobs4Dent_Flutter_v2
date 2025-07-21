import 'package:flutter/material.dart';
import '../dashboard_data_processor.dart';
import '../dashboard_utils.dart';

/// Dashboard key metrics widget
class DashboardMetricsWidget extends StatelessWidget {
  final DashboardMetrics metrics;

  const DashboardMetricsWidget({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ตัวชี้วัดหลัก',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'งานที่เปิดรับ',
                value: metrics.activeJobs.toString(),
                icon: Icons.work,
                color: Colors.green,
                subtitle: 'กำลังรับสมัคร',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'ใบสมัคร',
                value: metrics.totalApplications.toString(),
                icon: Icons.people,
                color: Colors.orange,
                subtitle: 'รวมที่ได้รับ',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'จ้างงานแล้ว',
                value: metrics.filledJobs.toString(),
                icon: Icons.check_circle,
                color: Colors.blue,
                subtitle: 'จ้างงานสำเร็จ',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'หมดอายุ',
                value: metrics.expiredJobs.toString(),
                icon: Icons.schedule,
                color: Colors.red,
                subtitle: 'เลยกำหนด',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual metric card widget
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 