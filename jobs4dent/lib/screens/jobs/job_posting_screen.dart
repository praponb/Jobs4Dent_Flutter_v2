import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_model.dart';

class JobPostingScreen extends StatefulWidget {
  final JobModel? jobToEdit;
  
  const JobPostingScreen({super.key, this.jobToEdit});

  @override
  State<JobPostingScreen> createState() => _JobPostingScreenState();
}

class _JobPostingScreenState extends State<JobPostingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  final _salaryDetailsController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _perksController = TextEditingController();
  final _addressController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _additionalRequirementsController = TextEditingController();
  final _cityController = TextEditingController();

  // Form values
  String? _selectedBranchId;
  String _selectedJobType = 'full-time';
  String _selectedJobCategory = JobProvider.jobCategories.first;
  String _selectedExperienceLevel = 'entry';
  String _selectedSalaryType = 'monthly';
  String _selectedProvince = 'กรุงเทพมหานคร';

  List<String> _selectedRequiredSkills = [];
  List<String> _selectedRequiredSpecialties = [];
  List<String> _selectedRequiredCertifications = [];
  List<String> _selectedRequiredLanguages = [];
  List<String> _selectedRequiredSoftware = [];
  List<String> _selectedWorkingDays = [];
  int? _minExperienceYears;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _deadline;
  bool _isUrgent = false;
  bool _isRemote = false;
  bool _travelRequired = false;

  // Thai provinces
  final List<String> _thaiProvinces = [
    'กรุงเทพมหานคร', 'กระบี่', 'กาญจนบุรี', 'กาฬสินธุ์', 'กำแพงเพชร',
    'ขอนแก่น', 'จันทบุรี', 'ฉะเชิงเทรา', 'ชลบุรี', 'ชัยนาท', 'ชัยภูมิ',
    'ชุมพร', 'เชียงราย', 'เชียงใหม่', 'ตรัง', 'ตราด', 'ตาก',
    'นครนายก', 'นครปฐม', 'นครพนม', 'นครราชสีมา', 'นครศรีธรรมราช',
    'นครสวรรค์', 'นนทบุรี', 'นราธิวาส', 'น่าน', 'บึงกาฬ', 'บุรีรัมย์',
    'ปทุมธานี', 'ประจวบคีรีขันธ์', 'ปราจีนบุรี', 'ปัตตานี', 'พระนครศรีอยุธยา',
    'พังงา', 'พัทลุง', 'พิจิตร', 'พิษณุโลก', 'เพชรบุรี', 'เพชรบูรณ์',
    'แพร่', 'ภูเก็ต', 'มหาสารคาม', 'มุกดาหาร', 'แม่ฮ่องสอน',
    'ยะลา', 'ยโสธร', 'ร้อยเอ็ด', 'ระนอง', 'ระยอง', 'ราชบุรี',
    'ลพบุรี', 'ลำปาง', 'ลำพูน', 'เลย', 'ศรีสะเกษ', 'สกลนคร',
    'สงขลา', 'สตูล', 'สมุทรปราการ', 'สมุทรสงคราม', 'สมุทรสาคร',
    'สระแก้ว', 'สระบุรี', 'สิงห์บุรี', 'สุโขทัย', 'สุพรรณบุรี',
    'สุราษฎร์ธานี', 'สุรินทร์', 'หนองคาย', 'หนองบัวลำภู', 'อ่างทอง',
    'อำนาจเจริญ', 'อุดรธานี', 'อุตรดิตถ์', 'อุทัยธานี', 'อุบลราชธานี'
  ];

  // Working days
  final List<String> _workingDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  // Dental skills
  final List<String> _dentalSkills = [
    'Oral Examination', 'Dental Cleaning', 'X-ray Operation', 'Dental Assisting',
    'Sterilization', 'Patient Communication', 'Dental Software', 'Insurance Processing',
    'Appointment Scheduling', 'Dental Photography', 'Impression Taking', 'Chart Management',
    'Emergency Care', 'Pain Management', 'Local Anesthesia', 'Dental Materials Knowledge'
  ];

  // Dental specialties
  final List<String> _dentalSpecialties = [
    'General Dentistry', 'Orthodontics', 'Oral Surgery', 'Endodontics',
    'Periodontics', 'Prosthodontics', 'Pediatric Dentistry', 'Oral Pathology',
    'Oral Radiology', 'Dental Hygiene', 'Dental Laboratory', 'Cosmetic Dentistry'
  ];

  // Common certifications
  final List<String> _certifications = [
    'Dental License', 'CPR Certification', 'Radiology License', 'Local Anesthesia Certification',
    'Infection Control Certification', 'OSHA Training', 'HIPAA Training'
  ];

  // Common languages
  final List<String> _languages = [
    'Thai', 'English', 'Chinese', 'Japanese', 'Korean', 'Arabic', 'French', 'German'
  ];

  // Common software
  final List<String> _dentalSoftware = [
    'Dentrix', 'Eaglesoft', 'Open Dental', 'Practice-Web', 'Curve Dental',
    'PracticeWorks', 'SoftDent', 'Dental Office Manager'
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.jobToEdit != null) {
      final job = widget.jobToEdit!;
      _titleController.text = job.title;
      _descriptionController.text = job.description;
      _selectedBranchId = job.branchId;
      _selectedJobType = job.jobType;
      _selectedJobCategory = job.jobCategory;
      _selectedExperienceLevel = job.experienceLevel;
      _selectedSalaryType = job.salaryType;
      _selectedProvince = job.province;
      _cityController.text = job.city;
      _addressController.text = job.address ?? '';
      _minSalaryController.text = job.minSalary?.toString() ?? '';
      _maxSalaryController.text = job.maxSalary?.toString() ?? '';
      _salaryDetailsController.text = job.salaryDetails ?? '';
      _benefitsController.text = job.benefits ?? '';
      _perksController.text = job.perks ?? '';
      _workingHoursController.text = job.workingHours ?? '';
      _additionalRequirementsController.text = job.additionalRequirements ?? '';
      _selectedRequiredSkills = List.from(job.requiredSkills);
      _selectedRequiredSpecialties = List.from(job.requiredSpecialties);
      _selectedRequiredCertifications = List.from(job.requiredCertifications ?? []);
      _selectedRequiredLanguages = List.from(job.requiredLanguages ?? []);
      _selectedRequiredSoftware = List.from(job.requiredSoftware ?? []);
      _selectedWorkingDays = List.from(job.workingDays ?? []);
      _minExperienceYears = job.minExperienceYears;
      _startDate = job.startDate;
      _endDate = job.endDate;
      _deadline = job.deadline;
      _isUrgent = job.isUrgent;
      _isRemote = job.isRemote;
      _travelRequired = job.travelRequired;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _salaryDetailsController.dispose();
    _benefitsController.dispose();
    _perksController.dispose();
    _addressController.dispose();
    _workingHoursController.dispose();
    _additionalRequirementsController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobToEdit != null ? 'Edit Job Posting' : 'Post New Job'),
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
                        widget.jobToEdit != null ? 'Update' : 'Post',
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
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),

              // Job Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., General Dentist, Dental Assistant',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Job title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Job Category and Type
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedJobCategory,
                      decoration: const InputDecoration(
                        labelText: 'Job Category *',
                        border: OutlineInputBorder(),
                      ),
                      items: JobProvider.jobCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJobCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedJobType,
                      decoration: const InputDecoration(
                        labelText: 'Job Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: JobProvider.jobTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJobType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Job Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Job Description *',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the role, responsibilities, and requirements...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Job description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Location Information Section
              _buildSectionHeader('Location Information'),
              const SizedBox(height: 16),

              // Province and City
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedProvince,
                      decoration: const InputDecoration(
                        labelText: 'Province *',
                        border: OutlineInputBorder(),
                      ),
                      items: _thaiProvinces.map((province) {
                        return DropdownMenuItem(
                          value: province,
                          child: Text(province),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProvince = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City/District *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Full Address',
                  border: OutlineInputBorder(),
                  hintText: 'Street address, building, floor, etc.',
                ),
              ),
              const SizedBox(height: 16),

              // Remote work and Travel required
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Remote Work Available'),
                      value: _isRemote,
                      onChanged: (value) {
                        setState(() {
                          _isRemote = value ?? false;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Travel Required'),
                      value: _travelRequired,
                      onChanged: (value) {
                        setState(() {
                          _travelRequired = value ?? false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Experience Requirements Section
              _buildSectionHeader('Experience Requirements'),
              const SizedBox(height: 16),

              // Experience Level and Minimum Years
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedExperienceLevel,
                      decoration: const InputDecoration(
                        labelText: 'Experience Level *',
                        border: OutlineInputBorder(),
                      ),
                      items: JobProvider.experienceLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExperienceLevel = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Min. Years of Experience',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 2',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _minExperienceYears = int.tryParse(value);
                      },
                      initialValue: _minExperienceYears?.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Required Skills
              _buildMultiSelectField(
                'Required Skills',
                _dentalSkills,
                _selectedRequiredSkills,
                (values) => setState(() => _selectedRequiredSkills = values),
              ),
              const SizedBox(height: 16),

              // Required Specialties
              _buildMultiSelectField(
                'Required Specialties',
                _dentalSpecialties,
                _selectedRequiredSpecialties,
                (values) => setState(() => _selectedRequiredSpecialties = values),
              ),
              const SizedBox(height: 16),

              // Required Certifications
              _buildMultiSelectField(
                'Required Certifications',
                _certifications,
                _selectedRequiredCertifications,
                (values) => setState(() => _selectedRequiredCertifications = values),
              ),
              const SizedBox(height: 16),

              // Required Languages
              _buildMultiSelectField(
                'Required Languages',
                _languages,
                _selectedRequiredLanguages,
                (values) => setState(() => _selectedRequiredLanguages = values),
              ),
              const SizedBox(height: 16),

              // Required Software
              _buildMultiSelectField(
                'Required Software',
                _dentalSoftware,
                _selectedRequiredSoftware,
                (values) => setState(() => _selectedRequiredSoftware = values),
              ),
              const SizedBox(height: 24),

              // Salary Information Section
              _buildSectionHeader('Salary Information'),
              const SizedBox(height: 16),

              // Salary Type
              DropdownButtonFormField<String>(
                value: _selectedSalaryType,
                decoration: const InputDecoration(
                  labelText: 'Salary Type *',
                  border: OutlineInputBorder(),
                ),
                items: JobProvider.salaryTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSalaryType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Salary Range
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minSalaryController,
                      decoration: const InputDecoration(
                        labelText: 'Min Salary (THB)',
                        border: OutlineInputBorder(),
                        hintText: '25000',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxSalaryController,
                      decoration: const InputDecoration(
                        labelText: 'Max Salary (THB)',
                        border: OutlineInputBorder(),
                        hintText: '40000',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Salary Details
              TextFormField(
                controller: _salaryDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Salary Details',
                  border: OutlineInputBorder(),
                  hintText: 'Additional compensation details...',
                ),
              ),
              const SizedBox(height: 16),

              // Benefits
              TextFormField(
                controller: _benefitsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Benefits',
                  border: OutlineInputBorder(),
                  hintText: 'Health insurance, dental coverage, etc...',
                ),
              ),
              const SizedBox(height: 16),

              // Perks
              TextFormField(
                controller: _perksController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Perks',
                  border: OutlineInputBorder(),
                  hintText: 'Flexible hours, team building, etc...',
                ),
              ),
              const SizedBox(height: 24),

              // Schedule Information Section
              _buildSectionHeader('Schedule Information'),
              const SizedBox(height: 16),

              // Working Days
              _buildMultiSelectField(
                'Working Days',
                _workingDays,
                _selectedWorkingDays,
                (values) => setState(() => _selectedWorkingDays = values),
              ),
              const SizedBox(height: 16),

              // Working Hours
              TextFormField(
                controller: _workingHoursController,
                decoration: const InputDecoration(
                  labelText: 'Working Hours',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 9:00 AM - 6:00 PM',
                ),
              ),
              const SizedBox(height: 16),

              // Date Range (for freelance/locum positions)
              if (_selectedJobType == 'freelance' || _selectedJobType == 'locum') ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _startDate != null 
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Select start date',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _endDate != null 
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Select end date',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Application Deadline
              InkWell(
                onTap: () => _selectDeadline(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Application Deadline',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _deadline != null 
                        ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                        : 'Select deadline (optional)',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Additional Information Section
              _buildSectionHeader('Additional Information'),
              const SizedBox(height: 16),

              // Additional Requirements
              TextFormField(
                controller: _additionalRequirementsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Requirements',
                  border: OutlineInputBorder(),
                  hintText: 'Any other specific requirements...',
                ),
              ),
              const SizedBox(height: 16),

              // Urgent Hiring
              CheckboxListTile(
                title: const Text('Urgent Hiring'),
                subtitle: const Text('Mark this job as urgent to increase visibility'),
                value: _isUrgent,
                onChanged: (value) {
                  setState(() {
                    _isUrgent = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Post/Update Button
              Consumer<JobProvider>(
                builder: (context, jobProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: jobProvider.isLoading ? null : _postJob,
                      child: jobProvider.isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              widget.jobToEdit != null ? 'Update Job Posting' : 'Post Job',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildMultiSelectField(
    String title,
    List<String> items,
    List<String> selectedValues,
    Function(List<String>) onConfirm,
  ) {
    return MultiSelectDialogField<String>(
      items: items.map((item) => MultiSelectItem(item, item)).toList(),
      title: Text(title),
      selectedColor: Theme.of(context).primaryColor,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      buttonIcon: const Icon(Icons.arrow_drop_down),
      buttonText: Text(
        selectedValues.isEmpty 
            ? 'Select $title' 
            : '${selectedValues.length} selected',
      ),
      onConfirm: onConfirm,
      initialValue: selectedValues,
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
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
        const SnackBar(content: Text('User information not available')),
      );
      return;
    }

    final user = authProvider.userModel!;
    final now = DateTime.now();

    final job = JobModel(
      jobId: widget.jobToEdit?.jobId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      clinicId: user.userId,
      clinicName: user.clinicName ?? user.userName,
      branchId: _selectedBranchId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      jobType: _selectedJobType,
      jobCategory: _selectedJobCategory,
      requiredSkills: _selectedRequiredSkills,
      requiredSpecialties: _selectedRequiredSpecialties,
      experienceLevel: _selectedExperienceLevel,
      minExperienceYears: _minExperienceYears,
      salaryType: _selectedSalaryType,
      minSalary: _minSalaryController.text.isNotEmpty ? double.tryParse(_minSalaryController.text) : null,
      maxSalary: _maxSalaryController.text.isNotEmpty ? double.tryParse(_maxSalaryController.text) : null,
      salaryDetails: _salaryDetailsController.text.trim().isNotEmpty ? _salaryDetailsController.text.trim() : null,
      benefits: _benefitsController.text.trim().isNotEmpty ? _benefitsController.text.trim() : null,
      perks: _perksController.text.trim().isNotEmpty ? _perksController.text.trim() : null,
      province: _selectedProvince,
      city: _cityController.text.trim(),
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      startDate: _startDate,
      endDate: _endDate,
      workingDays: _selectedWorkingDays.isEmpty ? null : _selectedWorkingDays,
      workingHours: _workingHoursController.text.trim().isNotEmpty ? _workingHoursController.text.trim() : null,
      isUrgent: _isUrgent,
      isRemote: _isRemote,
      requiredCertifications: _selectedRequiredCertifications.isEmpty ? null : _selectedRequiredCertifications,
      requiredLanguages: _selectedRequiredLanguages.isEmpty ? null : _selectedRequiredLanguages,
      additionalRequirements: _additionalRequirementsController.text.trim().isNotEmpty ? _additionalRequirementsController.text.trim() : null,
      travelRequired: _travelRequired,
      requiredSoftware: _selectedRequiredSoftware.isEmpty ? null : _selectedRequiredSoftware,
      createdAt: widget.jobToEdit?.createdAt ?? now,
      updatedAt: now,
      deadline: _deadline,
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
                  ? 'Job updated successfully!' 
                  : 'Job posted successfully!',
            ),
          ),
        );
        navigator.pop();
      }
    } else {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(jobProvider.error ?? 'Failed to post job')),
        );
      }
    }
  }
} 