import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

class DentistMiniResumeScreen extends StatefulWidget {
  const DentistMiniResumeScreen({super.key});

  @override
  State<DentistMiniResumeScreen> createState() => _DentistMiniResumeScreenState();
}

class _DentistMiniResumeScreenState extends State<DentistMiniResumeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationSpecialistController = TextEditingController(); // Added missing controller
  
  List<String> _selectedCompetencies = [];
  List<String> _selectedLimitations = [];
  bool _isLoading = false;

  // Predefined competencies list
  final List<String> _availableCompetencies = [
    'อุดฟัน',
    'ขูดหินปูน',
    'ถอนฟัน',
    'ผ่าฟันคุดบน',
    'ผ่าฟันคุดล่าง',
    'ผ่าฟันฝัง',
    'รักษารากฟันกรามน้อย',
    'รักษารากฟันกรามใหญ่',
    'ฟอกสีฟัน',
    'ฟันปลอมถอดได้',
    'ฟันปลอมทั้งปาก',
    'ครอบฟัน',
    'สะพานฟัน',
    'วีเนียร์',
    'อุดปิดช่องฟันห่าง',
    'จัดฟัน',
    'ถอนฟันน้ำนม',
    'อุดฟันน้ำนม',
    'รักษารากฟันเด็ก',
    'ผ่าตัดขากรรไกร',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;
      
      if (user != null) {
        print('Loading dentist data from Firestore collection "users" for user: ${user.userId}');
        
        // Load fresh data from Firestore "users" collection
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data() as Map<String, dynamic>;
          
          setState(() {
            _educationController.text = data['educationInstitute']?.toString() ?? '';
            _experienceController.text = data['experienceYears']?.toString() ?? '';
            _educationSpecialistController.text = data['educationSpecialist']?.toString() ?? ''; // Load educationSpecialist
            _selectedCompetencies = List<String>.from(data['coreCompetencies'] ?? []);
            _selectedLimitations = List<String>.from(data['workLimitations'] ?? []);
          });

          print('Successfully loaded dentist mini-resume data from Firestore');
        }
      } else {
        print('User not found - cannot load dentist data');
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
      print('Error loading dentist data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: ${e.toString()}'),
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

  @override
  void dispose() {
    _educationController.dispose();
    _experienceController.dispose();
    _educationSpecialistController.dispose(); // Dispose new controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('ข้อมูลสรุปสำหรับสมัครงาน'),
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'กำลังโหลดข้อมูลจาก Firestore...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Education Institute Section
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

                    //สถาบันที่สำเร็จการศึกษา
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'จบทันตกรรมทั่วไปจากสถาบัน?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _educationController,
                      decoration: const InputDecoration(
                        hintText: 'เช่น จุฬาฯ มหิดล เชียงใหม่ มศว.',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกสถาบันที่สำเร็จการศึกษาทันตกรรมทั่วไป';
                        }
                        return null;
                      },
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'จบทันตแพทย์เฉพาะทาง(ถ้ามี)จากสถาบัน',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _educationSpecialistController,
                      maxLines: null,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'จัดฟัน รักษารากฟัน ฟันปลอม\nเช่น จุฬาฯ มหิดล เชียงใหม่ มศว.',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintMaxLines: 2,
                      ),
                      validator: (value) {
                        // This field is optional, so no validation required
                        return null;
                      },
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Experience Years Section
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
                    Row(
                      children: [
                        Icon(
                          Icons.work_history,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ประสบการณ์ทำงาน (ปี)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        hintText: 'จำนวนปีของประสบการณ์ทำงาน',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixText: 'ปี',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกจำนวนปีประสบการณ์';
                        }
                        final years = int.tryParse(value.trim());
                        if (years == null || years < 0) {
                          return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Core Competencies Section
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
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: Colors.green[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ความสามารถ/หัตถการที่ทำได้',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เลือกหัตถการที่มีความเชี่ยวชาญ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableCompetencies.map((competency) {
                        final isSelected = _selectedCompetencies.contains(competency);
                        return FilterChip(
                          label: Text(
                            competency,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCompetencies.add(competency);
                              } else {
                                _selectedCompetencies.remove(competency);
                              }
                            });
                          },
                          selectedColor: Colors.green[600],
                          backgroundColor: Colors.grey[100],
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Work Limitations Section
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
                    Row(
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.orange[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'หัตถการที่ไม่สะดวกทำ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เลือกหัตถการที่ไม่สะดวกใจที่จะทำ (ไม่บังคับ)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableCompetencies.map((competency) {
                        final isSelected = _selectedLimitations.contains(competency);
                        return FilterChip(
                          label: Text(
                            competency,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedLimitations.add(competency);
                              } else {
                                _selectedLimitations.remove(competency);
                              }
                            });
                          },
                          selectedColor: Colors.orange[600],
                          backgroundColor: Colors.grey[100],
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
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
                      : const Text(
                          'บันทึกข้อมูล',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Info Section
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ข้อมูลนี้จะถูกใช้เป็นข้อมูลหลักในการสมัครงาน และจะช่วยให้คลินิกสามารถประเมินคุณสมบัติของคุณได้อย่างรวดเร็ว',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCompetencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกความสามารถ/หัตถการที่ทำได้อย่างน้อย 1 รายการ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;

      if (user != null) {
        print('Saving dentist mini-resume data to Firestore collection "users" for user: ${user.userId}');
        
        // Update user profile directly in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .update({
          'educationInstitute': _educationController.text.trim(),
          'experienceYears': int.parse(_experienceController.text.trim()),
          'educationSpecialist': _educationSpecialistController.text.trim(), // Save educationSpecialist
          'coreCompetencies': _selectedCompetencies,
          'workLimitations': _selectedLimitations,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('Successfully saved dentist mini-resume data to Firestore');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บันทึกข้อมูลสำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
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