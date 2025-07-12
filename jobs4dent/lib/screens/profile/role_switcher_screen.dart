import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RoleSwitcherScreen extends StatelessWidget {
  const RoleSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เปลี่ยนบทบาท'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userModel = authProvider.userModel;
          
          if (userModel == null) {
            return const Center(
              child: Text('ไม่มีข้อมูลผู้ใช้'),
            );
          }

          final availableRoles = userModel.roles;
          final currentRole = userModel.currentRole;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'บทบาทปัจจุบัน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2196F3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getRoleIcon(currentRole),
                        color: const Color(0xFF2196F3),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getRoleTitle(currentRole),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (availableRoles.length > 1) ...[
                  const Text(
                    'บทบาทที่มี',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableRoles.length,
                      itemBuilder: (context, index) {
                        final role = availableRoles[index];
                        final isCurrentRole = role == currentRole;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: isCurrentRole ? null : () async {
                              final success = await authProvider.switchRole(role);
                              if (success && context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('เปลี่ยนเป็น ${_getRoleTitle(role)} แล้ว'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCurrentRole 
                                    ? Colors.grey[100]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrentRole 
                                      ? Colors.grey[300]!
                                      : Colors.grey[200]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getRoleIcon(role),
                                    color: isCurrentRole 
                                        ? Colors.grey[500]
                                        : const Color(0xFF2196F3),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getRoleTitle(role),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isCurrentRole 
                                                ? Colors.grey[500]
                                                : Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          _getRoleDescription(role),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrentRole)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.grey[500],
                                    )
                                  else
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF2196F3),
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'บัญชีบทบาทเดียว',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'คุณมีบทบาทเดียวในขณะนี้ ติดต่อฝ่ายสนับสนุนเพื่อเพิ่มบทบาทอื่นในบัญชีของคุณ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                // Error message
                if (authProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.error!,
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: authProvider.clearError,
                          iconSize: 20,
                          color: Colors.red[600],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'dentist':
        return Icons.medical_services;
      case 'assistant':
        return Icons.medical_information;
      case 'clinic':
        return Icons.business;
      case 'seller':
        return Icons.store;
      default:
        return Icons.person;
    }
  }

  String _getRoleTitle(String role) {
    switch (role) {
      case 'dentist':
        return 'ทันตแพทย์';
      case 'assistant':
        return 'ผู้ช่วยทันตแพทย์';
      case 'clinic':
        return 'เจ้าของคลินิก';
      case 'seller':
        return 'ผู้ขายอุปกรณ์';
      default:
        return role.toUpperCase();
    }
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'dentist':
        return 'ผู้ประกอบวิชาชีพทันตกรรม';
      case 'assistant':
        return 'ผู้ช่วยทันตแพทย์มืออาชีพ';
      case 'clinic':
        return 'เจ้าของ/ผู้จัดการคลินิกทันตกรรม';
      case 'seller':
        return 'ผู้ขายอุปกรณ์ทันตกรรม';
      default:
        return 'บทบาทมืออาชีพ';
    }
  }
} 