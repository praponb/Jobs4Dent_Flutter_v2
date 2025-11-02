import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/assistant_job_model.dart';
import '../../models/job_application_model.dart';
import '../../services/notification_service.dart';
import 'assistant_job_constants.dart';

class AssistantJobSearchScreen extends StatefulWidget {
  const AssistantJobSearchScreen({super.key});

  @override
  State<AssistantJobSearchScreen> createState() =>
      _AssistantJobSearchScreenState();
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
      // First try the query with orderBy and limit to 1000 records
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection('job_posts_assistant')
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .limit(1000)
            .get();
      } catch (indexError) {
        debugPrint(
          'Index error, falling back to query without orderBy: $indexError',
        );
        // Fallback: Query without orderBy if index doesn't exist
        querySnapshot = await _firestore
            .collection('job_posts_assistant')
            .where('isActive', isEqualTo: true)
            .limit(1000)
            .get();
      }

      final jobs = <AssistantJobModel>[];

      for (var doc in querySnapshot.docs) {
        try {
          final jobData = doc.data() as Map<String, dynamic>;
          // Add document ID to the data if it's missing
          jobData['jobId'] = jobData['jobId'] ?? doc.id;

          // Debug: Print raw Firestore data for perk field
          debugPrint('🔍 Initial load - Raw Firestore data for job ${doc.id}:');
          debugPrint('   - perk field: "${jobData['perk']}"');
          debugPrint('   - workType: "${jobData['workType']}"');

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

      debugPrint(
        '📊 Loaded ${jobs.length} assistant jobs from Firestore (max 1000)',
      );
      debugPrint(
        '📊 Total documents in query result: ${querySnapshot.docs.length}',
      );

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
            .limit(1000)
            .get();
      } catch (indexError) {
        debugPrint(
          'Index error in search, falling back to query without orderBy: $indexError',
        );
        querySnapshot = await query.limit(1000).get();
      }

      List<AssistantJobModel> jobs = <AssistantJobModel>[];

      for (var doc in querySnapshot.docs) {
        try {
          final jobData = doc.data() as Map<String, dynamic>;
          jobData['jobId'] = jobData['jobId'] ?? doc.id;

          // Debug: Print raw Firestore data for perk field
          debugPrint('🔍 Raw Firestore data for job ${doc.id}:');
          debugPrint('   - perk field: "${jobData['perk']}"');
          debugPrint('   - workType: "${jobData['workType']}"');

          final job = AssistantJobModel.fromMap(jobData);
          jobs.add(job);
        } catch (parseError) {
          debugPrint('Error parsing job document ${doc.id}: $parseError');
          // Continue with other documents
        }
      }

      // Sort by createdAt if we used fallback query
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint(
        '📊 Search loaded ${jobs.length} assistant jobs from Firestore (max 1000)',
      );
      debugPrint(
        '📊 Total documents in search result: ${querySnapshot.docs.length}',
      );

      // Debug: Print perk values for all jobs
      debugPrint('🔍 Debug: Perk values in jobs:');
      for (int i = 0; i < jobs.length && i < 5; i++) {
        final job = jobs[i];
        debugPrint(
          '   Job ${i + 1}: "${job.titlePost}" - Perk: "${job.perk ?? 'null'}"',
        );
      }

      // Apply text-based filters (Firestore doesn't support complex text search)
      if (_keywordController.text.trim().isNotEmpty) {
        final keyword = _keywordController.text.trim().toLowerCase();
        debugPrint('🔍 Searching for keyword: "$keyword"');
        debugPrint('📊 Total jobs before keyword filter: ${jobs.length}');

        jobs = jobs.where((job) {
          final titleMatch = job.titlePost.toLowerCase().contains(keyword);
          final clinicMatch = job.clinicNameAndBranch.toLowerCase().contains(
            keyword,
          );
          final perkMatch =
              job.perk != null && job.perk!.toLowerCase().contains(keyword);

          // Debug print for each job
          if (titleMatch || clinicMatch || perkMatch) {
            debugPrint('✅ Job "${job.titlePost}" matches keyword "$keyword"');
            if (perkMatch) {
              debugPrint('   - Perk field contains keyword: "${job.perk}"');
            }
          }

          return titleMatch || clinicMatch || perkMatch;
        }).toList();

        debugPrint('📊 Total jobs after keyword filter: ${jobs.length}');
      }

      if (_locationController.text.trim().isNotEmpty) {
        final location = _locationController.text.trim().toLowerCase();
        debugPrint('🔍 Searching for location: "$location"');
        debugPrint('📊 Total jobs before location filter: ${jobs.length}');

        jobs = jobs.where((job) {
          final clinicMatch = job.clinicNameAndBranch.toLowerCase().contains(
            location,
          );
          final perkMatch =
              job.perk != null && job.perk!.toLowerCase().contains(location);

          // Debug print for location matches
          if (clinicMatch || perkMatch) {
            debugPrint('✅ Job "${job.titlePost}" matches location "$location"');
            if (perkMatch) {
              debugPrint('   - Perk field contains location: "${job.perk}"');
            }
            if (clinicMatch) {
              debugPrint(
                '   - Clinic field contains location: "${job.clinicNameAndBranch}"',
              );
            }
          }

          return clinicMatch || perkMatch;
        }).toList();

        debugPrint('📊 Total jobs after location filter: ${jobs.length}');
      }

      // Filter by selected skills
      if (_selectedSkills.isNotEmpty) {
        jobs = jobs.where((job) {
          return _selectedSkills.any(
            (skill) => job.skillAssistant.contains(skill),
          );
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
                          }),
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
                        color: _selectedSkills.isEmpty
                            ? Colors.grey[600]
                            : Colors.black,
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
          Expanded(child: _buildJobsList()),
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
            ElevatedButton(onPressed: _loadJobs, child: const Text('ลองใหม่')),
          ],
        ),
      );
    }

    if (_jobs.isEmpty) {
      return const Center(child: Text('ไม่พบงานที่ค้นหา'));
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: job.workType == 'Full-time'
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          job.workType,
                          style: TextStyle(
                            fontSize: 12,
                            color: job.workType == 'Full-time'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showReportDialog(job),
                        icon: const Icon(Icons.flag_outlined, size: 20),
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: job.skillAssistant.take(3).map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                    if (job.skillAssistant.length > 3) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: job.skillAssistant.skip(3).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Salary/Rate information
              if (job.workType == 'Part-time') ...[
                if (job.payPerDayPartTime != null ||
                    job.payPerHourPartTime != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatPartTimeRate(job),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ] else ...[
                if (job.salaryFullTime != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'เงินเดือน ${job.salaryFullTime} บาท',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: AssistantJobConstants.allAssistantSkills.map((
                        skill,
                      ) {
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
                            setState(
                              () => _selectedSkills = tempSelectedSkills,
                            );
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

                        // Location Information
                        if (job.selectedProvinceZones != null ||
                            job.selectedLocationZones != null ||
                            job.selectedTrainLine != null ||
                            job.selectedTrainStation != null) ...[
                          const Text(
                            'ข้อมูลสถานที่:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (job.selectedProvinceZones != null)
                            _buildDetailRow(
                              'โซนที่ตั้ง',
                              job.selectedProvinceZones!,
                            ),
                          if (job.selectedLocationZones != null)
                            _buildDetailRow(
                              'จังหวัด/โซนในจังหวัด',
                              job.selectedLocationZones!,
                            ),
                          if (job.selectedTrainLine != null)
                            _buildDetailRow('รถไฟฟ้า', job.selectedTrainLine!),
                          if (job.selectedTrainStation != null)
                            _buildDetailRow(
                              'สถานีรถไฟฟ้า',
                              job.selectedTrainStation!,
                            ),
                          const SizedBox(height: 8),
                        ],

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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
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
                            _buildDetailRow(
                              'เงื่อนไขการจ่าย',
                              job.paymentTermPartTime!,
                            ),
                          if (job.payPerDayPartTime != null &&
                              job.payPerDayPartTime!.isNotEmpty)
                            _buildDetailRow(
                              'ค่าแรงต่อวัน',
                              '${job.payPerDayPartTime} บาท',
                            ),
                          if (job.payPerHourPartTime != null &&
                              job.payPerHourPartTime!.isNotEmpty)
                            _buildDetailRow(
                              'ค่าแรงต่อชั่วโมง',
                              '${job.payPerHourPartTime} บาท',
                            ),
                          if (job.workDayPartTime != null &&
                              job.workDayPartTime!.isNotEmpty)
                            _buildDetailRow(
                              'วันทำงาน',
                              _formatWorkDays(job.workDayPartTime!),
                            ),
                        ],

                        // Full-time specific details
                        if (job.workType == 'Full-time') ...[
                          if (job.salaryFullTime != null &&
                              job.salaryFullTime!.isNotEmpty)
                            _buildDetailRow(
                              'เงินเดือน',
                              '${job.salaryFullTime} บาท',
                            ),
                          if (job.totalIncomeFullTime != null &&
                              job.totalIncomeFullTime!.isNotEmpty)
                            _buildDetailRow(
                              'รายได้รวม',
                              '${job.totalIncomeFullTime} บาท',
                            ),
                          if (job.dayOffFullTime != null)
                            _buildDetailRow('วันหยุด', job.dayOffFullTime!),
                          if (job.workTimeStart != null &&
                              job.workTimeEnd != null)
                            _buildDetailRow(
                              'เวลาทำงาน',
                              '${job.workTimeStart} - ${job.workTimeEnd}',
                            ),
                          if (job.perk != null && job.perk!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'สวัสดิการและรายละเอียดเพิ่มเติม',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
          Expanded(child: Text(value)),
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

  void _showReportDialog(AssistantJobModel job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('รายงานโพสต์งาน'),
          content: const Text(
            'คุณต้องการรายงานโพสต์งานนี้ว่าไม่เหมาะสมหรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _reportJob(job);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('รายงาน'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reportJob(AssistantJobModel job) async {
    try {
      await _firestore.collection('job_posts_assistant').doc(job.jobId).update({
        'reported': true,
        'updatedAt': DateTime.now(),
      });

      // Update local state
      setState(() {
        final index = _jobs.indexWhere((j) => j.jobId == job.jobId);
        if (index != -1) {
          _jobs[index] = job.copyWith(reported: true);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รายงานโพสต์งานเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error reporting job: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการรายงาน'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _applyForJob(AssistantJobModel job) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนสมัครงาน')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = authProvider.userModel!;
      final now = DateTime.now();

      // Check if already applied
      final existingApplication = await _firestore
          .collection('job_applications_assistant')
          .where('jobId', isEqualTo: job.jobId)
          .where('applicantId', isEqualTo: user.userId)
          .limit(1)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('คุณได้สมัครงานนี้แล้ว'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Fetch additional user data from 'users' collection
      final userDoc = await _firestore
          .collection('users')
          .doc(user.userId)
          .get();

      Map<String, dynamic> userData = {};
      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;
        debugPrint(
          'Fetched user data from users collection: ${userData.keys.toList()}',
        );
      }

      // Check verification status
      final verificationStatus = userData['verificationStatus'] ?? 'unverified';
      if (verificationStatus != 'verified') {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('ไม่สามารถสมัครงานได้'),
              content: const Text(
                'บัญชีของคุณยังไม่ได้รับการยืนยันตัวตน กรุณายืนยันตัวตนก่อนสมัครงาน',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ปิด'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Create application ID
      final applicationId = _firestore
          .collection('job_applications_assistant')
          .doc()
          .id;

      // Create comprehensive applicant profile with data from AssistantMiniResumeScreen
      final applicantProfile = {
        // Basic user information
        'userName': user.userName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'profilePhotoUrl': user.profilePhotoUrl,
        'userType': user.userType,

        // Personal Information from AssistantMiniResumeScreen
        'fullName': userData['fullName'] ?? '',
        'nickName': userData['nickName'] ?? '',
        'age': userData['age'],

        // Job Application Information from AssistantMiniResumeScreen
        'educationLevel': userData['educationLevel'],
        'jobType': userData['jobType'],
        'minSalary': userData['minSalary'],
        'maxSalary': userData['maxSalary'],
        'jobReadiness': userData['jobReadiness'],

        // Education and Experience from AssistantMiniResumeScreen
        'educationInstitute': userData['educationInstitute'] ?? '',
        'experienceYears': userData['experienceYears'] ?? 0,
        'educationSpecialist': userData['educationSpecialist'] ?? '',

        // Skills from AssistantMiniResumeScreen
        'coreCompetencies': userData['coreCompetencies'] ?? [],
        'counterSkills': userData['counterSkills'] ?? [],
        'softwareSkills': userData['softwareSkills'] ?? [],
        'eqSkills': userData['eqSkills'] ?? [],
        'workLimitations': userData['workLimitations'] ?? [],

        // Additional profile information
        'address': userData['address'],
        'verificationStatus': userData['verificationStatus'] ?? 'unverified',
        'isProfileComplete': userData['isProfileComplete'] ?? false,
      };

      // Create job application
      final application = JobApplicationModel(
        applicationId: applicationId,
        jobId: job.jobId,
        applicantId: user.userId,
        clinicId: job.clinicId,
        applicantName: userData['fullName']?.toString() ?? user.userName,
        applicantEmail: user.email,
        applicantPhone: user.phoneNumber,
        applicantProfilePhoto: user.profilePhotoUrl,
        coverLetter:
            'สมัครงานตำแหน่ง ${job.titlePost} ที่ ${job.clinicNameAndBranch}',
        additionalDocuments: const [],
        status: 'submitted',
        appliedAt: now,
        updatedAt: now,
        notes: null,
        interviewDate: null,
        interviewLocation: null,
        interviewNotes: null,
        matchingScore: null,
        applicantProfile: applicantProfile,
        jobTitle: job.titlePost,
        clinicName: job.clinicNameAndBranch,
      );

      // Save to Firestore
      await _firestore
          .collection('job_applications_assistant')
          .doc(applicationId)
          .set(application.toMap());

      debugPrint('✅ Job application saved successfully: $applicationId');

      // Send push notification to clinic's mobile devices
      // This notifies the clinic when an assistant applies for their job
      try {
        final notificationService = NotificationService();
        await notificationService.sendJobApplicationNotification(
          clinicId: job.clinicId,
          applicantName: userData['fullName']?.toString() ?? user.userName,
          jobTitle: job.titlePost,
          applicationId: applicationId,
        );
        debugPrint('✅ Push notification sent to clinic: ${job.clinicId}');
      } catch (e) {
        debugPrint('⚠️ Error sending notification (non-critical): $e');
        // Don't fail the application process if notification fails
        // The application is already saved, notification is just a convenience
      }

      // Update job's application count
      await _firestore.collection('job_posts_assistant').doc(job.jobId).update({
        'applicationCount': FieldValue.increment(1),
        'applicationIds': FieldValue.arrayUnion([applicationId]),
        'updatedAt': now.millisecondsSinceEpoch,
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สมัครงาน ${job.titlePost} สำเร็จแล้ว!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(label: 'ปิด', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error applying for job: $e');
    }
  }
}
