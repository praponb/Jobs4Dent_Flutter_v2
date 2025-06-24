import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'role_switcher_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userModel;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: user.profilePhotoUrl != null
                                ? NetworkImage(user.profilePhotoUrl!)
                                : null,
                            child: user.profilePhotoUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // User Name
                      Text(
                        user.userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // User Type
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getUserTypeLabel(user.currentRole),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // Role switcher button (only show if user has multiple roles)
                      if (user.roles.length > 1) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RoleSwitcherScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swap_horiz,
                                  size: 16,
                                  color: const Color(0xFF2196F3),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Switch Role',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF2196F3),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: const Color(0xFF2196F3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Menu Items
                _buildMenuSection([
                  _MenuItemData(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: 'Update your details',
                    onTap: () {
                      // TODO: Navigate to personal info
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.work_outline,
                    title: 'Professional Info',
                    subtitle: 'Skills, experience & qualifications',
                    onTap: () {
                      // TODO: Navigate to professional info
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.location_on_outlined,
                    title: 'Work Preferences',
                    subtitle: 'Location and availability',
                    onTap: () {
                      // TODO: Navigate to work preferences
                    },
                  ),
                  // Role Management - only show if user has multiple roles
                  if (user.roles.length > 1)
                    _MenuItemData(
                      icon: Icons.swap_horiz,
                      title: 'Role Management',
                      subtitle: 'Switch between your roles (${user.roles.length} roles available)',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSwitcherScreen(),
                          ),
                        );
                      },
                    ),
                ]),

                const SizedBox(height: 16),

                _buildMenuSection([
                  _MenuItemData(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage your alerts',
                    onTap: () {
                      // TODO: Navigate to notifications settings
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.security_outlined,
                    title: 'Privacy & Security',
                    subtitle: 'Account security settings',
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact us',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                ]),

                const SizedBox(height: 16),

                // Logout Section
                _buildMenuSection([
                  _MenuItemData(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () {
                      _showLogoutDialog(context, authProvider);
                    },
                    isDestructive: true,
                  ),
                ]),

                const SizedBox(height: 32),

                // App Version
                Text(
                  'Jobs4Dent v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuSection(List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: items.map((item) {
          final isLast = item == items.last;
          return _buildMenuItem(
            item,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItemData item, {bool showDivider = true}) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.isDestructive
                                                  ? Colors.red.withValues(alpha: 0.1)
                          : const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isDestructive
                        ? Colors.red
                        : const Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: item.isDestructive
                              ? Colors.red
                              : Colors.black87,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            if (showDivider) ...[
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: Colors.grey[200],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case 'dentist':
        return 'Dentist';
      case 'assistant':
        return 'Dental Assistant';
      case 'clinic':
        return 'Clinic Owner';
      case 'seller':
        return 'Equipment Seller';
      case 'sales':
        return 'Sales Representative';
      case 'admin':
        return 'Administrator';
      default:
        return 'User';
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.signOut();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
} 