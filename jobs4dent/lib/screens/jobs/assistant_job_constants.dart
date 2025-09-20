/// Constants for Assistant Job Posting functionality
class AssistantJobConstants {
  // Work type options
  static const List<String> workTypes = ['Part-time', 'Full-time'];

  // Payment terms for Part-time work
  static const List<String> paymentTermsPartTime = [
    'รับเงินสด/โอนทันที หลังจบงาน',
    'โอนวันถัดไป',
    'โอนสัปดาห์ถัดไป',
    'รวมโอนให้สิ้นเดือน',
    'ตามตกลง',
  ];

  // Day off options for Full-time work
  static const List<String> dayOffFullTimeOptions = [
    'หยุด1 วันต่อสัปดาห์',
    'หยุด 2 วันต่อสัปดาห์',
    'หยุด 3 วันต่อสัปดาห์',
    'หยุด เสาร์-อาทิตย์',
  ];

  // Get all available assistant skills combined
  static const List<String> allAssistantSkills = [
    'GP – อุด ขูด ถอน',
    'Ortho – จัดฟัน',
    'GP & จัดฟัน',
    'GP & ฟันปลอม',
    'ศัลย์',
    'รักษาราก',
    'ฟันปลอม',
    'รากเทียม',
    'X-Ray',
    'รักษาเด็ก',
    'ช่วยได้ทุกงาน',
    'เคาน์เตอร์',
    'ผู้จัดการคลินิก',
  ];
}
