import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

class SkillsSpecialtiesScreen extends StatefulWidget {
  const SkillsSpecialtiesScreen({super.key});

  @override
  State<SkillsSpecialtiesScreen> createState() => _SkillsSpecialtiesScreenState();
}

class _SkillsSpecialtiesScreenState extends State<SkillsSpecialtiesScreen> {
  bool _isLoading = false;
  List<String> _selectedSkills = [];
  List<String> _selectedSpecialties = [];
  List<String> _selectedCertifications = [];

  final List<String> _availableSkills = [
    'การดูแลผู้ป่วย',
    'หัตถการทันตกรรม',
    'การถ่ายเอ็กซ์เรย์',
    'การฆ่าเชื้อ',
    'การบำรุงรักษาอุปกรณ์',
    'การให้ความรู้ผู้ป่วย',
    'ซอฟต์แวร์ทันตกรรม',
    'การดูแลฉุกเฉิน',
    'การจัดการอาการปวด',
    'การควบคุมเชื้อ',
    'การถ่ายภาพทันตกรรม',
    'การพิมพ์ฟันดิจิทัล',
    'CAD/CAM',
    'ทันตกรรมเลเซอร์',
    'ทันตกรรมใส่ยาสลบ',
  ];

  final List<String> _availableSpecialties = [
    'ทันตกรรมทั่วไป',
    'จัดฟัน',
    'รักษารากฟัน',
    'ปริทันตวิทยา (โรคเหงือก)',
    'ศัลยกรรมช่องปาก',
    'ประดิษฐทันต์',
    'ทันตกรรมเด็ก',
    'ทันตกรรมความงาม',
    'ทันตกรรมรากเทียม',
    'พยาธิวิทยาช่องปาก',
    'ศัลยกรรมช่องปากและแม็กซิลโลเฟเชียล',
    'ทันตกรรมบูรณะ',
    'ทันตกรรมป้องกัน',
    'ทันตกรรมฉุกเฉิน',
    'ทันตกรรมผู้สูงอายุ',
  ];

  final List<String> _availableCertifications = [
    'ใบรับรองการช่วยชีวิต (CPR)',
    'การฉีดยาชาเฉพาะที่',
    'การให้แก๊สไนตรัสออกไซด์',
    'ผู้ช่วยทันตแพทย์ขยายหน้าที่ (EFDA)',
    'ผู้ช่วยทันตแพทย์จดทะเบียน (RDA)',
    'ผู้ช่วยทันตแพทย์ได้รับการรับรอง (CDA)',
    'ความปลอดภัยด้านรังสี',
    'การปฏิบัติตาม OSHA',
    'การควบคุมเชื้อ',
    'ใบอนุญาตนักสุขอนามัยช่องปาก',
    'ใบรับรองคณะกรรมการความเชี่ยวชาญ',
    'หน่วยการศึกษาต่อเนื่อง (CEU)',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user != null) {
      _selectedSkills = List<String>.from(user.skills ?? []);
      _selectedSpecialties = List<String>.from(user.specialties ?? []);
      _selectedCertifications = List<String>.from(user.certifications ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('ทักษะและความเชี่ยวชาญ'),
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
            _buildSkillsSection(),
            const SizedBox(height: 24),
            _buildSpecialtiesSection(),
            const SizedBox(height: 24),
            _buildCertificationsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return _buildSectionCard(
      title: 'ทักษะวิชาชีพ',
      subtitle: 'เลือกทักษะและความสามารถวิชาชีพของคุณ',
      icon: Icons.psychology_outlined,
      children: [
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSkills.map((skill) {
            final isSelected = _selectedSkills.contains(skill);
            return _buildSelectableChip(
              label: skill,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSkills.remove(skill);
                  } else {
                    _selectedSkills.add(skill);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildAddCustomButton(
          onPressed: () => _showAddCustomDialog(
                            title: 'เพิ่มทักษะกำหนดเอง',
                            hintText: 'ใส่ทักษะที่กำหนดเอง',
            onAdd: (skill) {
              setState(() {
                if (!_selectedSkills.contains(skill)) {
                  _selectedSkills.add(skill);
                  _availableSkills.add(skill);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtiesSection() {
    return _buildSectionCard(
      title: 'ความเชี่ยวชาญ',
      subtitle: 'เลือกความเชี่ยวชาญทางทันตกรรมและสาขาที่มีความเชี่ยวชาญ',
      icon: Icons.medical_services_outlined,
      children: [
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSpecialties.map((specialty) {
            final isSelected = _selectedSpecialties.contains(specialty);
            return _buildSelectableChip(
              label: specialty,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSpecialties.remove(specialty);
                  } else {
                    _selectedSpecialties.add(specialty);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildAddCustomButton(
          onPressed: () => _showAddCustomDialog(
                            title: 'เพิ่มความเชี่ยวชาญกำหนดเอง',
                            hintText: 'ใส่ความเชี่ยวชาญที่กำหนดเอง',
            onAdd: (specialty) {
              setState(() {
                if (!_selectedSpecialties.contains(specialty)) {
                  _selectedSpecialties.add(specialty);
                  _availableSpecialties.add(specialty);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return _buildSectionCard(
                    title: 'ใบรับรอง และใบอนุญาต',
                  subtitle: 'เลือกใบรับรองและใบอนุญาตของคุณ',
      icon: Icons.verified_outlined,
      children: [
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCertifications.map((certification) {
            final isSelected = _selectedCertifications.contains(certification);
            return _buildSelectableChip(
              label: certification,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCertifications.remove(certification);
                  } else {
                    _selectedCertifications.add(certification);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildAddCustomButton(
          onPressed: () => _showAddCustomDialog(
                            title: 'เพิ่มใบรับรองกำหนดเอง',
                            hintText: 'ใส่ใบรับรองที่กำหนดเอง',
            onAdd: (certification) {
              setState(() {
                if (!_selectedCertifications.contains(certification)) {
                  _selectedCertifications.add(certification);
                  _availableCertifications.add(certification);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
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
                child: Icon(
                  icon,
                  color: const Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2196F3)
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomButton({required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
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
              Icons.add,
              size: 16,
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(width: 8),
            Text(
              'เพิ่มกำหนดเอง',
              style: TextStyle(
                color: const Color(0xFF2196F3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomDialog({
    required String title,
    required String hintText,
    required Function(String) onAdd,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
                          child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onAdd(text);
                Navigator.of(context).pop();
              }
            },
                          child: const Text('เพิ่ม'),
          ),
        ],
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

      final updatedUser = user.copyWith(
        skills: _selectedSkills,
        specialties: _selectedSpecialties,
        certifications: _selectedCertifications,
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
            content: Text('อัปเดตทักษะและความเชี่ยวชาญเรียบร้อยแล้ว'),
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