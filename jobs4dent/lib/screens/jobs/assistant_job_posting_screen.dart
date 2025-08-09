import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/assistant_job_model.dart';
import 'assistant_job_constants.dart';
import 'job_posting_form_widgets.dart';
import 'job_posting_constants.dart';
import 'job_posting_utils.dart';

class AssistantJobPostingScreen extends StatefulWidget {
  final AssistantJobModel? jobToEdit;

  const AssistantJobPostingScreen({super.key, this.jobToEdit});

  @override
  State<AssistantJobPostingScreen> createState() => _AssistantJobPostingScreenState();
}

class _AssistantJobPostingScreenState extends State<AssistantJobPostingScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Controllers
  final _clinicNameAndBranchController = TextEditingController();
  final _titlePostController = TextEditingController();
  final _payPerDayPartTimeController = TextEditingController();
  final _payPerHourPartTimeController = TextEditingController();
  final _salaryFullTimeController = TextEditingController();
  final _totalIncomeFullTimeController = TextEditingController();
  final _workTimeStartController = TextEditingController();
  final _workTimeEndController = TextEditingController();
  final _perkController = TextEditingController();
  final _perkPostController = TextEditingController();

  //--------------------Add manually by Aek---------------------------------------
  String _selectedProvinceZones = JobPostingConstants.thaiProvinceZones.first;
  String _selectedLocationZones = JobPostingConstants.thaiLocationZones.first.first;
  String _selectedTrainLine = JobPostingConstants.thaiTrainLines.last;
  String _selectedTrainStation = JobPostingConstants.thaiTrainStations.last.first;
  //-------------------------------------------------------------------------------

  // State variables
  bool _isLoading = false;
  String _selectedWorkType = AssistantJobConstants.workTypes.first;
  List<String> _selectedSkills = [];
  List<DateTime> _selectedWorkDays = [];
  String _selectedPaymentTerm = AssistantJobConstants.paymentTermsPartTime.first;
  String _selectedDayOff = AssistantJobConstants.dayOffFullTimeOptions.first;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _clinicNameAndBranchController.dispose();
    _titlePostController.dispose();
    _payPerDayPartTimeController.dispose();
    _payPerHourPartTimeController.dispose();
    _salaryFullTimeController.dispose();
    _totalIncomeFullTimeController.dispose();
    _workTimeStartController.dispose();
    _workTimeEndController.dispose();
    _perkController.dispose();
    _perkPostController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.jobToEdit != null) {
      final job = widget.jobToEdit!;
      _clinicNameAndBranchController.text = job.clinicNameAndBranch;
      _titlePostController.text = job.titlePost;
      _selectedSkills = List.from(job.skillAssistant);
      _selectedWorkType = job.workType;
      _selectedWorkDays = job.workDayPartTime ?? [];
      _selectedPaymentTerm = job.paymentTermPartTime ?? AssistantJobConstants.paymentTermsPartTime.first;
      _payPerDayPartTimeController.text = job.payPerDayPartTime ?? '';
      _payPerHourPartTimeController.text = job.payPerHourPartTime ?? '';
      _salaryFullTimeController.text = job.salaryFullTime ?? '';
      _totalIncomeFullTimeController.text = job.totalIncomeFullTime ?? '';
      _selectedDayOff = job.dayOffFullTime ?? AssistantJobConstants.dayOffFullTimeOptions.first;
      _workTimeStartController.text = job.workTimeStart ?? '';
      _workTimeEndController.text = job.workTimeEnd ?? '';
      _perkController.text = job.perk ?? '';
      _perkPostController.text = job.perk ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobToEdit != null ? 'แก้ไขประกาศงานผู้ช่วย' : 'ประกาศงานผู้ช่วย'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // หัวข้อโพส Section
              _buildSectionHeader('หัวข้อโพส'),
              const SizedBox(height: 16),
              // Title Post
              _buildTextFormField(
                controller: _titlePostController,
                label: 'หัวข้อโพส',
                hintText: 'รับสมัครผู้ช่วยทันตแพทย์ประจำ',
                maxLength: 180,
                validator: (value) => _requiredValidator(value, 'หัวข้อโพส'),
              ),
              const SizedBox(height: 24),
              _buildTextFormField(
                controller: _clinicNameAndBranchController,
                label: 'ชื่อคลินิกและสาขา',
                hintText: 'คลินิกที่รับสมัคร',
                maxLength: 80,
                validator: (value) => _requiredValidator(value, 'Branch'),
              ),
              const SizedBox(height: 16),

  //--------------------Add manually by Aek---------------------------------------
              // Location Information Section
              JobPostingFormWidgets.buildSectionHeader(context, 'ข้อมูลสถานที่'),
              const SizedBox(height: 16),

              // Province
              JobPostingFormWidgets.buildDropdownField<String>(
                'โซนที่ตั้ง',
                _selectedProvinceZones,
                JobPostingConstants.thaiProvinceZones,
                (value) => _onProvinceChanged(value!),
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // City/Location Zone
              JobPostingFormWidgets.buildDropdownField<String>(
                'จังหวัด/โซนในจังหวัด',
                JobPostingUtils.getValidLocationZone(_selectedProvinceZones, _selectedLocationZones),
                JobPostingUtils.getCurrentLocationZones(_selectedProvinceZones),
                (value) => setState(() => _selectedLocationZones = value!),
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Train Line
              JobPostingFormWidgets.buildDropdownField<String>(
                'รถไฟฟ้า',
                _selectedTrainLine,
                JobPostingConstants.thaiTrainLines,
                (value) => _onTrainLineChanged(value!),
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Train Station
              JobPostingFormWidgets.buildDropdownField<String>(
                'สถานีรถไฟฟ้า',
                JobPostingUtils.getValidTrainStation(_selectedTrainLine, _selectedTrainStation),
                JobPostingUtils.getCurrentTrainStations(_selectedTrainLine),
                (value) => setState(() => _selectedTrainStation = value!),
                isRequired: true,
              ),
              const SizedBox(height: 24),
  //-------------------------------------------------------------------------------
  
              // ประเภทงาน Section
              _buildSectionHeader('ประเภทงาน'),
              const SizedBox(height: 16),
              _buildWorkTypeToggle(),
              const SizedBox(height: 24),

              // ตำแหน่งผู้ช่วยทันตแพทย์ที่รับสมัคร Section
              _buildSectionHeader('ตำแหน่งผู้ช่วยทันตแพทย์ที่รับสมัคร'),
              const SizedBox(height: 16),
              _buildSkillSelector(),
              const SizedBox(height: 24),

              // Conditional fields based on work type
              if (_selectedWorkType == 'Part-time') ..._buildPartTimeFields(),
              if (_selectedWorkType == 'Full-time') ..._buildFullTimeFields(),

              const SizedBox(height: 32),

              // Post Job Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _postJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ประกาศงานผู้ช่วย',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkTypeToggle() {
    return Row(
      children: AssistantJobConstants.workTypes.map((type) {
        final isSelected = _selectedWorkType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedWorkType = type),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          _selectedSkills.isEmpty
              ? 'เลือกตำแหน่งผู้ช่วยทันตแพทย์ที่รับสมัคร'
              : '${_selectedSkills.length} ตำแหน่งที่เลือก',
          style: TextStyle(
            color: _selectedSkills.isEmpty ? Colors.grey[600] : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: _showSkillSelectionModal,
      ),
    );
  }

  void _showSkillSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<String> tempSelectedSkills = List.from(_selectedSkills);
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'เลือกทักษะผู้ช่วยทันตแพทย์',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: AssistantJobConstants.allAssistantSkills.map((skill) {
                        final isSelected = tempSelectedSkills.contains(skill);
                        return CheckboxListTile(
                          title: Text(skill),
                          value: isSelected,
                          onChanged: (value) {
                            setModalState(() {
                              if (value!) {
                                tempSelectedSkills.add(skill);
                              } else {
                                tempSelectedSkills.remove(skill);
                              }
                            });
                          },
                          activeColor: Colors.blue,
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ยกเลิก'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _selectedSkills = tempSelectedSkills);
                            Navigator.pop(context);
                          },
                          child: const Text('ยืนยัน'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPartTimeFields() {
    return [
      // วันทำงานสำหรับ Part-Time
      _buildSectionHeader('วันทำงานสำหรับ Part-Time'),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(
            _selectedWorkDays.isEmpty
                ? 'เลือกวันทำงาน'
                : '${_selectedWorkDays.length} วันที่เลือก',
            style: TextStyle(
              color: _selectedWorkDays.isEmpty ? Colors.grey[600] : Colors.black,
            ),
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: _showDatePicker,
        ),
      ),
      const SizedBox(height: 24),

      // เงื่อนไขการจ่าย Part-Time
      _buildSectionHeader('เงื่อนไขการจ่าย Part-Time'),
      const SizedBox(height: 16),
      _buildDropdownField(
        value: _selectedPaymentTerm,
        items: AssistantJobConstants.paymentTermsPartTime,
        onChanged: (value) => setState(() => _selectedPaymentTerm = value!),
      ),
      const SizedBox(height: 24),

      // Rate Section
      _buildSectionHeader('ค่าแรงต่อวันพาร์ทไทม์'),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildTextFormField(
              controller: _payPerDayPartTimeController,
              label: 'ค่าแรงต่อวัน',
              hintText: '800',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextFormField(
              controller: _payPerHourPartTimeController,
              label: 'ค่าแรงต่อชั่วโมง',
              hintText: '100',
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // Note field
      _buildSectionHeader('รายละเอียดโพส - สวัสดิการ'),
      const SizedBox(height: 16),
      _buildTextFormField(
        controller: _perkPostController,
        label: '',
        hintText: 'สวัสดิการและรายละเอียดเพิ่มเติม...',
        maxLines: 3,
        maxLength: 180,
      ),
    ];
  }

  List<Widget> _buildFullTimeFields() {
    return [
      // รายได้ Full-Time
      _buildSectionHeader('รายได้ Full-Time'),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildTextFormField(
              controller: _salaryFullTimeController,
              label: 'เงินเดือน',
              hintText: '15000',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextFormField(
              controller: _totalIncomeFullTimeController,
              label: 'รายได้รวม',
              hintText: '20000',
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // จำนวนวันหยุดของ Full-time
      _buildSectionHeader('จำนวนวันหยุดของ Full-time'),
      const SizedBox(height: 16),
      _buildDropdownField(
        value: _selectedDayOff,
        items: AssistantJobConstants.dayOffFullTimeOptions,
        onChanged: (value) => setState(() => _selectedDayOff = value!),
      ),
      const SizedBox(height: 24),

      // เวลาทำงานของ Full-time
      _buildSectionHeader('เวลาทำงานของ Full-time'),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildTextFormField(
              controller: _workTimeStartController,
              label: 'เวลาเริ่มงาน',
              hintText: '09:00',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextFormField(
              controller: _workTimeEndController,
              label: 'เวลาเลิกงาน',
              hintText: '18:00',
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // รายละเอียดโพส - สวัสดิการ
      _buildSectionHeader('รายละเอียดโพส - สวัสดิการ'),
      const SizedBox(height: 16),
      _buildTextFormField(
        controller: _perkController,
        label: '',
        hintText: 'สวัสดิการและรายละเอียดเพิ่มเติม...',
        maxLines: 5,
        maxLength: 2000,
      ),
      // const SizedBox(height: 24),

      // Title Post for Full-time
      // _buildTextFormField(
      //   controller: _titlePostController,
      //   label: 'หัวข้อโพส',
      //   hintText: 'รับสมัครผู้ช่วยทันตแพทย์ประจำ',
      //   maxLength: 180,
      //   validator: (value) => _requiredValidator(value, 'หัวข้อโพส'),
      // ),
    ];
  }
  //--------------------Add manually by Aek---------------------------------------
  void _onProvinceChanged(String newProvince) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedProvinceZones = newProvince;
        final newLocations = JobPostingUtils.getCurrentLocationZones(newProvince);
        if (newLocations.isNotEmpty) {
          _selectedLocationZones = newLocations.first;
        }
      });
    });
  }

  void _onTrainLineChanged(String newTrainLine) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedTrainLine = newTrainLine;
        final newStations = JobPostingUtils.getCurrentTrainStations(newTrainLine);
        if (newStations.isNotEmpty) {
          _selectedTrainStation = newStations.first;
        }
      });
    });
  }
//---------------------------------------------------------------------------------
  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    // This will show a simple date picker for now
    // You might want to implement a multi-date picker in the future
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (!_selectedWorkDays.contains(picked)) {
          _selectedWorkDays.add(picked);
        }
      });
    }
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    return null;
  }

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกตำแหน่งผู้ช่วยทันตแพทย์อย่างน้อย 1 ตำแหน่ง')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel == null) {
        throw Exception('ข้อมูลผู้ใช้ไม่พร้อมใช้งาน');
      }

      final user = authProvider.userModel!;
      final now = DateTime.now();

      final assistantJob = AssistantJobModel(
        jobId: widget.jobToEdit?.jobId ?? now.millisecondsSinceEpoch.toString(),
        clinicId: user.userId,
        clinicNameAndBranch: _clinicNameAndBranchController.text.trim(),
        titlePost: _titlePostController.text.trim(),
        skillAssistant: _selectedSkills,
        workType: _selectedWorkType,
        workDayPartTime: _selectedWorkType == 'Part-time' ? _selectedWorkDays : null,
        paymentTermPartTime: _selectedWorkType == 'Part-time' ? _selectedPaymentTerm : null,
        payPerDayPartTime: _selectedWorkType == 'Part-time' ? _payPerDayPartTimeController.text.trim() : null,
        payPerHourPartTime: _selectedWorkType == 'Part-time' ? _payPerHourPartTimeController.text.trim() : null,
        salaryFullTime: _selectedWorkType == 'Full-time' ? _salaryFullTimeController.text.trim() : null,
        totalIncomeFullTime: _selectedWorkType == 'Full-time' ? _totalIncomeFullTimeController.text.trim() : null,
        dayOffFullTime: _selectedWorkType == 'Full-time' ? _selectedDayOff : null,
        workTimeStart: _selectedWorkType == 'Full-time' ? _workTimeStartController.text.trim() : null,
        workTimeEnd: _selectedWorkType == 'Full-time' ? _workTimeEndController.text.trim() : null,
        perk: _selectedWorkType == 'Full-time' 
            ? _perkController.text.trim() 
            : (_perkPostController.text.trim().isNotEmpty ? _perkPostController.text.trim() : null),
        createdAt: widget.jobToEdit?.createdAt ?? now,
        updatedAt: now,
      );

      await _firestore
          .collection('job_posts_assistant')
          .doc(assistantJob.jobId)
          .set(assistantJob.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.jobToEdit != null 
                  ? 'อัปเดตงานสำเร็จแล้ว!' 
                  : 'โพสต์งานสำเร็จแล้ว!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error posting assistant job: $e'); // Using debugPrint as per memory
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 