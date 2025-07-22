import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import 'assistant_skills_data.dart';
import 'widgets/personal_info_section.dart';
import 'widgets/job_application_section.dart';
import 'widgets/skills_section.dart';

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
  
  // Legacy controllers (no longer used in UI but kept for data migration)
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationSpecialistController = TextEditingController();
  
  List<String> _selectedCompetencies = [];
  List<String> _selectedCounterSkills = [];
  List<String> _selectedSoftwareSkills = [];
  List<String> _selectedEqSkills = [];
  List<String> _selectedLimitations = [];
  bool _isLoading = false;

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

  void _onSkillToggle(String skill, bool selected, List<String> skillList) {
    setState(() {
      if (selected) {
        skillList.add(skill);
      } else {
        skillList.remove(skill);
      }
    });
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
                    PersonalInfoSection(
                      fullNameController: _fullNameController,
                      nickNameController: _nickNameController,
                      ageController: _ageController,
                      phoneNumberController: _phoneNumberController,
                    ),

                    const SizedBox(height: 16),

                    // Job Application Information Section
                    JobApplicationSection(
                      selectedEducationLevel: _selectedEducationLevel,
                      selectedJobType: _selectedJobType,
                      selectedJobReadiness: _selectedJobReadiness,
                      requestedMinSalaryController: _requestedMinSalaryController,
                      requestedMaxSalaryController: _requestedMaxSalaryController,
                      onEducationLevelChanged: (value) {
                        setState(() {
                          _selectedEducationLevel = value;
                        });
                      },
                      onJobTypeChanged: (value) {
                        setState(() {
                          _selectedJobType = value;
                        });
                      },
                      onJobReadinessChanged: (value) {
                        setState(() {
                          _selectedJobReadiness = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Core Competencies Section
                    SkillsSection(
                      title: 'ทักษะผู้ช่วยทันตแพทย์',
                      subtitle: 'เลือกทักษะงานที่สามารถทำได้',
                      availableSkills: AssistantSkillsData.availableCompetencies,
                      selectedSkills: _selectedCompetencies,
                      onSkillToggle: (skill, selected) => _onSkillToggle(skill, selected, _selectedCompetencies),
                      icon: Icons.medical_services,
                      iconColor: Colors.green[600],
                    ),

                    const SizedBox(height: 16),

                    // Counter Skills Section
                    SkillsSection(
                      title: 'ทักษะเคาน์เตอร์',
                      subtitle: 'เลือกทักษะเคาน์เตอร์ที่สามารถทำได้',
                      availableSkills: AssistantSkillsData.availableCounterSkills,
                      selectedSkills: _selectedCounterSkills,
                      onSkillToggle: (skill, selected) => _onSkillToggle(skill, selected, _selectedCounterSkills),
                      icon: Icons.medical_services,
                      iconColor: Colors.green[600],
                    ),

                    const SizedBox(height: 16),

                    // Software Skills Section
                    SkillsSection(
                      title: 'ซอฟต์แวร์ที่สามารถใช้ได้',
                      subtitle: 'เลือกซอฟต์แวร์ที่สามารถใช้ได้',
                      availableSkills: AssistantSkillsData.availableSoftwareSkills,
                      selectedSkills: _selectedSoftwareSkills,
                      onSkillToggle: (skill, selected) => _onSkillToggle(skill, selected, _selectedSoftwareSkills),
                      icon: Icons.medical_services,
                      iconColor: Colors.green[600],
                    ),

                    const SizedBox(height: 16),

                    // EQ Skills Section
                    SkillsSection(
                      title: 'ทักษะด้านอารมณ์และสังคม',
                      subtitle: 'เลือกทักษะด้านอารมณ์และสังคม',
                      availableSkills: AssistantSkillsData.availableEqSkills,
                      selectedSkills: _selectedEqSkills,
                      onSkillToggle: (skill, selected) => _onSkillToggle(skill, selected, _selectedEqSkills),
                      icon: Icons.medical_services,
                      iconColor: Colors.green[600],
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
          // Legacy fields - keeping existing data, not updating from UI
          'educationInstitute': _educationController.text.trim().isEmpty ? '' : _educationController.text.trim(),
          'experienceYears': _experienceController.text.trim().isEmpty ? 0 : int.tryParse(_experienceController.text.trim()) ?? 0,
          'educationSpecialist': _educationSpecialistController.text.trim().isEmpty ? '' : _educationSpecialistController.text.trim(),
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