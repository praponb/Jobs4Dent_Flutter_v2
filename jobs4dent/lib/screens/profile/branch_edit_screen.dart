import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/branch_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/branch_model.dart';
import 'location_picker_screen.dart';

class BranchEditScreen extends StatefulWidget {
  final BranchModel? branch; // null for new branch, existing branch for edit

  const BranchEditScreen({super.key, this.branch});

  @override
  State<BranchEditScreen> createState() => _BranchEditScreenState();
}

class _BranchEditScreenState extends State<BranchEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _branchNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _parkingController = TextEditingController();

  Map<String, String> _operatingHours = {};
  GeoPoint? _selectedCoordinates;
  bool _isLoading = false;

  // Days of the week
  final List<String> _daysOfWeek = [
    'monday', 'tuesday', 'wednesday', 'thursday', 
    'friday', 'saturday', 'sunday'
  ];

  final Map<String, String> _dayNames = {
    'monday': 'จันทร์',
    'tuesday': 'อังคาร',
    'wednesday': 'พุธ',
    'thursday': 'พฤหัสบดี',
    'friday': 'ศุกร์',
    'saturday': 'เสาร์',
    'sunday': 'อาทิตย์',
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.branch != null) {
      final branch = widget.branch!;
      _branchNameController.text = branch.branchName;
      _addressController.text = branch.address;
      _contactController.text = branch.contactNumber;
      _parkingController.text = branch.parkingInfo;
      _operatingHours = Map<String, String>.from(branch.operatingHours);
      _selectedCoordinates = branch.coordinates;
    } else {
      // Initialize with default operating hours
      _operatingHours = {
        'monday': '09:00-18:00',
        'tuesday': '09:00-18:00',
        'wednesday': '09:00-18:00',
        'thursday': '09:00-18:00',
        'friday': '09:00-18:00',
        'saturday': '09:00-17:00',
        'sunday': 'ปิด',
      };
    }
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _parkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.branch != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขข้อมูลสาขา' : 'เพิ่มสาขาใหม่'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveData,
            child: const Text(
              'บันทึก',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ข้อมูลพื้นฐาน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Branch Name
                    TextFormField(
                      controller: _branchNameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อสาขา',
                        hintText: 'เช่น สาขาสุขุมวิท, สาขารามอินทรา',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกชื่อสาขา';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'ที่อยู่',
                        hintText: 'ที่อยู่เต็มของสาขา',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกที่อยู่';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact Number
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'เบอร์โทรศัพท์ติดต่อ',
                        hintText: 'เบอร์โทรศัพท์ของสาขา',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกเบอร์โทรศัพท์';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Parking Information
                    TextFormField(
                      controller: _parkingController,
                      decoration: const InputDecoration(
                        labelText: 'ข้อมูลที่จอดรถ',
                        hintText: 'เช่น มีที่จอดรถ 5 คัน, จอดริมถนน',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_parking),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Location Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ตำแหน่งสาขา',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location picker button
                    InkWell(
                      onTap: _openLocationPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: _selectedCoordinates != null 
                                  ? Colors.green[600] 
                                  : Colors.grey[600],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCoordinates != null 
                                        ? 'ตำแหน่งที่เลือกแล้ว' 
                                        : 'คลิกเพื่อปักหมุดตำแหน่ง',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedCoordinates != null 
                                          ? Colors.green[700] 
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (_selectedCoordinates != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Lat: ${_selectedCoordinates!.latitude.toStringAsFixed(6)}, '
                                      'Lng: ${_selectedCoordinates!.longitude.toStringAsFixed(6)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'เลือกตำแหน่งสาขาบนแผนที่',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[400],
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_selectedCoordinates != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openLocationPicker,
                              icon: const Icon(Icons.edit_location, size: 18),
                              label: const Text('แก้ไขตำแหน่ง'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[600],
                                side: BorderSide(color: Colors.blue[600]!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _removeLocation,
                              icon: const Icon(Icons.clear, size: 18),
                              label: const Text('ลบตำแหน่ง'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red[600],
                                side: BorderSide(color: Colors.red[600]!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Operating Hours Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'เวลาทำการ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._daysOfWeek.map((day) => _buildOperatingHourRow(day)).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditing ? 'อัปเดตข้อมูลสาขา' : 'สร้างสาขาใหม่',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperatingHourRow(String day) {
    final dayName = _dayNames[day] ?? day;
    final currentValue = _operatingHours[day] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              dayName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              initialValue: currentValue,
              decoration: InputDecoration(
                hintText: 'เช่น 09:00-18:00 หรือ ปิด',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              onChanged: (value) {
                _operatingHours[day] = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  // Open location picker
  Future<void> _openLocationPicker() async {
    try {
      final LatLng? selectedLocation = await Navigator.push<LatLng>(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerScreen(
            initialLocation: _selectedCoordinates,
            initialAddress: _addressController.text,
          ),
        ),
      );

      if (selectedLocation != null) {
        setState(() {
          _selectedCoordinates = GeoPoint(
            selectedLocation.latitude,
            selectedLocation.longitude,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเลือกตำแหน่ง: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Remove location
  void _removeLocation() {
    setState(() {
      _selectedCoordinates = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ลบตำแหน่งแล้ว'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final branchProvider = Provider.of<BranchProvider>(context, listen: false);
      final user = authProvider.userModel;

      if (user == null) {
        throw Exception('ไม่พบข้อมูลผู้ใช้');
      }

      final now = DateTime.now();
      
      if (widget.branch != null) {
        // Edit existing branch
        final updatedBranch = widget.branch!.copyWith(
          branchName: _branchNameController.text.trim(),
          address: _addressController.text.trim(),
          contactNumber: _contactController.text.trim(),
          parkingInfo: _parkingController.text.trim(),
          operatingHours: _operatingHours,
          coordinates: _selectedCoordinates,
          updatedAt: now,
        );

        print('Updating branch to Firebase collection "branches": ${updatedBranch.branchId}');
        await branchProvider.updateBranch(updatedBranch);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อัปเดตข้อมูลสาขาสำเร็จและบันทึกแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new branch
        final newBranch = BranchModel(
          branchId: '', // Will be set by Firestore
          clinicId: user.userId,
          branchName: _branchNameController.text.trim(),
          address: _addressController.text.trim(),
          contactNumber: _contactController.text.trim(),
          parkingInfo: _parkingController.text.trim(),
          operatingHours: _operatingHours,
          coordinates: _selectedCoordinates,
          createdAt: now,
          updatedAt: now,
          isActive: true, // Explicitly set as active
        );

        print('Creating new branch in Firebase collection "branches" for clinic: ${user.userId}');
        await branchProvider.createBranch(newBranch);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('สร้างสาขาใหม่สำเร็จและบันทึกแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 