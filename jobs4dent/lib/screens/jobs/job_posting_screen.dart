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
  final _perksController = TextEditingController();
  final _workingDaysController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _additionalRequirementsController = TextEditingController();

  String _selectedJobCategory = JobProvider.jobCategories.first;
  String _selectedExperienceLevel = 'ไม่มีประสบการณ์';
  String _selectedSalaryType = '50:50';
  String _selectedProvinceZones = 'กรุงเทพฯ ในเมือง';
  String _selectedLocationZones = 'พระราม 8 สามเสน ราชวัตร ศรีย่าน ดุสิต';

  List<String> _selectedWorkingType = [];

  final List<String> _workingType = [
    'ประจำ', 'Part-time'
  ];

  // Thai provinces
  final List<String> _thaiProvinceZones = [
    'กรุงเทพฯ ในเมือง',
    'กรุงเทพฯ ตอนเหนือ',
    'กรุงเทพฯ ฝั่งตะวันออก',
    'กรุงเทพฯ ธนบุรี',
    'กรุงเทพฯ นนทบุรี',
    'กรุงเทพฯ ปทุมธานี',
    'ต่างจังหวัด',
  ];

  final List<List<String>> _thaiLocationZones = [
    
    //กรุงเทพฯ ในเมือง
    ['พระราม 8 สามเสน ราชวัตร ศรีย่าน ดุสิต',
    'สยาม จุฬาลงกรณ์ สามย่าน สนามกีฬาแห่งชาติ หัวลำโพง ปทุมวัน',
    'สีลม ศาลาแดง บางรัก สี่พระยา สุรวงศ์',
    'วิทยุ ชิดลม หลังสวน เพลินจิต ร่วมฤดี สารสิน ราชดำริ ลุมพินี',
    'ราชเทวี พญาไท รางน้ำ ประตูน้ำ ราชปรารภ',
    'อารีย์ อนุสาวรีย์ ราชครู สนามเป้า',
    'สะพานควาย จตุจักร หมอชิต ประดิพัทธ์ อินทามะระ',
    'รัชดาภิเษก ห้วยขวาง สุทธิสาร ศูนย์วัฒนธรรม เหม่งจ๋าย',
    'พระราม 9 เพชรบุรีตัดใหม่ RCA ดินแดง ศูนย์วิจัย คลองตัน',
    'นานาฝั่งเหนือ นานาฝั่งใต้',
    'สุขุมวิท อโศก ทองหล่อ เอกมัย พร้อมพงษ์ ประสานมิตร',
    'อ่อนนุช อุดมสุข พระโขนง บางจาก ปุณณวิถี',
    'คลองเตย กล้วยน้ำไท ท่าเรือ พระราม 4',
    'สาทร นราธิวาส เย็นอากาศ ช่องนนทรี สุรศักดิ์ เซ้นต์หลุย เจริญราษฎร์ เจริญกรุง',
    'พระราม 3 สาธุประดิษฐ์ นางลิ้นจี่ ยานนาวา',
    'เยาวราช บางลำพู พระนคร ป้อมปราบ สัมพันธวงศ์',
    ],
    //กรุงเทพฯ ตอนเหนือ
    ['เกษตรศาสตร์ รัชโยธิน เสือใหญ่ เสนานิคม วังหิน รัชวิภา บางเขน',
    'เกษตร-นวมินทร์ (ประเสริฐมนูกิจ) สุคนธสวัสดิ์ นวลจันทร์ มัยลาภ ลาดปลาเค้า',
    'เลียบทางด่วนรามอินทรา (ประดิษฐ์มนูธรรม) โยธินพัฒนา CDC ศรีวรา',
    'รามอินทรา วัชรพล สายไหม หทัยราษฎร์ นวมินทร์ แฟชั่นไอส์แลนด์ สุขาภิบาล 5',
    'ลาดพร้าวตอนต้น ห้าแยกลาดพร้าว เซ็นทรัลลาดพร้าว โชคชัยร่วมมิตร',
    'ลาดพร้าวตอนกลาง โชคชัย 4 ลาดพร้าว 71 นาคนิวาส',
    'ลาดพร้าวตอนปลาย มหาดไทย ลาดพร้าว 101 แฮปปี้แลนด์ เดอะมอลล์บางกะปิ',
    'ดอนเมือง สะพานใหม่ วิภาวดี สรงประภา หลักสี่',
    ],
    //กรุงเทพฯ ฝั่งตะวันออก
    [
    'ศรีนครินทร์ พัฒนาการ กรุงเทพกรีฑา สวนหลวง',
    'บางนา สรรพวุธ ลาซาล แบริ่ง สันติคาม ม.รามคำแหง 2 เมกะบางนา เอแบคบางนา',
    'รามคำแหงตอนต้น ม.รามคำแหง หัวหมาก เอแบครามคำแหง ทาวน์อินทาวน์ บดินทรเดชา',
    'รามคำแหงตอนกลาง นิด้า เสรีไทย สุขาภิบาล 2',
    'ร่มเกล้า หนองจอก มีนบุรี รามคำแหงตอนปลาย ซอยมิสทีน สุวินทวงศ์',
    'เทพารักษ์ บางพลี สำโรง แพรกษา ปู่เจ้าสมิงพราย ศรีด่าน ปากน้ำ บางปู สมุทรปราการ',
    'ลาดกระบัง สุวรรณภูมิ มอเตอร์เวย์ เฉลิมพระเกียรติ ประเวศ',
    ],
    //กรุงเทพฯ ธนบุรี
    ['วงเวียนใหญ่ เจริญนคร กรุงธนบุรี ตากสิน อิสรภาพ',
    'กัลปพฤกษ์ ท่าพระ ตลาดพลู โพธิ์นิมิตร วุฒากาศ บางหว้า เทอดไท',
    'ตลิ่งชัน ปิ่นเกล้า จรัญสนิทวงศ์ บางอ้อ บางพลัด บรมราชชนนี อรุณอัมรินทร์ ราชพฤกษ์',
    'บางบอน ดาวคะนอง จอมทอง เอกชัย กัลปพฤกษ์',
    'ราษฎร์บูรณะ สุขสวัสดิ์ ประชาอุทิศ พระประแดง พุทธบูชา ทุ่งครุ',
    'พระราม 2 บางขุนเทียน ท่าข้าม เทียนทะเล',
    'บางแค เพชรเกษม ภาษีเจริญ หนองแขม',
    ],
    //กรุงเทพฯ นนทบุรี
    ['บางซื่อ วงศ์สว่าง เตาปูน ประชาชื่น บางโพ บางซ่อน ประชาราษฎร์ กรุงเทพนนท์',
    'รัตนาธิเบศร์ สนามบินน้ำ พระนั่งเกล้า สามัคคี เรวดี',
    'ราชพฤกษ์ ถนน 345 บางกรวย ติวานนท์ นครอินทร์ พระราม 5 พิบูลสงคราม ชัยพฤกษ์',
    'แจ้งวัฒนะ เมืองทอง งามวงศ์วาน เลียบคลองประปา แคราย ปากเกร็ด',
    'นนทบุรี บางใหญ่ บางบัวทอง ไทรน้อย ไทรม้า ท่าอิฐ',
    ],
    //กรงเทพฯ ปทุมธานี
    ['รังสิต ลำลูกกา ปทุมธานี คลองหลวง'],
    //ต่างจังหวัด
    ['นครปฐม',
    'อยุธยา',
    'กำแพงเพชร',
    'ชัยนาท',
    'นครนายก',
    'นครสวรรค์',
    'พิจิตร',
    'พิษณุโลก',
    'เพชรบูรณ์',
    'ลพบุรี',
    'สมุทรสงคราม',
    'สมุทรสาคร',
    'สิงห์บุรี',
    'สุโขทัย',
    'สุพรรณบุรี',
    'สระบุรี',
    'อ่างทอง',
    'อุทัยธานี',
    'เชียงใหม่',
    'เชียงราย',
    'น่าน',
    'พะเยา',
    'แพร่',
    'แม่ฮ่องสอน',
    'ลำปาง',
    'ลำพูน',
    'อุตรดิตถ์',
    'ประจวบคีรีขันธ์',
    'กาญจนบุรี',
    'ตาก',
    'เพชรบุรี',
    'ราชบุรี',
    'ชลบุรี',
    'จันทบุรี',
    'ฉะเชิงเทรา',
    'ตราด',
    'ปราจีนบุรี',
    'ระยอง',
    'สระแก้ว',
    'ชลบุรี',
    'นครราชสีมา',
    'ขอนแก่น',
    'กาฬสินธุ์',
    'ชัยภูมิ',
    'นครพนม',
    'บึงกาฬ',
    'บุรีรัมย์',
    'มหาสารคาม',
    'มุกดาหาร',
    'ยโสธร',
    'ร้อยเอ็ด',
    'เลย',
    'ศรีสะเกษ',
    'สกลนคร',
    'สุรินทร์',
    'หนองคาย',
    'หนองบัวลำภู',
    'อำนาจเจริญ',
    'อุดรธานี',
    'อุบลราชธานี',
    'ภูเก็ต',
    'กระบี่',
    'ชุมพร',
    'ตรัง',
    'นครศรีธรรมราช',
    'นราธิวาส',
    'ปัตตานี',
    'พังงา',
    'พัทลุง',
    'ยะลา',
    'ระนอง',
    'สงขลา',
    'สตูล',
    'สุราษฎร์ธานี',
    ],
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  List<String> _getCurrentLocationZones() {
    int provinceIndex = _thaiProvinceZones.indexOf(_selectedProvinceZones);
    if (provinceIndex >= 0 && provinceIndex < _thaiLocationZones.length) {
      final locationZones = _thaiLocationZones[provinceIndex];
      if (locationZones.isNotEmpty) {
        return locationZones;
      }
    }
    // Default to first zone if not found or empty
    return _thaiLocationZones.isNotEmpty && _thaiLocationZones.first.isNotEmpty 
        ? _thaiLocationZones.first 
        : ['กรุงเทพฯ']; // Ultimate fallback
  }

  String _getValidLocationZone() {
    final availableLocations = _getCurrentLocationZones();
    if (availableLocations.contains(_selectedLocationZones)) {
      return _selectedLocationZones;
    }
    // If current selection is not valid, update it and return first option
    if (availableLocations.isNotEmpty) {
      _selectedLocationZones = availableLocations.first;
      return _selectedLocationZones;
    }
    // Ultimate fallback
    return 'กรุงเทพฯ';
  }

  void _initializeForm() {
    if (widget.jobToEdit != null) {
      final job = widget.jobToEdit!;
      _titleController.text = job.title;
      _descriptionController.text = job.description;
      _selectedJobCategory = job.jobCategory;
      _selectedExperienceLevel = job.experienceLevel;
      _selectedSalaryType = job.salaryType;
      _selectedProvinceZones = job.province;
      
      final availableLocations = _getCurrentLocationZones();
      if (availableLocations.contains(job.city)) {
        _selectedLocationZones = job.city;
      } else {
        _selectedLocationZones = availableLocations.first;
      }
      
      _minSalaryController.text = job.minSalary?.toString() ?? '';
      _perksController.text = job.perks ?? '';
      _workingDaysController.text = job.workingDays?.join(', ') ?? '';
      _workingHoursController.text = job.workingHours ?? '';
      _additionalRequirementsController.text = job.additionalRequirements ?? '';

      _selectedWorkingType = List.from(job.workingDays ?? []);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobToEdit != null ? 'แก้ไขประกาศงาน' : 'ประกาศงานใหม่'),
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
              _buildSectionHeader('ข้อมูลพื้นฐาน'),
              const SizedBox(height: 16),

              // Job Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'หัวข้อ *',
                  border: OutlineInputBorder(),
                  hintText: 'เช่น รับสมัครทันตแพทย์ประจำ(สามารถเลือกวันลงตรวจได้)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ต้องระบุหัวข้อ';
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
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'หมวดหมู่งาน *',
                        border: OutlineInputBorder(),
                      ),
                      items: JobProvider.jobCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJobCategory = value!;
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
                  labelText: 'รายละเอียดงาน *',
                  border: OutlineInputBorder(),
                  hintText: 'อธิบายลักษณะงาน และข้อมูลการติดต่อ...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ต้องระบุรายละเอียดงาน';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Location Information Section
              _buildSectionHeader('ข้อมูลสถานที่'),
              const SizedBox(height: 16),

              // Province and City
              DropdownButtonFormField<String>(
                value: _selectedProvinceZones,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'โซนที่ตั้ง *',
                  border: OutlineInputBorder(),
                ),
                items: _thaiProvinceZones.map((province) {
                  return DropdownMenuItem(
                    value: province,
                    child: Text(
                      province,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    // Defer the setState call to avoid "setState called during build" error
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedProvinceZones = value;
                        // Reset location when province changes
                        final newLocations = _getCurrentLocationZones();
                        if (newLocations.isNotEmpty) {
                          _selectedLocationZones = newLocations.first;
                        }
                      });
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _getValidLocationZone(),
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'จังหวัด/โซนในจังหวัด *',
                  border: OutlineInputBorder(),
                ),
                items: _getCurrentLocationZones().map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(
                      location,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLocationZones = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              _buildSectionHeader('ข้อกำหนดประสบการณ์'),
              const SizedBox(height: 16),

              // Experience Level and Minimum Years
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedExperienceLevel,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'ประสบการณ์(กี่ปี) *',
                        border: OutlineInputBorder(),
                      ),
                      items: JobProvider.experienceLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(
                            level,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExperienceLevel = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildSectionHeader('ข้อมูลรายได้'),
              const SizedBox(height: 16),

              // Salary Type
              DropdownButtonFormField<String>(
                value: _selectedSalaryType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Doctor Fee *',
                  border: OutlineInputBorder(),
                ),
                items: JobProvider.salaryTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
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
                        labelText: 'ประกันรายได้ขั้นต่ำ (บาท/วัน)',
                        border: OutlineInputBorder(),
                        hintText: '2500',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Other Benefits
              TextFormField(
                controller: _perksController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'อื่นๆ',
                  border: OutlineInputBorder(),
                  hintText: 'สิทธิพิเศษ, เวลางานยืดหยุ่น ฯลฯ',
                ),
              ),
              const SizedBox(height: 24),

              // Schedule Information Section
              _buildSectionHeader('ข้อมูลตารางงาน'),
              const SizedBox(height: 16),

              // Working Days
              _buildMultiSelectField(
                'ประจำ หรือ part-time',
                _workingType,
                _selectedWorkingType,
                (values) => setState(() => _selectedWorkingType = values),
              ),
              const SizedBox(height: 16),

              // Working Days
              TextFormField(
                controller: _workingDaysController,
                decoration: const InputDecoration(
                  labelText: 'วัน ทำงาน',
                  border: OutlineInputBorder(),
                  hintText: 'เช่น จันทร์-ศุกร์',
                ),
              ),
              const SizedBox(height: 16),

              // Working Hours
              TextFormField(
                controller: _workingHoursController,
                decoration: const InputDecoration(
                  labelText: 'เวลา ทำงาน',
                  border: OutlineInputBorder(),
                  hintText: 'เช่น 09:00น.-18:00น.',
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionHeader('ข้อมูลเพิ่มเติม'),
              const SizedBox(height: 16),

              // Additional Requirements
              TextFormField(
                controller: _additionalRequirementsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ข้อกำหนดเพิ่มเติม',
                  border: OutlineInputBorder(),
                  hintText: 'ข้อกำหนดเฉพาะอื่นๆ...',
                ),
              ),
              const SizedBox(height: 16),

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
                              widget.jobToEdit != null ? 'อัปเดตโพสต์งาน' : 'โพสต์งาน',
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
            ? 'เลือก$title' 
            : 'เลือก ${selectedValues.length} รายการ',
      ),
      onConfirm: onConfirm,
      initialValue: selectedValues,
    );
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
    final now = DateTime.now();

        final job = JobModel(
      jobId: widget.jobToEdit?.jobId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      clinicId: user.userId,
      clinicName: user.clinicName ?? user.userName,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      jobCategory: _selectedJobCategory,
      experienceLevel: _selectedExperienceLevel,
      salaryType: _selectedSalaryType,
      minSalary: _minSalaryController.text.isNotEmpty ? double.tryParse(_minSalaryController.text) : null,
      perks: _perksController.text.trim().isNotEmpty ? _perksController.text.trim() : null,
      province: _selectedProvinceZones,
      city: _selectedLocationZones,
      workingDays: _workingDaysController.text.trim().isNotEmpty 
          ? _workingDaysController.text.trim().split(',').map((day) => day.trim()).where((day) => day.isNotEmpty).toList()
          : (_selectedWorkingType.isEmpty ? null : _selectedWorkingType),
      workingHours: _workingHoursController.text.trim().isNotEmpty ? _workingHoursController.text.trim() : null,
      additionalRequirements: _additionalRequirementsController.text.trim().isNotEmpty ? _additionalRequirementsController.text.trim() : null,
      createdAt: widget.jobToEdit?.createdAt ?? now,
      updatedAt: now,
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