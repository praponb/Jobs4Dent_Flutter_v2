import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/job_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_model.dart';
import 'job_posting_constants.dart';
import 'job_posting_form_widgets.dart';
import 'job_posting_utils.dart';

class DentistJobPostingScreen extends StatefulWidget {
  final JobModel? jobToEdit;

  const DentistJobPostingScreen({super.key, this.jobToEdit});

  @override
  State<DentistJobPostingScreen> createState() =>
      _DentistJobPostingScreenState();
}

class _DentistJobPostingScreenState extends State<DentistJobPostingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _perksController = TextEditingController();
  final _workingDaysController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _additionalRequirementsController = TextEditingController();

  // Selection variables
  String _selectedJobCategory = JobConstants.jobCategories.first;
  String _selectedExperienceLevel = 'ไม่มีประสบการณ์';
  String _selectedSalaryType = '50:50';
  String _selectedProvinceZones = JobPostingConstants.thaiProvinceZones.first;
  String _selectedLocationZones =
      JobPostingConstants.thaiLocationZones.first.first;
  String _selectedTrainLine = JobPostingConstants.thaiTrainLines.last;
  String _selectedTrainStation =
      JobPostingConstants.thaiTrainStations.last.first;
  String _selectedWorkingType = JobPostingConstants.workingTypes.first;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minSalaryController.dispose();
    _perksController.dispose();
    _workingDaysController.dispose();
    _workingHoursController.dispose();
    _additionalRequirementsController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.jobToEdit != null) {
      final job = widget.jobToEdit!;
      final formData = JobPostingUtils.initializeFormFromJob(job);

      _titleController.text = formData['title'];
      _descriptionController.text = formData['description'];
      _selectedJobCategory = formData['jobCategory'];
      _selectedExperienceLevel = formData['experienceLevel'];
      _selectedSalaryType = formData['salaryType'];

      // Validate and set location
      final locationData = JobPostingUtils.validateLocationForEditing(job);
      _selectedProvinceZones = locationData['province']!;
      _selectedLocationZones = locationData['city']!;

      // Validate and set train info
      final trainData = JobPostingUtils.validateTrainForEditing(job);
      _selectedTrainLine = trainData['trainLine']!;
      _selectedTrainStation = trainData['trainStation']!;

      _minSalaryController.text = formData['minSalary'];
      _perksController.text = formData['perks'];
      _workingDaysController.text = formData['workingDays'];
      _workingHoursController.text = formData['workingHours'];
      _additionalRequirementsController.text =
          formData['additionalRequirements'];
      _selectedWorkingType = formData['workingType'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.jobToEdit != null ? 'แก้ไขประกาศงาน' : 'ประกาศงานใหม่',
        ),
        actions: [
          Consumer<JobProvider>(
            builder: (context, jobProvider, child) {
              return TextButton(
                onPressed: jobProvider.isLoading ? null : _postJob,
                child: jobProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.jobToEdit != null ? 'อัปเดต' : 'ประกาศ',
                        style: const TextStyle(color: Colors.white),
                      ),
              );
            },
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
              JobPostingFormWidgets.buildSectionHeader(
                context,
                'ข้อมูลพื้นฐาน',
              ),
              const SizedBox(height: 16),

              // Job Title
              JobPostingFormWidgets.buildTextFormField(
                _titleController,
                'หัวข้อ',
                hintText:
                    'เช่น รับสมัครทันตแพทย์ประจำ(สามารถเลือกวันลงตรวจได้)',
                isRequired: true,
                validator: (value) =>
                    JobPostingFormWidgets.requiredValidator(value, 'หัวข้อ'),
              ),
              const SizedBox(height: 16),

              // Job Category
              JobPostingFormWidgets.buildJobCategoryDropdown(
                _selectedJobCategory,
                (value) => setState(() => _selectedJobCategory = value!),
              ),
              const SizedBox(height: 16),

              // Job Description
              JobPostingFormWidgets.buildTextFormField(
                _descriptionController,
                'รายละเอียดงาน',
                hintText: 'อธิบายลักษณะงาน และข้อมูลการติดต่อ...',
                maxLines: 5,
                isRequired: true,
                validator: (value) => JobPostingFormWidgets.requiredValidator(
                  value,
                  'รายละเอียดงาน',
                ),
              ),
              const SizedBox(height: 24),

              // Location Information Section
              JobPostingFormWidgets.buildSectionHeader(
                context,
                'ข้อมูลสถานที่',
              ),
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
                JobPostingUtils.getValidLocationZone(
                  _selectedProvinceZones,
                  _selectedLocationZones,
                ),
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
                JobPostingUtils.getValidTrainStation(
                  _selectedTrainLine,
                  _selectedTrainStation,
                ),
                JobPostingUtils.getCurrentTrainStations(_selectedTrainLine),
                (value) => setState(() => _selectedTrainStation = value!),
                isRequired: true,
              ),
              const SizedBox(height: 24),

              // Experience Section
              JobPostingFormWidgets.buildSectionHeader(
                context,
                'ข้อกำหนดประสบการณ์',
              ),
              const SizedBox(height: 16),

              // Experience Level
              JobPostingFormWidgets.buildExperienceLevelDropdown(
                _selectedExperienceLevel,
                (value) => setState(() => _selectedExperienceLevel = value!),
              ),
              const SizedBox(height: 24),

              // Salary Information Section
              JobPostingFormWidgets.buildSectionHeader(context, 'ข้อมูลรายได้'),
              const SizedBox(height: 16),

              // Salary Type
              JobPostingFormWidgets.buildSalaryTypeDropdown(
                _selectedSalaryType,
                (value) => setState(() => _selectedSalaryType = value!),
              ),
              const SizedBox(height: 16),

              // Minimum Salary
              JobPostingFormWidgets.buildTextFormField(
                _minSalaryController,
                'ประกันรายได้ขั้นต่ำ (บาท/วัน)',
                hintText: '2500',
                keyboardType: TextInputType.number,
                validator: JobPostingFormWidgets.numberValidator,
              ),
              const SizedBox(height: 16),

              // Other Benefits
              JobPostingFormWidgets.buildTextFormField(
                _perksController,
                'อื่นๆ',
                hintText: 'สิทธิพิเศษ, เวลางานยืดหยุ่น ฯลฯ',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Schedule Information Section
              JobPostingFormWidgets.buildSectionHeader(
                context,
                'ข้อมูลตารางงาน',
              ),
              const SizedBox(height: 16),

              // Working Type
              JobPostingFormWidgets.buildDropdownField<String>(
                'ประจำ หรือ part-time',
                _selectedWorkingType,
                JobPostingConstants.workingTypes,
                (value) => setState(() => _selectedWorkingType = value!),
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Working Days
              JobPostingFormWidgets.buildTextFormField(
                _workingDaysController,
                'วัน ทำงาน',
                hintText: 'เช่น จันทร์-ศุกร์',
              ),
              const SizedBox(height: 16),

              // Working Hours
              JobPostingFormWidgets.buildTextFormField(
                _workingHoursController,
                'เวลา ทำงาน',
                hintText: 'เช่น 09:00น.-18:00น.',
              ),
              const SizedBox(height: 24),

              // Additional Information Section
              JobPostingFormWidgets.buildSectionHeader(
                context,
                'ข้อมูลเพิ่มเติม',
              ),
              const SizedBox(height: 16),

              // Additional Requirements
              JobPostingFormWidgets.buildTextFormField(
                _additionalRequirementsController,
                'ข้อกำหนดเพิ่มเติม',
                hintText: 'ข้อกำหนดเฉพาะอื่นๆ...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Submit Button
              Consumer<JobProvider>(
                builder: (context, jobProvider, child) {
                  return JobPostingFormWidgets.buildLoadingButton(
                    onPressed: _postJob,
                    isLoading: jobProvider.isLoading,
                    text: widget.jobToEdit != null
                        ? 'อัปเดตโพสต์งาน'
                        : 'โพสต์งาน',
                  );
                },
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  void _onProvinceChanged(String newProvince) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedProvinceZones = newProvince;
        final newLocations = JobPostingUtils.getCurrentLocationZones(
          newProvince,
        );
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
        final newStations = JobPostingUtils.getCurrentTrainStations(
          newTrainLine,
        );
        if (newStations.isNotEmpty) {
          _selectedTrainStation = newStations.first;
        }
      });
    });
  }

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (authProvider.userModel == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('ข้อมูลผู้ใช้ไม่พร้อมใช้งาน')),
      );
      return;
    }

    final user = authProvider.userModel!;

    // Check verification status
    if (user.verificationStatus != 'verified') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ไม่สามารถโพสต์งานได้'),
          content: const Text(
            'บัญชีของคุณยังไม่ได้รับการยืนยันตัวตน กรุณายืนยันตัวตนก่อนโพสต์งาน',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
      return;
    }

    final job = JobPostingUtils.createJobFromFormData(
      jobId:
          widget.jobToEdit?.jobId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      clinicId: user.userId,
      clinicName: user.clinicName ?? user.userName,
      title: _titleController.text,
      description: _descriptionController.text,
      jobCategory: _selectedJobCategory,
      experienceLevel: _selectedExperienceLevel,
      salaryType: _selectedSalaryType,
      province: _selectedProvinceZones,
      city: _selectedLocationZones,
      trainLine: _selectedTrainLine,
      trainStation: _selectedTrainStation,
      minSalary: _minSalaryController.text,
      perks: _perksController.text,
      workingDays: _workingDaysController.text,
      workingHours: _workingHoursController.text,
      additionalRequirements: _additionalRequirementsController.text,
      selectedWorkingType: _selectedWorkingType,
      existingCreatedAt: widget.jobToEdit?.createdAt,
    );

    bool success;
    if (widget.jobToEdit != null) {
      success = await jobProvider.updateJob(job);
    } else {
      success = await jobProvider.postJob(job);
    }

    if (success) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.jobToEdit != null
                  ? 'อัปเดตงานสำเร็จแล้ว!'
                  : 'โพสต์งานสำเร็จแล้ว!',
            ),
          ),
        );
        navigator.pop();
      }
    } else {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(jobProvider.error ?? 'โพสต์งานไม่สำเร็จ')),
        );
      }
    }
  }
}
