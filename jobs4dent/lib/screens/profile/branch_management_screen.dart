import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/branch_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/branch_model.dart';
import 'branch_edit_screen.dart';

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is fully built before loading data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBranchesOnInit();
    });
  }

  Future<void> _loadBranchesOnInit() async {
    debugPrint(
      'Branch Management Screen initialized - loading branches for first time',
    );
    await _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final branchProvider = Provider.of<BranchProvider>(
        context,
        listen: false,
      );
      final user = authProvider.userModel;

      if (user != null) {
        debugPrint(
          'Loading branches from Firestore collection "branches" for user: ${user.userId}',
        );
        await branchProvider.loadBranchesForClinic(user.userId);

        if (mounted) {
          debugPrint(
            'Successfully loaded ${branchProvider.branches.length} branches from Firestore',
          );
        }
      } else {
        debugPrint('User not found - cannot load branches');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading branches: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูลสาขา: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Opens Google Maps app with the branch's coordinates
  Future<void> _viewOnGoogleMap(BranchModel branch) async {
    try {
      // Check if branch has coordinates
      if (branch.coordinates == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่พบข้อมูลพิกัดของสาขานี้'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final double latitude = branch.coordinates!.latitude;
      final double longitude = branch.coordinates!.longitude;

      // Create Google Maps URL with coordinates and branch name as label
      final String encodedBranchName = Uri.encodeComponent(branch.branchName);

      // Try different Google Maps URL formats for better compatibility
      final List<String> mapUrls = [
        // Google Maps app URL showing location with marker (not navigation)
        'geo:$latitude,$longitude?q=$latitude,$longitude($encodedBranchName)',
        // Google Maps web URL with marker
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        // Alternative Google Maps web URL with place name
        'https://maps.google.com/?q=$latitude,$longitude($encodedBranchName)',
        // Fallback web URL showing location
        'https://www.google.com/maps/@$latitude,$longitude,17z',
      ];

      bool mapOpened = false;

      // Try each URL until one works
      for (String mapUrl in mapUrls) {
        final Uri uri = Uri.parse(mapUrl);

        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // Open in external app
          );
          mapOpened = true;

          debugPrint('🗺️ Opened Google Maps for branch: ${branch.branchName}');
          debugPrint('📍 Coordinates: $latitude, $longitude');
          debugPrint('🔗 URL used: $mapUrl');
          break;
        }
      }

      if (!mapOpened) {
        // If no URL worked, show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'ไม่สามารถเปิดแผนที่ได้ กรุณาตรวจสอบการติดตั้ง Google Maps',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error opening Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเปิดแผนที่: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('จัดการข้อมูลสาขา'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addNewBranch,
            icon: const Icon(Icons.add),
            tooltip: 'เพิ่มสาขาใหม่',
          ),
        ],
      ),
      body: Consumer2<BranchProvider, AuthProvider>(
        builder: (context, branchProvider, authProvider, child) {
          // Show loading state
          if (branchProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'กำลังโหลดข้อมูลสาขาจาก Firebase...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Show error state
          if (branchProvider.error != null) {
            return _buildErrorState(branchProvider.error!);
          }

          final branches = branchProvider.branches;

          // Show empty state
          if (branches.isEmpty) {
            return _buildEmptyState();
          }

          // Show branches list
          return RefreshIndicator(
            onRefresh: _loadBranches,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return _buildBranchCard(branch);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBranch,
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีข้อมูลสาขา',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เพิ่มสาขาแรกของคุณเพื่อให้ผู้สมัครงานเห็นข้อมูลที่ชัดเจน',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewBranch,
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มสาขาใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'เกิดข้อผิดพลาด',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final branchProvider = Provider.of<BranchProvider>(
                context,
                listen: false,
              );
              branchProvider.clearError();
              _loadBranches();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('ลองใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(BranchModel branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.business, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.branchName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (branch.contactNumber.isNotEmpty)
                        Text(
                          branch.contactNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _onMenuSelected(value, branch),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('แก้ไข'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('ลบ', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Branch Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address
                _buildDetailRow(
                  Icons.location_on,
                  'ที่อยู่',
                  branch.address.isNotEmpty ? branch.address : 'ไม่ได้ระบุ',
                ),
                const SizedBox(height: 12),

                // Operating Hours
                _buildDetailRow(
                  Icons.access_time,
                  'เวลาทำการ',
                  branch.operatingHours.isNotEmpty
                      ? _formatOperatingHours(branch.operatingHours)
                      : 'ไม่ได้ระบุ',
                ),
                const SizedBox(height: 12),

                // Parking Info
                _buildDetailRow(
                  Icons.local_parking,
                  'ที่จอดรถ',
                  branch.parkingInfo.isNotEmpty
                      ? branch.parkingInfo
                      : 'ไม่ได้ระบุ',
                ),
                const SizedBox(height: 12),

                // Photos
                if (branch.branchPhotos.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.photo_library,
                    'รูปภาพ',
                    '${branch.branchPhotos.length} รูป',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: branch.branchPhotos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(branch.branchPhotos[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editBranch(branch),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('แก้ไข'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[600],
                          side: BorderSide(color: Colors.blue[600]!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewOnGoogleMap(branch),
                        icon: const Icon(Icons.map, size: 18),
                        label: const Text('ดูแผนที่'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  String _formatOperatingHours(Map<String, String> operatingHours) {
    if (operatingHours.isEmpty) return 'ไม่ได้ระบุ';

    final first = operatingHours.entries.first;
    if (operatingHours.length == 1) {
      return '${_getDayName(first.key)}: ${first.value}';
    } else {
      return '${_getDayName(first.key)}: ${first.value} (+${operatingHours.length - 1} วันอื่นๆ)';
    }
  }

  String _getDayName(String day) {
    const dayNames = {
      'monday': 'จันทร์',
      'tuesday': 'อังคาร',
      'wednesday': 'พุธ',
      'thursday': 'พฤหัสบดี',
      'friday': 'ศุกร์',
      'saturday': 'เสาร์',
      'sunday': 'อาทิตย์',
    };
    return dayNames[day.toLowerCase()] ?? day;
  }

  void _onMenuSelected(String value, BranchModel branch) {
    switch (value) {
      case 'edit':
        _editBranch(branch);
        break;
      case 'delete':
        _confirmDeleteBranch(branch);
        break;
    }
  }

  void _addNewBranch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BranchEditScreen()),
    ).then((_) => _loadBranches());
  }

  void _editBranch(BranchModel branch) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BranchEditScreen(branch: branch)),
    ).then((_) => _loadBranches());
  }

  void _confirmDeleteBranch(BranchModel branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสาขา "${branch.branchName}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBranch(branch);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBranch(BranchModel branch) async {
    try {
      final branchProvider = Provider.of<BranchProvider>(
        context,
        listen: false,
      );
      await branchProvider.deleteBranch(branch.branchId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบสาขา "${branch.branchName}" สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
