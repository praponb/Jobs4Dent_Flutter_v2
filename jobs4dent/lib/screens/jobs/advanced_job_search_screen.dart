import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/job_constants.dart';
import '../../providers/auth_provider.dart';
import 'job_search_screen.dart';

class AdvancedJobSearchScreen extends StatefulWidget {
  const AdvancedJobSearchScreen({super.key});

  @override
  State<AdvancedJobSearchScreen> createState() => _AdvancedJobSearchScreenState();
}

class _AdvancedJobSearchScreenState extends State<AdvancedJobSearchScreen> {
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _trainLineController = TextEditingController();
  final TextEditingController _trainStationController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController();
  final TextEditingController _additionalRequirementsController = TextEditingController();
  
  String? _selectedJobCategory;
  String? _selectedExperienceLevel;
  String? _selectedSalaryType;
  String? _selectedWorkingType;
  bool _isUrgent = false;
  bool _isRemote = false;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _selectedWorkingDays = [];
  
  // Hierarchical location selection
  int? _selectedProvinceZoneIndex;
  String? _selectedLocation;
  
  // Hierarchical train selection
  int? _selectedTrainLineIndex;
  String? _selectedTrainStation;

  final List<String> _workingDayOptions = [
    'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์'
  ];

  final List<String> _workingType = [
    'ประจำ', 'Part-time'
  ];

  //------------------------------------------------------------------------------------------------
  // Thai provinces
  final List<String> _thaiProvinceZones = [
    'กรุงเทพฯ ในเมือง',
    'กรุงเทพฯ ตอนเหนือ',
    'กรุงเทพฯ ฝั่งตะวันออก',
    'กรุงเทพฯ ธนบุรี',
    'กรุงเทพฯ นนทบุรี',
    'กรุงเทพฯ ปทุมธานี',
    'ภาคกลาง',
    'ภาคเหนือ',
    'ภาคตะวันตก',
    'ภาคตะวันออก',
    'ภาคตะวันออกเฉียงเหนือ',
    'ภาคใต้',
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
    'บางบอน ดาวคะนอง จอมทอง เอกชัย กัลปพฤกษ์',
    'พระราม 2 บางขุนเทียน ท่าข้าม เทียนทะเล',
    'ตลิ่งชัน ปิ่นเกล้า จรัญสนิทวงศ์ บางอ้อ บางพลัด บรมราชชนนี อรุณอัมรินทร์ ราชพฤกษ์',
    'กัลปพฤกษ์ ท่าพระ ตลาดพลู โพธิ์นิมิตร วุฒากาศ บางหว้า เทอดไท',
    'ราษฎร์บูรณะ สุขสวัสดิ์ ประชาอุทิศ พระประแดง พุทธบูชา ทุ่งครุ',
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
    // ภาคกลาง
    ['นครปฐม',
    'อยุธยา',
    'กำแพงเพชร',
    'ชัยนาท',
    'นครนายก',
    'นครปฐม',
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
    ],
    // ภาคเหนือ
    ['เชียงใหม่',
    'เชียงราย',
    'น่าน',
    'พะเยา',
    'แพร่',
    'แม่ฮ่องสอน',
    'ลำปาง',
    'ลำพูน',
    'อุตรดิตถ์',
    ],
    // ภาคตะวันตก
    ['ประจวบคีรีขันธ์',
    'กาญจนบุรี',
    'ตาก',
    'เพชรบุรี',
    'ราชบุรี',
    ],
    // ภาคตะวันออก
    ['ชลบุรี',
    'จันทบุรี',
    'ฉะเชิงเทรา',
    'ตราด',
    'ปราจีนบุรี',
    'ระยอง',
    'สระแก้ว',
    ],
    // ภาคตะวันออกเฉียงเหนือ
    ['นครราชสีมา',
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
    ],
    // ภาคใต้
    ['ภูเก็ต',
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

  // Thai train lines
  final List<String> _thaiTrainLines = [
    'BTS สายสุขุมวิท',
    'BTS สายสีลม',
    'BTS สายสีทอง',
    'Airport Rail Link',
    'MRT สายสีน้ำเงิน',
    'MRT สายสีม่วง',
    'MRT สายสีชมพู',
    'MRT สายสีเหลือง',
    'BRT',
    'SRT สายสีแดง',
    'ไม่ใกล้รถไฟฟ้า'
  ];

  final List<List<String>> _thaiTrainStations = [
    // BTS สายสุขุมวิท
    ['หมอชิต',
    'สะพานควาย',
    'อารีย์',
    'สนามเป้า',
    'อนุสาวรีย์ชัยสมรภูมิ',
    'พญาไท',
    'ราชเทวี',
    'สยาม',
    'ชิดลม',
    'เพลินจิต',
    'นานา',
    'อโศก',
    'พร้อมพงษ์',
    'ทองหล่อ',
    'เอกมัย',
    'พระโขนง',
    'อ่อนนุช',
    'บางจาก',
    'ปุณณวิถี',
    'อุดมสุข',
    'บางนา',
    'แบริ่ง',
    'สำโรง',
    'ปู่เจ้าสมิงพราย',
    'ช้างเอราวัณ',
    'โรงเรียนนายเรือ',
    'ปากน้ำ',
    'ศรีนครินทร์',
    'แพรกษา',
    'สายลวด',
    'เคหะสมุทรปราการ',
    'ห้าแยกลาดพร้าว',
    'พหลโยธิน 24',
    'รัชโยธิน',
    'เสนานิคม',
    'ม.เกษตรศาสตร์',
    'กรมป่าไม้',
    'ศรีปทุม (บางบัว)',
    'กรมทหารราบที่ 11',
    'วัดพระศรีมหาธาตุ',
    'พหลโยธิน 59',
    'สายหยุด',
    'สะพานใหม่',
    'คูคต',
    ],
    // BTS สายสีลม
    ['สนามกีฬาแห่งชาติ',
    'ราชดำริ',
    'ศาลาแดง',
    'ช่องนนทรี',
    'สุรศักดิ์',
    'สะพานตากสิน',
    'กรุงธนบุรี',
    'วงเวียนใหญ่',
    'โพธิ์นิมิตร',
    'ตลาดพลู',
    'วุฒากาศ',
    'บางหว้า',
    ],
    // BTS สายสีทอง
    ['กรุงธนบุรี',
    'เจริญนคร',
    'คลองสาน',
    ],
    // Airport Rail Link
    ['พญาไท',
    'ราชปรารภ',
    'มักกะสัน',
    'รามคำแหง',
    'หัวหมาก',
    'บ้านทับช้าง',
    'ลาดกระบัง',
    'สุวรรณภูมิ',
    ],
    // MRT สายสีน้ำเงิน
    ['หัวลำโพง',
    'สามย่าน',
    'สีลม',
    'ลุมพินี',
    'คลองเตย',
    'ศูนย์การประชุมแห่งชาติสิริกิติ์',
    'สุขุมวิท',
    'เพชรบุรี',
    'พระราม 9',
    'ศูนย์วัฒนธรรมแห่งประเทศไทย',
    'ห้วยขวาง',
    'สุทธิสาร',
    'รัชดาภิเษก',
    'ลาดพร้าว',
    'พหลโยธิน',
    'จตุจักร',
    'กำแพงเพชร',
    'บางซื่อ',
    'เตาปูน',
    'บางโพ',
    'บางอ้อ',
    'บางพลัด',
    'สิรินธร',
    'บางยี่ขัน',
    'บางขุนนนท์',
    'แยกไฟฉาย',
    'จรัญสนิทวงศ์ 13',
    'ท่าพระ',
    'บางไผ่',
    'บางหว้า',
    'เพชรเกษม 48',
    'ภาษีเจริญ',
    'บางแค',
    'หลักสอง',
    'วัดมังกร',
    'สามยอด',
    'สนามไชย',
    'อิสรภาพ',
    ],
    // MRT สายสีม่วง
    ['คลองบางไผ่',
    'ตลาดบางใหญ่',
    'สามแยกบางใหญ่',
    'บางพลู',
    'บางรักใหญ่',
    'บางรักน้อยท่าอิฐ',
    'ไทรม้า',
    'สะพานพระนั่งเกล้า',
    'แยกนนทบุรี 1',
    'บางกระสอ',
    'ศูนย์ราชการนนทบุรี',
    'กระทรวงสาธารณสุข',
    'แยกติวานนท์',
    'วงศ์สว่าง',
    'บางซ่อน',
    'เตาปูน',
    ],
    // MRT สายสีชมพู
    ['ศูนย์ราชการนนทบุรี',
    'แคราย',
    'สนามบินน้ำ',
    'สามัคคี',
    'กรมชลประทาน',
    'แยกปากเกร็ด',
    'เลี่ยงเมืองปากเกร็ด',
    'แจ้งวัฒนะ-ปากเกร็ด 28',
    'ศรีรัช',
    'เมืองทองธานี',
    'แจ้งวัฒนะ 14',
    'ศูนย์ราชการเฉลิมพระเกียรติ',
    'โทรคมนาคมแห่งชาติ',
    'หลักสี่',
    'ราชภัฏพระนคร',
    'วัดพระศรีมหาธาตุ',
    'รามอินทรา 3',
    'ลาดปลาเค้า',
    'รามอินทรา กม.4',
    'มัยลาภ',
    'วัชรพล',
    'รามอินทรา กม.6',
    'คู้บอน',
    'รามอินทรา กม.9',
    'วงแหวนรามอินทรา',
    'นพรัตน์',
    'บางชัน',
    'เศรษฐบุตรบำเพ็ญ',
    'ตลาดมีนบุรี',
    'มีนบุรี',
    'อิมแพ็ค เมืองทองธานี',
    'ทะเลสาปเมืองทอง',
    ],
    // MRT สายสีเหลือง
    ['ลาดพร้าว',
    'ภาวนา',
    'โชคชัย 4',
    'ลาดพร้าว 71',
    'ลาดพร้าว 83',
    'มหาดไทย',
    'ลาดพร้าว 101',
    'บางกะปิ',
    'แยกลำสาลี',
    'ศรีกรีฑา',
    'หัวหมาก',
    'กลันตัน',
    'ศรีนุช',
    'ศรีนครินทร์ 38',
    'สวนหลวง ร.9',
    'ศรีอุดม',
    'ศรีเอี่ยม',
    'ศรีลาซาล',
    'ศรีแบริ่ง',
    'ศรีด่าน',
    'ศรีเทพา',
    'ทิพวัล',
    'สำโรง',
    ],
    // BRT
    ['สาทร',
    'อาคารสงเคราะห์',
    'เทคนิคกรุงเทพ',
    'ถนนจันทน์',
    'นราราม 3',
    'วัดด่าน',
    'วัดปริวาส',
    'วัดดอกไม้',
    'สะพานพระราม 9',
    'เจริญราษฎร์',
    'สะพานพระราม 3',
    'ราชพฤกษ์',
    ],
    // SRT สายสีแดง
    ['สถานีกลางบางซื่อ',
    'จตุจักร',
    'วัดเสมียนนารี',
    'บางเขน',
    'ทุ่งสองห้อง',
    'หลักสี่',
    'การเคหะ',
    'ดอนเมือง',
    'หลักหก',
    'รังสิต',
    'บางซ่อน',
    'บางบำหรุ',
    'ตลิ่งชัน',
    ],
    //ไม่ใกล้รถไฟฟ้า
    ['ไม่ใกล้รถไฟฟ้า'],
  ];








  @override
  void initState() {
    super.initState();
    _loadSavedSearchState();
  }

  void _loadSavedSearchState() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final savedState = jobProvider.savedAdvancedSearchState;
    
    if (savedState != null) {
      // Restore text controllers
      _keywordController.text = savedState['keyword'] ?? '';
      _minSalaryController.text = savedState['minSalary'] ?? '';
      _maxSalaryController.text = savedState['maxSalary'] ?? '';
      _workingHoursController.text = savedState['workingHours'] ?? '';
      _additionalRequirementsController.text = savedState['additionalRequirements'] ?? '';
      
      // Restore dropdown selections
      _selectedJobCategory = savedState['selectedJobCategory'];
      _selectedExperienceLevel = savedState['selectedExperienceLevel'];
      _selectedSalaryType = savedState['selectedSalaryType'];
      _selectedWorkingType = savedState['selectedWorkingType'];
      
      // Restore location selections
      _selectedProvinceZoneIndex = savedState['selectedProvinceZoneIndex'];
      _selectedLocation = savedState['selectedLocation'];
      
      // Restore train selections
      _selectedTrainLineIndex = savedState['selectedTrainLineIndex'];
      _selectedTrainStation = savedState['selectedTrainStation'];
      
      // Restore working days
      final workingDays = savedState['selectedWorkingDays'];
      if (workingDays != null && workingDays is List) {
        _selectedWorkingDays.clear();
        _selectedWorkingDays.addAll(List<String>.from(workingDays));
      }
      
      // Restore dates
      if (savedState['startDate'] != null) {
        _startDate = DateTime.parse(savedState['startDate']);
      }
      if (savedState['endDate'] != null) {
        _endDate = DateTime.parse(savedState['endDate']);
      }
      
      // Update province and city controllers based on selections
      if (_selectedProvinceZoneIndex != null) {
        _provinceController.text = _thaiProvinceZones[_selectedProvinceZoneIndex!];
      }
      if (_selectedLocation != null) {
        _cityController.text = _selectedLocation!;
      }
      if (_selectedTrainLineIndex != null) {
        _trainLineController.text = _thaiTrainLines[_selectedTrainLineIndex!];
      }
      if (_selectedTrainStation != null) {
        _trainStationController.text = _selectedTrainStation!;
      }
    }
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _trainLineController.dispose();
    _trainStationController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _workingHoursController.dispose();
    _additionalRequirementsController.dispose();
    super.dispose();
  }

  void _searchJobs() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Save current search form state before performing search
    jobProvider.saveAdvancedSearchState(
      keyword: _keywordController.text,
      selectedProvinceZoneIndex: _selectedProvinceZoneIndex,
      selectedLocation: _selectedLocation,
      selectedJobCategory: _selectedJobCategory,
      selectedExperienceLevel: _selectedExperienceLevel,
      selectedSalaryType: _selectedSalaryType,
      minSalary: _minSalaryController.text,
      maxSalary: _maxSalaryController.text,
      selectedTrainLineIndex: _selectedTrainLineIndex,
      selectedTrainStation: _selectedTrainStation,
      selectedWorkingType: _selectedWorkingType,
      selectedWorkingDays: _selectedWorkingDays,
      workingHours: _workingHoursController.text,
      startDate: _startDate,
      endDate: _endDate,
      additionalRequirements: _additionalRequirementsController.text,
    );
    
    // Use AI-powered search with Gemini 1.5 Flash
    jobProvider.searchJobsWithAI(
      keyword: _keywordController.text.trim().isEmpty ? null : _keywordController.text.trim(),
      province: _selectedProvinceZoneIndex != null ? _thaiProvinceZones[_selectedProvinceZoneIndex!] : null,
      city: _selectedLocation,
      jobCategory: _selectedJobCategory,
      experienceLevel: _selectedExperienceLevel,
      salaryType: _selectedSalaryType,
      minSalary: _minSalaryController.text.trim().isEmpty ? null : double.tryParse(_minSalaryController.text.trim()),
      maxSalary: _maxSalaryController.text.trim().isEmpty ? null : double.tryParse(_maxSalaryController.text.trim()),
      startDate: _startDate,
      endDate: _endDate,
      isUrgent: _isUrgent ? true : null,
      isRemote: _isRemote ? true : null,
      trainLine: _selectedTrainLineIndex != null ? _thaiTrainLines[_selectedTrainLineIndex!] : null,
      trainStation: _selectedTrainStation,
      workingDays: _selectedWorkingDays.isEmpty ? null : _selectedWorkingDays,
      workingHours: _workingHoursController.text.trim().isEmpty ? null : _workingHoursController.text.trim(),
      additionalRequirements: _additionalRequirementsController.text.trim().isEmpty ? null : _additionalRequirementsController.text.trim(),
      workingType: _selectedWorkingType,
      userId: authProvider.userModel?.userId,
    );

    // Navigate to job search screen with results
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const JobSearchScreen(),
      ),
    );
  }

  void _clearFilters() {
    // Clear the saved search state when explicitly clearing filters
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.clearAdvancedSearchState();
    
    setState(() {
      _keywordController.clear();
      _provinceController.clear();
      _cityController.clear();
      _trainLineController.clear();
      _trainStationController.clear();
      _minSalaryController.clear();
      _maxSalaryController.clear();
      _workingHoursController.clear();
      _additionalRequirementsController.clear();
      _selectedJobCategory = null;
      _selectedExperienceLevel = null;
      _selectedSalaryType = null;
      _selectedWorkingType = null;
      _isUrgent = false;
      _isRemote = false;
      _startDate = null;
      _endDate = null;
      _selectedWorkingDays.clear();
      _selectedProvinceZoneIndex = null;
      _selectedLocation = null;
      _selectedTrainLineIndex = null;
      _selectedTrainStation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาขั้นสูง'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('ล้างทั้งหมด', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Search Section
            _buildSectionTitle('ค้นหาทั่วไป'),
            const SizedBox(height: 8),
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: 'ชื่อคลินิก หรือ อื่นๆ',
                hintText: 'ค้นหาชื่อคลินิก หรือคำอธิบายงาน...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Location Section
            _buildSectionTitle('ที่ตั้งและการเดินทาง'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedProvinceZoneIndex,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'พื้นที่',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('เลือกพื้นที่'),
                ),
                for (int i = 0; i < _thaiProvinceZones.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(_thaiProvinceZones[i]),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedProvinceZoneIndex = value;
                  _selectedLocation = null; // Reset location when province changes
                  _provinceController.text = value != null ? _thaiProvinceZones[value] : '';
                });
              },
            ),
            // if (_selectedProvinceZoneIndex != null) ...[
            //   const SizedBox(height: 16),
            //   DropdownButtonFormField<String>(
            //     value: _selectedLocation,
            //     isExpanded: true,
            //     decoration: const InputDecoration(
            //       labelText: 'ตำแหน่งที่ตั้ง',
            //       border: OutlineInputBorder(),
            //     ),
            //     items: [
            //       const DropdownMenuItem(
            //         value: null,
            //         child: Text('เลือกตำแหน่งที่ตั้ง'),
            //       ),
            //       ..._thaiLocationZones[_selectedProvinceZoneIndex!].map((location) {
            //         return DropdownMenuItem(
            //           value: location,
            //           child: Text(location),
            //         );
            //       }),
            //     ],
            //     onChanged: (value) {
            //       setState(() {
            //         _selectedLocation = value;
            //         _cityController.text = value ?? '';
            //       });
            //     },
            //   ),
            // ],
            const SizedBox(height: 16),
            if (_selectedProvinceZoneIndex != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'จังหวัด/โซนในจังหวัด',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('เลือกโซนทำงาน'),
                  ),
                  ..._thaiLocationZones[_selectedProvinceZoneIndex!].map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text(location),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                    _cityController.text = value ?? '';
                  });
                },
              ),
            ],
            const SizedBox(height: 24),
            // TextField(
            //   controller: _cityController,
            //   decoration: const InputDecoration(
            //     labelText: 'เขต/อำเภอ',
            //     hintText: 'เช่น วัฒนา, บางกะปิ',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedTrainLineIndex,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'สายรถไฟฟ้า',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('เลือกสายรถไฟฟ้า'),
                ),
                for (int i = 0; i < _thaiTrainLines.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(_thaiTrainLines[i]),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTrainLineIndex = value;
                  _selectedTrainStation = null; // Reset station when line changes
                  _trainLineController.text = value != null ? _thaiTrainLines[value] : '';
                });
              },
            ),
            if (_selectedTrainLineIndex != null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTrainStation,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'สถานีรถไฟฟ้า',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('เลือกสถานี'),
                  ),
                  ..._thaiTrainStations[_selectedTrainLineIndex!].map((station) {
                    return DropdownMenuItem(
                      value: station,
                      child: Text(station),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTrainStation = value;
                    _trainStationController.text = value ?? '';
                  });
                },
              ),
            ],
            const SizedBox(height: 24),

            // Job Category and Experience
            _buildSectionTitle('เลือกความถนัดเฉพาะทาง หรือ ระดับประสบการณ์'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedJobCategory,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'หมวดหมู่งาน',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('เลือกหมวดหมู่งาน'),
                ),
                ...JobConstants.jobCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedJobCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedExperienceLevel,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'ระดับประสบการณ์',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('เลือกระดับประสบการณ์'),
                ),
                ...JobConstants.experienceLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedExperienceLevel = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Salary Section
            _buildSectionTitle('ประกันรายได้รายวัน หรือ เงินเดือน'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSalaryType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'ประเภทเงินเดือน',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('อัตราส่วนรายได้'),
                ),
                ...JobConstants.salaryTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSalaryType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minSalaryController,
                    decoration: const InputDecoration(
                      labelText: 'ประกันรายได้ขั้นต่ำ',
                      hintText: '2500',
                      border: OutlineInputBorder(),
                      suffixText: 'บาท',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxSalaryController,
                    decoration: const InputDecoration(
                      labelText: 'เงินเดือนขั้นต่ำ',
                      hintText: '25000',
                      border: OutlineInputBorder(),
                      suffixText: 'บาท',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Work Schedule Section
            _buildSectionTitle('ตารางงานและเวลาทำงาน'),
            const SizedBox(height: 8),
            const Text('ประเภทการทำงาน:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: _workingType.map((type) {
                return Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: type,
                        groupValue: _selectedWorkingType,
                        onChanged: (value) {
                          setState(() {
                            _selectedWorkingType = value;
                          });
                        },
                      ),
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('วันทำงาน:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _workingDayOptions.map((day) {
                return FilterChip(
                  label: Text(day),
                  selected: _selectedWorkingDays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWorkingDays.add(day);
                      } else {
                        _selectedWorkingDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _workingHoursController,
              decoration: const InputDecoration(
                labelText: 'เลือกเวลาเริ่มงาน',
                hintText: 'เช่น 08:00 น.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Date Filters Section
            _buildSectionTitle('ช่วงวันทำงาน'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'วันที่เริ่มต้น',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _startDate?.toString().split(' ')[0] ?? 'เลือกวันที่',
                        style: TextStyle(
                          color: _startDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'วันที่สิ้นสุด',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _endDate?.toString().split(' ')[0] ?? 'เลือกวันที่',
                        style: TextStyle(
                          color: _endDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // // Work Preferences Section
            // _buildSectionTitle('ลักษณะงาน'),
            // const SizedBox(height: 8),
            // SwitchListTile(
            //   title: const Text('งานด่วน'),
            //   subtitle: const Text('งานที่ต้องการคนเร่งด่วน'),
            //   value: _isUrgent,
            //   onChanged: (value) {
            //     setState(() {
            //       _isUrgent = value;
            //     });
            //   },
            // ),
            // SwitchListTile(
            //   title: const Text('ทำงานระยะไกล'),
            //   subtitle: const Text('สามารถทำงานจากที่ไหนก็ได้'),
            //   value: _isRemote,
            //   onChanged: (value) {
            //     setState(() {
            //       _isRemote = value;
            //     });
            //   },
            // ),
            // const SizedBox(height: 24),

            // Additional Requirements Section
            _buildSectionTitle('ข้อกำหนดเพิ่มเติม'),
            const SizedBox(height: 8),
            TextField(
              controller: _additionalRequirementsController,
              decoration: const InputDecoration(
                labelText: 'ข้อกำหนดพิเศษ',
                hintText: 'เช่น ห้องพักแพทย์, ที่จอดรถ, wifi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _searchJobs,
                    child: const Text('ค้นหา'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
} 