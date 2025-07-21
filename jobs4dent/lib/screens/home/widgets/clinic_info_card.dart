import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../dashboard_utils.dart';

/// Clinic information card widget for dashboard
class ClinicInfoCard extends StatelessWidget {
  final UserModel user;

  const ClinicInfoCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: DashboardUtils.gradientCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.clinicName ?? 'คลินิกของคุณ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.userType == 'clinic' ? 'คลินิกหลัก' : 'สาขาคลินิก',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.address ?? 'จัดการคลินิกของคุณและค้นหาผู้เชี่ยวชาญทันตกรรมที่ดีที่สุด',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          if (user.branches?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              '${user.branches!.length} สาขา',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 