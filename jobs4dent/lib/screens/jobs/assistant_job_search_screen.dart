import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/assistant_job_model.dart';
import 'assistant_job_constants.dart';

class AssistantJobSearchScreen extends StatefulWidget {
  const AssistantJobSearchScreen({super.key});

  @override
  State<AssistantJobSearchScreen> createState() => _AssistantJobSearchScreenState();
}

class _AssistantJobSearchScreenState extends State<AssistantJobSearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  List<AssistantJobModel> _jobs = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedWorkType;
  List<String> _selectedSkills = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First try the query with orderBy
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection('job_posts_assistant')
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (indexError) {
        debugPrint('Index error, falling back to query without orderBy: $indexError');
        // Fallback: Query without orderBy if index doesn't exist
        querySnapshot = await _firestore
            .collection('job_posts_assistant')
            .where('isActive', isEqualTo: true)
            .get();
      }

      final jobs = <AssistantJobModel>[];
      
      for (var doc in querySnapshot.docs) {
        try {
          final jobData = doc.data() as Map<String, dynamic>;
          // Add document ID to the data if it's missing
          jobData['jobId'] = jobData['jobId'] ?? doc.id;
          final job = AssistantJobModel.fromMap(jobData);
          jobs.add(job);
        } catch (parseError) {
          debugPrint('Error parsing job document ${doc.id}: $parseError');
          debugPrint('Document data: ${doc.data()}');
          // Continue with other documents instead of failing entirely
        }
      }

      // Sort jobs by createdAt if we used the fallback query
      if (querySnapshot.docs.isNotEmpty) {
        jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading assistant jobs: $e');
      setState(() {
        _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Query query = _firestore
          .collection('job_posts_assistant')
          .where('isActive', isEqualTo: true);

      // Apply filters
      if (_selectedWorkType != null && _selectedWorkType!.isNotEmpty) {
        query = query.where('workType', isEqualTo: _selectedWorkType);
      }

      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await query
            .orderBy('createdAt', descending: true)
            .get();
      } catch (indexError) {
        debugPrint('Index error in search, falling back to query without orderBy: $indexError');
        querySnapshot = await query.get();
      }

      List<AssistantJobModel> jobs = <AssistantJobModel>[];
      
      for (var doc in querySnapshot.docs) {
        try {
          final jobData = doc.data() as Map<String, dynamic>;
          jobData['jobId'] = jobData['jobId'] ?? doc.id;
          final job = AssistantJobModel.fromMap(jobData);
          jobs.add(job);
        } catch (parseError) {
          debugPrint('Error parsing job document ${doc.id}: $parseError');
          // Continue with other documents
        }
      }

      // Sort by createdAt if we used fallback query
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply text-based filters (Firestore doesn't support complex text search)
      if (_keywordController.text.trim().isNotEmpty) {
        final keyword = _keywordController.text.trim().toLowerCase();
        jobs = jobs.where((job) {
          return job.titlePost.toLowerCase().contains(keyword) ||
                 job.clinicNameAndBranch.toLowerCase().contains(keyword);
        }).toList();
      }

      if (_locationController.text.trim().isNotEmpty) {
        final location = _locationController.text.trim().toLowerCase();
        jobs = jobs.where((job) {
          return job.clinicNameAndBranch.toLowerCase().contains(location);
        }).toList();
      }

      // Filter by selected skills
      if (_selectedSkills.isNotEmpty) {
        jobs = jobs.where((job) {
          return _selectedSkills.any((skill) => job.skillAssistant.contains(skill));
        }).toList();
      }

      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error searching assistant jobs: $e');
      setState(() {
        _error = 'เกิดข้อผิดพลาดในการค้นหา';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหางานผู้ช่วยทันตแพทย์'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _keywordController,
                        decoration: const InputDecoration(
                          hintText: 'ค้นหาชื่องาน หรือคลินิก...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _searchJobs(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchJobs,
                      child: const Text('ค้นหา'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: 'สถานที่...',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _searchJobs(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedWorkType,
                        decoration: const InputDecoration(
                          hintText: 'ประเภทงาน',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('ทั้งหมด'),
                          ),
                          ...AssistantJobConstants.workTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedWorkType = value);
                          _searchJobs();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Skills Filter
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: Text(
                      _selectedSkills.isEmpty
                          ? 'เลือกทักษะที่ต้องการ'
                          : '${_selectedSkills.length} ทักษะที่เลือก',
                      style: TextStyle(
                        color: _selectedSkills.isEmpty ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: _showSkillFilterModal,
                  ),
                ),
              ],
            ),
          ),
          
          // Search Criteria Display
          if (_hasActiveFilters()) _buildSearchCriteria(),
          
          // Results
          Expanded(
            child: _buildJobsList(),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _keywordController.text.trim().isNotEmpty ||
           _locationController.text.trim().isNotEmpty ||
           _selectedWorkType != null ||
           _selectedSkills.isNotEmpty;
  }

  Widget _buildSearchCriteria() {
    List<String> criteria = [];
    
    if (_keywordController.text.trim().isNotEmpty) {
      criteria.add('คำค้นหา: ${_keywordController.text.trim()}');
    }
    if (_locationController.text.trim().isNotEmpty) {
      criteria.add('สถานที่: ${_locationController.text.trim()}');
    }
    if (_selectedWorkType != null) {
      criteria.add('ประเภท: $_selectedWorkType');
    }
    if (_selectedSkills.isNotEmpty) {
      criteria.add('ทักษะ: ${_selectedSkills.length} รายการ');
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 4),
              Text(
                'เงื่อนไขการค้นหา',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: criteria.map((criterion) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Text(
                  criterion,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadJobs,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }
    
    if (_jobs.isEmpty) {
      return const Center(
        child: Text('ไม่พบงานที่ค้นหา'),
      );
    }
    
    return ListView.builder(
      itemCount: _jobs.length,
      itemBuilder: (context, index) {
        final job = _jobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(AssistantJobModel job) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showJobDetails(job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.titlePost,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: job.workType == 'Full-time' ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job.workType,
                      style: TextStyle(
                        fontSize: 12,
                        color: job.workType == 'Full-time' ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.clinicNameAndBranch,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              
              // Skills display
              if (job.skillAssistant.isNotEmpty) ...[
                const Text(
                  'ทักษะที่ต้องการ:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: job.skillAssistant.take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  }).toList()..addAll([
                    if (job.skillAssistant.length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${job.skillAssistant.length - 3}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 8),
              ],
              
              // Salary/Rate information
              if (job.workType == 'Part-time') ...[
                if (job.payPerDayPartTime != null || job.payPerHourPartTime != null)
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatPartTimeRate(job),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
              ] else ...[
                if (job.salaryFullTime != null)
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'เงินเดือน ${job.salaryFullTime} บาท',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
              ],
              
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'โพสต์เมื่อ ${_formatDate(job.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${job.applicationCount} ใบสมัคร',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPartTimeRate(AssistantJobModel job) {
    List<String> rates = [];
    if (job.payPerDayPartTime != null && job.payPerDayPartTime!.isNotEmpty) {
      rates.add('${job.payPerDayPartTime}/วัน');
    }
    if (job.payPerHourPartTime != null && job.payPerHourPartTime!.isNotEmpty) {
      rates.add('${job.payPerHourPartTime}/ชม.');
    }
    return rates.isEmpty ? 'ตามตกลง' : rates.join(', ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เพิ่งโพสต์';
    }
  }

  void _showSkillFilterModal() {
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
                  const Text(
                    'เลือกทักษะที่ต้องการ',
                    style: TextStyle(
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
                          onPressed: () {
                            setModalState(() => tempSelectedSkills.clear());
                          },
                          child: const Text('ล้างทั้งหมด'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _selectedSkills = tempSelectedSkills);
                            Navigator.pop(context);
                            _searchJobs();
                          },
                          child: const Text('ยืนยัน'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showJobDetails(AssistantJobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text('รายละเอียดงาน'),
            ),
            leading: const SizedBox(), // Remove default back button
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
            elevation: 1,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.titlePost,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.clinicNameAndBranch,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('ประเภทงาน', job.workType),
                        
                        // Skills
                        if (job.skillAssistant.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'ทักษะที่ต้องการ:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: job.skillAssistant.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Text(
                                  skill,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        // Part-time specific details
                        if (job.workType == 'Part-time') ...[
                          if (job.paymentTermPartTime != null)
                            _buildDetailRow('เงื่อนไขการจ่าย', job.paymentTermPartTime!),
                          if (job.payPerDayPartTime != null && job.payPerDayPartTime!.isNotEmpty)
                            _buildDetailRow('ค่าแรงต่อวัน', '${job.payPerDayPartTime} บาท'),
                          if (job.payPerHourPartTime != null && job.payPerHourPartTime!.isNotEmpty)
                            _buildDetailRow('ค่าแรงต่อชั่วโมง', '${job.payPerHourPartTime} บาท'),
                          if (job.workDayPartTime != null && job.workDayPartTime!.isNotEmpty)
                            _buildDetailRow('วันทำงาน', _formatWorkDays(job.workDayPartTime!)),
                        ],
                        
                        // Full-time specific details
                        if (job.workType == 'Full-time') ...[
                          if (job.salaryFullTime != null && job.salaryFullTime!.isNotEmpty)
                            _buildDetailRow('เงินเดือน', '${job.salaryFullTime} บาท'),
                          if (job.totalIncomeFullTime != null && job.totalIncomeFullTime!.isNotEmpty)
                            _buildDetailRow('รายได้รวม', '${job.totalIncomeFullTime} บาท'),
                          if (job.dayOffFullTime != null)
                            _buildDetailRow('วันหยุด', job.dayOffFullTime!),
                          if (job.workTimeStart != null && job.workTimeEnd != null)
                            _buildDetailRow('เวลาทำงาน', '${job.workTimeStart} - ${job.workTimeEnd}'),
                          if (job.perk != null && job.perk!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'สวัสดิการและรายละเอียดเพิ่มเติม',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              job.perk!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ],
                        
                        const SizedBox(height: 16),
                        Text(
                          'โพสต์เมื่อ ${_formatDate(job.createdAt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyForJob(job);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'สมัครงาน',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatWorkDays(List<DateTime> workDays) {
    if (workDays.isEmpty) return 'ไม่ระบุ';
    
    final sortedDays = List<DateTime>.from(workDays)..sort();
    final formattedDays = sortedDays.map((date) {
      return '${date.day}/${date.month}/${date.year}';
    }).toList();
    
    if (formattedDays.length <= 3) {
      return formattedDays.join(', ');
    } else {
      return '${formattedDays.take(3).join(', ')} และอีก ${formattedDays.length - 3} วัน';
    }
  }

  void _applyForJob(AssistantJobModel job) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนสมัครงาน')),
      );
      return;
    }

    // For now, show a simple message since there's no specific assistant job application screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('สมัครงาน: ${job.titlePost}'),
        action: SnackBarAction(
          label: 'ปิด',
          onPressed: () {},
        ),
      ),
    );
    
    // TODO: Navigate to AssistantJobApplicationScreen when implemented
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AssistantJobApplicationScreen(job: job),
    //   ),
    // );
  }
} 