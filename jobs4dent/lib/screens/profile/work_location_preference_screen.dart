import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

class WorkLocationPreferenceScreen extends StatefulWidget {
  const WorkLocationPreferenceScreen({super.key});

  @override
  State<WorkLocationPreferenceScreen> createState() => _WorkLocationPreferenceScreenState();
}

class _WorkLocationPreferenceScreenState extends State<WorkLocationPreferenceScreen> {
  bool _isLoading = false;
  List<String> _selectedProvinces = [];
  List<String> _selectedCities = [];
  bool _isWillingToRelocate = false;
  String _preferredWorkType = 'เต็มเวลา';

  final Map<String, List<String>> _thailandProvinces = {
    'กรุงเทพมหานคร': ['กรุงเทพมหานคร'],
    'ภาคกลาง': [
      'Ayutthaya',
      'Lopburi',
      'Nakhon Pathom',
      'Nonthaburi',
      'Pathum Thani',
      'Samut Prakan',
      'Samut Sakhon',
      'Samut Songkhram',
      'Saraburi',
      'Sing Buri',
      'Suphan Buri',
    ],
    'ภาคเหนือ': [
      'Chiang Mai',
      'Chiang Rai',
      'Kamphaeng Phet',
      'Lampang',
      'Lamphun',
      'Mae Hong Son',
      'Nan',
      'Phayao',
      'Phichit',
      'Phitsanulok',
      'Phrae',
      'Sukhothai',
      'Tak',
      'Uttaradit',
      'Uthai Thani',
    ],
    'ภาคตะวันออกเฉียงเหนือ': [
      'Amnat Charoen',
      'Bueng Kan',
      'Buri Ram',
      'Chaiyaphum',
      'Kalasin',
      'Khon Kaen',
      'Loei',
      'Maha Sarakham',
      'Mukdahan',
      'Nakhon Phanom',
      'Nakhon Ratchasima',
      'Nong Bua Lamphu',
      'Nong Khai',
      'Roi Et',
      'Sakon Nakhon',
      'Si Sa Ket',
      'Surin',
      'Ubon Ratchathani',
      'Udon Thani',
      'Yasothon',
    ],
    'ภาคตะวันออก': [
      'Chachoengsao',
      'Chanthaburi',
      'Chonburi',
      'Prachinburi',
      'Rayong',
      'Sa Kaeo',
      'Trat',
    ],
    'ภาคตะวันตก': [
      'Kanchanaburi',
      'Phetchaburi',
      'Prachuap Khiri Khan',
      'Ratchaburi',
    ],
    'ภาคใต้': [
      'Chumphon',
      'Krabi',
      'Nakhon Si Thammarat',
      'Narathiwat',
      'Pattani',
      'Phang Nga',
      'Phatthalung',
      'Phuket',
      'Ranong',
      'Satun',
      'Songkhla',
      'Surat Thani',
      'Trang',
      'Yala',
    ],
  };

  final List<String> _workTypes = [
    'เต็มเวลา',
    'ไม่เต็มเวลา', 
    'ตามสัญญา',
    'อิสระ',
    'ชั่วคราว',
    'ฝึกงาน',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user != null) {
      _selectedProvinces = List<String>.from(user.workLocationPreference ?? []);
      _isWillingToRelocate = user.availability?['willingToRelocate'] ?? false;
      _preferredWorkType = user.availability?['preferredWorkType'] ?? 'เต็มเวลา';
      
      // Extract cities from selected provinces
      _selectedCities = [];
      for (String province in _selectedProvinces) {
        bool found = false;
        _thailandProvinces.forEach((region, cities) {
          if (cities.contains(province)) {
            _selectedCities.add(province);
            found = true;
          }
        });
        if (!found) {
          _selectedCities.add(province);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('ความต้องการสถานที่ทำงาน'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveData,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'บันทึก',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreferredLocationsSection(),
            const SizedBox(height: 24),
            _buildWorkTypeSection(),
            const SizedBox(height: 24),
            _buildRelocationSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferredLocationsSection() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'พื้นที่ทำงานที่ต้องการ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เลือกจังหวัด/เมืองที่คุณต้องการทำงาน',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._thailandProvinces.entries.map((entry) {
            final region = entry.key;
            final cities = entry.value;
            
            return ExpansionTile(
              title: Text(
                region,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${cities.where((city) => _selectedCities.contains(city)).length} of ${cities.length} selected',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cities.map((city) {
                      final isSelected = _selectedCities.contains(city);
                      return _buildLocationChip(
                        label: city,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCities.remove(city);
                              _selectedProvinces.remove(city);
                            } else {
                              _selectedCities.add(city);
                              _selectedProvinces.add(city);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          if (_selectedCities.isNotEmpty) ...[
            const Text(
              'พื้นที่ที่เลือก:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedCities.map((city) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCities.remove(city);
                            _selectedProvinces.remove(city);
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkTypeSection() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ประเภทงานที่ต้องการ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เลือกประเภทการจ้างงานที่ต้องการ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _workTypes.map((workType) {
              final isSelected = _preferredWorkType == workType;
              return _buildLocationChip(
                label: workType,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _preferredWorkType = workType;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelocationSection() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.moving_outlined,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'การย้ายที่ทำงาน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'คุณเต็มใจย้ายที่ทำงานสำหรับโอกาสที่เหมาะสมหรือไม่?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _isWillingToRelocate,
            onChanged: (value) {
              setState(() {
                _isWillingToRelocate = value;
              });
            },
            title: const Text('เต็มใจย้ายที่อยู่'),
            subtitle: Text(
              _isWillingToRelocate
                                  ? 'เปิดรับโอกาสงานในพื้นที่อื่น'
                : 'ต้องการทำงานในพื้นที่ที่เลือกเท่านั้น',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            activeColor: const Color(0xFF2196F3),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2196F3)
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _saveData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;
      if (user == null) return;

      final availability = {
        'willingToRelocate': _isWillingToRelocate,
        'preferredWorkType': _preferredWorkType,
        ...(user.availability ?? {}),
      };

      final updatedUser = user.copyWith(
        workLocationPreference: _selectedProvinces,
        availability: availability,
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .update(updatedUser.toMap());

      authProvider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปเดตค่ากำหนดสถานที่ทำงานเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 