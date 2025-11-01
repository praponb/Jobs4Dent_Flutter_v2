import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String? selectedUserType;
  bool isDentist = true;

  final List<Map<String, dynamic>> userTypes = [
    {
      'type': 'dentist',
      'title': 'ทันตแพทย์',
      'description': 'ผู้เชี่ยวชาญทันตกรรมที่ได้รับใบอนุญาตแล้ว',
      'icon': Icons.medical_services,
      'isDentist': true,
    },
    {
      'type': 'assistant',
      'title': 'ผู้ช่วยทันตแพทย์',
      'description': 'ผู้ช่วยทันตแพทย์ที่กำลังมองหางาน',
      'icon': Icons.medical_information,
      'isDentist': true,
    },
    {
      'type': 'clinic',
      'title': 'เจ้าของคลินิก',
      'description': 'คลินิกทันตกรรมที่กำลังมองหาบุคลากร',
      'icon': Icons.business,
      'isDentist': false,
    },
    // {
    //   'type': 'seller',
    //   'title': 'ผู้ขายอุปกรณ์',
    //   'description': 'ผู้ขายอุปกรณ์และเวชภัณฑ์ทันตกรรม',
    //   'icon': Icons.store,
    //   'isDentist': false,
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('เลือกบทบาทของคุณ'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Header
              const Text(
                'อะไรที่อธิบายคุณได้ดีที่สุด?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'เลือกบทบาทของคุณเพื่อปรับแต่งประสบการณ์ของคุณ',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // User Type Selection
              Expanded(
                child: ListView.builder(
                  itemCount: userTypes.length,
                  itemBuilder: (context, index) {
                    final userType = userTypes[index];
                    final isSelected = selectedUserType == userType['type'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedUserType = userType['type'];
                            isDentist = userType['isDentist'];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2196F3)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? const Color(
                                    0xFF2196F3,
                                  ).withValues(alpha: 0.05)
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF2196F3)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  userType['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userType['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF2196F3)
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userType['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2196F3),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: selectedUserType == null
                        ? null
                        : () async {
                            bool success = await authProvider.updateUserProfile(
                              isDentist: isDentist,
                              userType: selectedUserType!,
                            );

                            if (success && context.mounted) {
                              // Navigate to home screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            } else if (authProvider.error != null &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authProvider.error!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'ดำเนินการต่อ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
