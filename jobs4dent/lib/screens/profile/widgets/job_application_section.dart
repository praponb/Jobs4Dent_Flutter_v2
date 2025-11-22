import 'package:flutter/material.dart';
import '../assistant_skills_data.dart';

class JobApplicationSection extends StatelessWidget {
  final String? selectedEducationLevel;
  final String? selectedJobType;
  final String? selectedJobReadiness;
  final TextEditingController requestedMinSalaryController;
  final TextEditingController requestedMaxSalaryController;
  final Function(String?) onEducationLevelChanged;
  final Function(String?) onJobTypeChanged;
  final Function(String?) onJobReadinessChanged;

  const JobApplicationSection({
    super.key,
    required this.selectedEducationLevel,
    required this.selectedJobType,
    required this.selectedJobReadiness,
    required this.requestedMinSalaryController,
    required this.requestedMaxSalaryController,
    required this.onEducationLevelChanged,
    required this.onJobTypeChanged,
    required this.onJobReadinessChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.work, color: Colors.blue[600], size: 24),
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
            key: ValueKey(selectedEducationLevel),
            initialValue: selectedEducationLevel,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'ระดับการศึกษา',
              border: OutlineInputBorder(),
            ),
            items: AssistantSkillsData.educationLevelOptions.map((level) {
              return DropdownMenuItem(value: level, child: Text(level));
            }).toList(),
            onChanged: onEducationLevelChanged,
            validator: (value) {
              if (value == null) {
                return 'กรุณาเลือกระดับการศึกษา';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(selectedJobType),
            initialValue: selectedJobType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'ประเภทงาน',
              border: OutlineInputBorder(),
            ),
            items: AssistantSkillsData.jobTypeOptions.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: onJobTypeChanged,
            validator: (value) {
              if (value == null) {
                return 'กรุณาเลือกประเภทงาน';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: requestedMinSalaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'รายได้ที่ต้องการขั้นต่ำ (บาท/เดือน)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
            controller: requestedMaxSalaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'รายได้ที่ต้องการสูงสุด (บาท/เดือน)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
            key: ValueKey(selectedJobReadiness),
            initialValue: selectedJobReadiness,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'ความพร้อมเริ่มงาน',
              border: OutlineInputBorder(),
            ),
            items: AssistantSkillsData.jobReadinessOptions.map((readiness) {
              return DropdownMenuItem(value: readiness, child: Text(readiness));
            }).toList(),
            onChanged: onJobReadinessChanged,
            validator: (value) {
              if (value == null) {
                return 'กรุณาเลือกความพร้อมเริ่มงาน';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
