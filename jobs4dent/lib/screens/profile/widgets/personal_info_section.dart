import 'package:flutter/material.dart';

class PersonalInfoSection extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController nickNameController;
  final TextEditingController ageController;
  final TextEditingController phoneNumberController;

  const PersonalInfoSection({
    super.key,
    required this.fullNameController,
    required this.nickNameController,
    required this.ageController,
    required this.phoneNumberController,
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
            controller: fullNameController,
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
            controller: nickNameController,
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
            controller: ageController,
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
            controller: phoneNumberController,
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
    );
  }
} 