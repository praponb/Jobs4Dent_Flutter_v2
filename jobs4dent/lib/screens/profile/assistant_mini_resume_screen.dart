import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

class AssistantMiniResumeScreen extends StatefulWidget {
  const AssistantMiniResumeScreen({super.key});

  @override
  State<AssistantMiniResumeScreen> createState() => _AssistantMiniResumeScreenState();
}

class _AssistantMiniResumeScreenState extends State<AssistantMiniResumeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Personal Information Controllers
  final _fullNameController = TextEditingController();
  final _nickNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  
  // Job Application Information Controllers and Variables
  final _requestedMinSalaryController = TextEditingController();
  final _requestedMaxSalaryController = TextEditingController();
  String? _selectedEducationLevel;
  String? _selectedJobType;
  String? _selectedJobReadiness;
  
  // Education and Experience Controllers
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationSpecialistController = TextEditingController();
  
  List<String> _selectedCompetencies = [];
  List<String> _selectedCounterSkills = [];
  List<String> _selectedSoftwareSkills = [];
  List<String> _selectedEqSkills = [];
  List<String> _selectedLimitations = [];
  bool _isLoading = false;

  // Predefined options for job application dropdowns
  final List<String> _educationLevelOptions = [
    'มัธยมศึกษาตอนต้น (ม.3)',
    'มัธยมศึกษาตอนปลาย (ม.6)',
    'ประกาศนียบัตรวิชาชีพ (ปวช.)',
    'ประกาศนียบัตรวิชาชีพชั้นสูง (ปวส.)',
    'ปริญญาตรี',
  ];

  final List<String> _jobTypeOptions = [
    'งานประจำ (Full-time)',
    'งานพาร์ทไทม์ (Part-time)',

  ];

  final List<String> _jobReadinessOptions = [
    'พร้อมเริ่มงานทันที',
    'ภายใน 15 วัน',
    'ภายใน 30 วัน',
    'มากกว่า 30 วัน',
  ];

  // Predefined competencies list for dental assistants
  final List<String> _availableCompetencies = [
    'ช่วยงานอุดฟัน',
    'ช่วยงานขูดหินปูน',
    'ช่วยงานถอนฟัน',
    'ช่วยงานผ่าฟันคุด',
    'ช่วยงานรักษารากฟัน',
    'ช่วยงานรักษารากเทียม',
    'ช่วยงานทำพิมพ์ปาก',
    'ช่วยงานจัดฟัน',
    'ช่วยถ่ายภาพ X-ray',
    'ล้างและทำความสะอาดเครื่องมือ',
    'เตรียมและห่อเครื่องมือ (Packaging)',
    'ใช้งานเครื่อง Autoclave',
  ];

final List<String> _availableCounterSkills = [
    'ทำนัดหมายคนไข้',
    'โทรยืนยันนัด (Confirm)',
    'ให้ข้อมูลการรักษาเบื้องต้น',
    'รับชำระเงิน/คิดเงิน',
    'ออกใบเสร็จ/เอกสารการเงิน',
    'สรุปยอดรายวัน',
    'ประสานงานกับ Lab',
    'จัดการสต็อกวัสดุ/ยา',
    'ใช้งานโปรแกรม Office พื้นฐาน',
    'จัดการ Social Media',
  ];

final List<String> _availableSoftwareSkills = [
    'FD',
    'JERA Dent',
    'DentCloud',
    'EZ Dentist Clinic',
    'Dentapop',
    'Dentaloncloud',
    'Neuraldent',
    'Cliniter',
    'MS Excel',
    'MS Word',
    'Canva',
  ];

final List<String> _availableEqSkills = [
    'มีใจรักงานบริการ',
    'มนุษยสัมพันธ์ดี',
    'ทำงานเป็นทีม',
    'มีความรับผิดชอบ',
    'อดทนต่อแรงกดดันได้ดี',
    'ซื่อสัตย์และตรงต่อเวลา',
    'กระตือรือร้น/พร้อมเรียนรู้',
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
        debugPrint('Loading assistant data from Firestore collection "users" for user: ${user.userId}');
        
        // Load fresh data from Firestore "users" collection
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data() as Map<String, dynamic>;
          
          setState(() {
            // Personal Information
            _fullNameController.text = data['fullName']?.toString() ?? '';
            _nickNameController.text = data['nickName']?.toString() ?? '';
            _ageController.text = data['age']?.toString() ?? '';
            _phoneNumberController.text = data['phoneNumber']?.toString() ?? '';
            
            // Job Application Information
            _selectedEducationLevel = data['educationLevel'];
            _selectedJobType = data['jobType'];
            _requestedMinSalaryController.text = data['minSalary']?.toString() ?? '';
            _requestedMaxSalaryController.text = data['maxSalary']?.toString() ?? '';
            _selectedJobReadiness = data['jobReadiness'];
            
            // Education and Experience
            _educationController.text = data['educationInstitute']?.toString() ?? '';
            _experienceController.text = data['experienceYears']?.toString() ?? '';
            _educationSpecialistController.text = data['educationSpecialist']?.toString() ?? '';
            _selectedCompetencies = List<String>.from(data['coreCompetencies'] ?? []);
            _selectedCounterSkills = List<String>.from(data['counterSkills'] ?? []);
            _selectedSoftwareSkills = List<String>.from(data['softwareSkills'] ?? []);
            _selectedEqSkills = List<String>.from(data['eqSkills'] ?? []);
            _selectedLimitations = List<String>.from(data['workLimitations'] ?? []);
          });

          debugPrint('Successfully loaded assistant mini-resume data from Firestore');
        }
      } else {
        debugPrint('User not found - cannot load assistant data');
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
      debugPrint('Error loading assistant data: $e');
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
    _fullNameController.dispose();
    _nickNameController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    _requestedMinSalaryController.dispose();
    _requestedMaxSalaryController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _educationSpecialistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('ประวัติผู้ช่วยทันตแพทย์'),
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
                    // Personal Information Section
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
                                Icons.person,
                                color: Colors.purple[600],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'ข้อมูลส่วนตัว',
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
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'ชื่อ-นามสกุล',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกชื่อ-นามสกุล';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nickNameController,
                            decoration: const InputDecoration(
                              labelText: 'ชื่อเล่น (ถ้ามี)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              // This field is optional, so no validation required
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'อายุ',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกอายุ';
                              }
                              final age = int.tryParse(value.trim());
                              if (age == null || age < 0) {
                                return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'เบอร์โทรศัพท์',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                    // Job Application Information Section
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
                                Icons.work,
                                color: Colors.blue[600],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'ข้อมูลการสมัครงาน',
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
                          DropdownButtonFormField<String>(
                            value: _selectedEducationLevel,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'ระดับการศึกษา',
                              border: OutlineInputBorder(),
                            ),
                            items: _educationLevelOptions.map((level) {
                              return DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedEducationLevel = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'กรุณาเลือกระดับการศึกษา';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedJobType,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'ประเภทงาน',
                              border: OutlineInputBorder(),
                            ),
                            items: _jobTypeOptions.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedJobType = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'กรุณาเลือกประเภทงาน';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _requestedMinSalaryController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'รายได้ที่ต้องการขั้นต่ำ (บาท/เดือน)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกรายได้ที่ต้องการ';
                              }
                              final salary = double.tryParse(value.trim());
                              if (salary == null || salary < 0) {
                                return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                              }
                              return null;
                            },
                                                     ),
                           const SizedBox(height: 16),
                           TextFormField(
                             controller: _requestedMaxSalaryController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'รายได้ที่ต้องการสูงสุด (บาท/เดือน)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกรายได้ที่ต้องการสูงสุด';
                              }
                              final salary = double.tryParse(value.trim());
                              if (salary == null || salary < 0) {
                                return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedJobReadiness,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'ความพร้อมเริ่มงาน',
                              border: OutlineInputBorder(),
                            ),
                            items: _jobReadinessOptions.map((readiness) {
                              return DropdownMenuItem(
                                value: readiness,
                                child: Text(readiness),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedJobReadiness = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'กรุณาเลือกความพร้อมเริ่มงาน';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Education Institute Section
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.grey[200]!),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       // สถาบันที่สำเร็จการศึกษา
                    //       Row(
                    //         children: [
                    //           Icon(
                    //             Icons.school,
                    //             color: Colors.blue[600],
                    //             size: 24,
                    //           ),
                    //           const SizedBox(width: 8),
                    //           const Expanded(
                    //             child: Text(
                    //               'สำเร็จการศึกษาจากสถาบัน?',
                    //               style: TextStyle(
                    //                 fontSize: 18,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.black87,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 16),
                    //       TextFormField(
                    //         controller: _educationController,
                    //         decoration: const InputDecoration(
                    //           hintText: 'เช่น วิทยาลัยการอาชีพ มหาวิทยาลัย สถาบันฝึกอบรม',
                    //           border: OutlineInputBorder(),
                    //           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //         ),
                    //         validator: (value) {
                    //           if (value == null || value.trim().isEmpty) {
                    //             return 'กรุณากรอกสถาบันที่สำเร็จการศึกษา';
                    //           }
                    //           return null;
                    //         },
                    //       ),
                    //       const SizedBox(height: 16),

                    //       Row(
                    //         children: [
                    //           Icon(
                    //             Icons.school,
                    //             color: Colors.blue[600],
                    //             size: 24,
                    //           ),
                    //           const SizedBox(width: 8),
                    //           const Expanded(
                    //             child: Text(
                    //               'ฝึกอบรมเพิ่มเติม (ถ้ามี)',
                    //               style: TextStyle(
                    //                 fontSize: 18,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.black87,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 16),
                    //       TextFormField(
                    //         controller: _educationSpecialistController,
                    //         maxLines: null,
                    //         minLines: 1,
                    //         decoration: const InputDecoration(
                    //           hintText: 'การฉีดยาชา การถ่ายเอ็กซ์เรย์ การดูแลผู้ป่วย\nเช่น โรงพยาบาล สถาบันฝึกอบรม',
                    //           border: OutlineInputBorder(),
                    //           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //           hintMaxLines: 2,
                    //         ),
                    //         validator: (value) {
                    //           // This field is optional, so no validation required
                    //           return null;
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // const SizedBox(height: 16),

                    // // Experience Years Section
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.grey[200]!),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Icon(
                    //             Icons.work_history,
                    //             color: Colors.blue[600],
                    //             size: 24,
                    //           ),
                    //           const SizedBox(width: 8),
                    //           const Text(
                    //             'ประสบการณ์ทำงาน (ปี)',
                    //             style: TextStyle(
                    //               fontSize: 18,
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.black87,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 16),
                    //       TextFormField(
                    //         controller: _experienceController,
                    //         decoration: const InputDecoration(
                    //           hintText: 'จำนวนปีของประสบการณ์ทำงานเป็นผู้ช่วยทันตแพทย์',
                    //           border: OutlineInputBorder(),
                    //           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //           suffixText: 'ปี',
                    //         ),
                    //         keyboardType: TextInputType.number,
                    //         validator: (value) {
                    //           if (value == null || value.trim().isEmpty) {
                    //             return 'กรุณากรอกจำนวนปีประสบการณ์';
                    //           }
                    //           final years = int.tryParse(value.trim());
                    //           if (years == null || years < 0) {
                    //             return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                    //           }
                    //           return null;
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // const SizedBox(height: 16),

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
                              const Expanded(
                                child: Text(
                                  'ทักษะผู้ช่วยทันตแพทย์',
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
                            'เลือกทักษะงานที่สามารถทำได้',
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

                    // Counter Skills Section
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
                              const Expanded(
                                child: Text(
                                  'ทักษะเคาน์เตอร์',
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
                            'เลือกทักษะเคาน์เตอร์ที่สามารถทำได้',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableCounterSkills.map((competency) {
                              final isSelected = _selectedCounterSkills.contains(competency);
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
                                      _selectedCounterSkills.add(competency);
                                    } else {
                                      _selectedCounterSkills.remove(competency);
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

                    // Software Skills Section
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
                              const Expanded(
                                child: Text(
                                  'ซอฟต์แวร์ที่สามารถใช้ได้',
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
                            'เลือกซอฟต์แวร์ที่สามารถใช้ได้',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableSoftwareSkills.map((competency) {
                              final isSelected = _selectedSoftwareSkills.contains(competency);
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
                                      _selectedSoftwareSkills.add(competency);
                                    } else {
                                      _selectedSoftwareSkills.remove(competency);
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

                    // EQ Skills Section
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
                              const Expanded(
                                child: Text(
                                  'ทักษะด้านอารมณ์และสังคม',
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
                            'เลือกทักษะด้านอารมณ์และสังคม',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableEqSkills.map((competency) {
                              final isSelected = _selectedEqSkills.contains(competency);
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
                                      _selectedEqSkills.add(competency);
                                    } else {
                                      _selectedEqSkills.remove(competency);
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
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.grey[200]!),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Icon(
                    //             Icons.block,
                    //             color: Colors.orange[600],
                    //             size: 24,
                    //           ),
                    //           const SizedBox(width: 8),
                    //           const Text(
                    //             'งานที่ไม่สะดวกทำ',
                    //             style: TextStyle(
                    //               fontSize: 18,
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.black87,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 8),
                    //       Text(
                    //         'เลือกงานที่ไม่สะดวกใจที่จะทำ (ไม่บังคับ)',
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           color: Colors.grey[600],
                    //         ),
                    //       ),
                    //       const SizedBox(height: 16),
                    //       Wrap(
                    //         spacing: 8,
                    //         runSpacing: 8,
                    //         children: _availableCompetencies.map((competency) {
                    //           final isSelected = _selectedLimitations.contains(competency);
                    //           return FilterChip(
                    //             label: Text(
                    //               competency,
                    //               style: TextStyle(
                    //                 color: isSelected ? Colors.white : Colors.grey[700],
                    //                 fontSize: 12,
                    //               ),
                    //             ),
                    //             selected: isSelected,
                    //             onSelected: (selected) {
                    //               setState(() {
                    //                 if (selected) {
                    //                   _selectedLimitations.add(competency);
                    //                 } else {
                    //                   _selectedLimitations.remove(competency);
                    //                 }
                    //               });
                    //             },
                    //             selectedColor: Colors.orange[600],
                    //             backgroundColor: Colors.grey[100],
                    //             checkmarkColor: Colors.white,
                    //           );
                    //         }).toList(),
                    //       ),
                    //     ],
                    //   ),
                    // ),

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
          content: Text('กรุณาเลือกความสามารถ/งานที่ทำได้อย่างน้อย 1 รายการ'),
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
        debugPrint('Saving assistant mini-resume data to Firestore collection "users" for user: ${user.userId}');
        
        // Update user profile directly in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .update({
          'fullName': _fullNameController.text.trim(),
          'nickName': _nickNameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()),
          'phoneNumber': _phoneNumberController.text.trim(),
          'educationLevel': _selectedEducationLevel,
          'jobType': _selectedJobType,
          'minSalary': double.tryParse(_requestedMinSalaryController.text.trim()),
          'maxSalary': double.tryParse(_requestedMaxSalaryController.text.trim()),
          'jobReadiness': _selectedJobReadiness,
          'educationInstitute': _educationController.text.trim(),
          'experienceYears': int.parse(_experienceController.text.trim()),
          'educationSpecialist': _educationSpecialistController.text.trim(),
          'coreCompetencies': _selectedCompetencies,
          'counterSkills': _selectedCounterSkills,
          'softwareSkills': _selectedSoftwareSkills,
          'eqSkills': _selectedEqSkills,
          'workLimitations': _selectedLimitations,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint('Successfully saved assistant mini-resume data to Firestore');

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
      debugPrint('Error saving assistant data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึก: ${e.toString()}'),
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