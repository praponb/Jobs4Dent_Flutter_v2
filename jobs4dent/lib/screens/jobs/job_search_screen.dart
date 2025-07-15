import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_model.dart';
import 'job_application_screen.dart';
import 'advanced_job_search_screen.dart';
import 'day_hour_job_search_screen.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedExperienceLevel;
  String? _selectedSalaryType;
  bool _isUrgent = false;
  bool _isRemote = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _locationController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    super.dispose();
  }

  void _loadJobs() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).searchJobs();
    });
  }

  void _searchJobs() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    jobProvider.searchJobs(
      keyword: _keywordController.text.trim().isEmpty ? null : _keywordController.text.trim(),
      jobCategory: _selectedCategory,
      experienceLevel: _selectedExperienceLevel,
      province: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      minSalary: _minSalaryController.text.trim().isEmpty ? null : double.tryParse(_minSalaryController.text.trim()),
      maxSalary: _maxSalaryController.text.trim().isEmpty ? null : double.tryParse(_maxSalaryController.text.trim()),
      isUrgent: _isUrgent ? true : null,
      isRemote: _isRemote ? true : null,
    );
  }

  void _clearFilters() {
    setState(() {
      _keywordController.clear();
      _locationController.clear();
      _minSalaryController.clear();
      _maxSalaryController.clear();
      _selectedCategory = null;
      _selectedExperienceLevel = null;
      _selectedSalaryType = null;
      _isUrgent = false;
      _isRemote = false;
    });
    _loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหางาน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
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
                          hintText: 'ค้นหาชื่องาน หรือคำอธิบาย...',
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DayHourJobSearchScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.tune),
                        label: const Text('เลือกวัน/เวลาทำงาน'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdvancedJobSearchScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.tune),
                        label: const Text('ค้นหาขั้นสูง'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: Consumer<JobProvider>(
              builder: (context, jobProvider, child) {
                if (jobProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (jobProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          jobProvider.error!,
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
                
                if (jobProvider.jobs.isEmpty) {
                  return const Center(
                    child: Text('ไม่พบงานที่ค้นหา'),
                  );
                }
                
                return ListView.builder(
                  itemCount: jobProvider.jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobProvider.jobs[index];
                    return _buildJobCard(job);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'กรองการค้นหา',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              _clearFilters();
                              Navigator.pop(context);
                            },
                            child: const Text('ล้างทั้งหมด'),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              // Location
                              TextField(
                                controller: _locationController,
                                decoration: const InputDecoration(
                                  labelText: 'สถานที่',
                                  border: OutlineInputBorder(),
                                  hintText: 'เช่น กรุงเทพมหานคร',
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Job Category
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'หมวดหมู่งาน',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('ทั้งหมด'),
                                  ),
                                  ...JobProvider.jobCategories.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Experience Level
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
                                    child: Text('ทั้งหมด'),
                                  ),
                                  ...JobProvider.experienceLevels.map((level) {
                                    return DropdownMenuItem(
                                      value: level,
                                      child: Text(level),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedExperienceLevel = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Salary Type
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
                                    child: Text('ทั้งหมด'),
                                  ),
                                  ...JobProvider.salaryTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedSalaryType = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Salary Range
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _minSalaryController,
                                      decoration: const InputDecoration(
                                        labelText: 'เงินเดือนต่ำสุด',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _maxSalaryController,
                                      decoration: const InputDecoration(
                                        labelText: 'เงินเดือนสูงสุด',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Checkboxes
                              CheckboxListTile(
                                title: const Text('งานด่วน'),
                                value: _isUrgent,
                                onChanged: (value) {
                                  setModalState(() {
                                    _isUrgent = value ?? false;
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('ทำงานจากที่ไหนก็ได้'),
                                value: _isRemote,
                                onChanged: (value) {
                                  setModalState(() {
                                    _isRemote = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('ยกเลิก'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  // Update the main state with modal state
                                });
                                Navigator.pop(context);
                                _searchJobs();
                              },
                              child: const Text('ใช้ตัวกรอง'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJobCard(JobModel job) {
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
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (job.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ด่วน',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.clinicName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.jobCategory,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${job.city}, ${job.province}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (job.minSalary != null || job.maxSalary != null)
                Row(
                  children: [
                    const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatSalary(job),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job.experienceLevel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job.salaryType,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  if (job.isRemote) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ระยะไกล',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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

  String _formatSalary(JobModel job) {
    if (job.minSalary != null && job.maxSalary != null) {
      return '${_formatNumber(job.minSalary!)} - ${_formatNumber(job.maxSalary!)} บาท';
    } else if (job.minSalary != null) {
      return 'เริ่มต้น ${_formatNumber(job.minSalary!)} บาท';
    } else if (job.maxSalary != null) {
      return 'สูงสุด ${_formatNumber(job.maxSalary!)} บาท';
    }
    return 'ตามตกลง';
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    } else {
      return number.toStringAsFixed(0);
    }
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

  void _showJobDetails(JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: const Text('รายละเอียดงาน'),
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
                          job.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.clinicName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('หมวดหมู่', job.jobCategory),
                        _buildDetailRow('ประสบการณ์', job.experienceLevel),
                        _buildDetailRow('ประเภทเงินเดือน', job.salaryType),
                        if (job.minSalary != null || job.maxSalary != null)
                          _buildDetailRow('เงินเดือน', _formatSalary(job)),
                        _buildDetailRow('สถานที่', '${job.city}, ${job.province}'),
                        if (job.trainLine != null && job.trainStation != null)
                          _buildDetailRow('รถไฟฟ้า', '${job.trainLine} - ${job.trainStation}'),
                        if (job.workingDays != null && job.workingDays!.isNotEmpty)
                          _buildDetailRow('วันทำงาน', job.workingDays!.join(', ')),
                        if (job.workingHours != null)
                          _buildDetailRow('เวลาทำงาน', job.workingHours!),
                        if (job.perks != null && job.perks!.isNotEmpty)
                          _buildDetailRow('สิทธิพิเศษ', job.perks!),
                        
                        const SizedBox(height: 16),
                        const Text(
                          'รายละเอียดงาน',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                        
                        if (job.additionalRequirements != null && job.additionalRequirements!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'ข้อกำหนดเพิ่มเติม',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.additionalRequirements!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (job.isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'ด่วน',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            if (job.isRemote) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ทำงานระยะไกล',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        
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
                      child: const Text('สมัครงาน'),
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
            width: 100,
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

  void _applyForJob(JobModel job) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนสมัครงาน')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobApplicationScreen(job: job),
      ),
    );
  }
} 