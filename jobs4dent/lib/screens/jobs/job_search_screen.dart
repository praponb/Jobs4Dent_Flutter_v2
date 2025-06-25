import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_model.dart';
// import 'job_detail_screen.dart'; // TODO: Create this screen

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // Filter values
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedJobType;
  String? _selectedJobCategory;
  String? _selectedExperienceLevel;
  List<String> _selectedSkills = [];
  List<String> _selectedSpecialties = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isRemote = false;
  bool _isUrgent = false;
  bool _showFilters = false;

  // Thai provinces for location filter
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

  // Common dental skills
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performInitialSearch();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _performInitialSearch() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    jobProvider.searchJobs(
      userId: authProvider.user?.uid, // For matching calculation
    );
  }

  void _performSearch() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    jobProvider.searchJobs(
      keyword: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      province: _selectedProvince,
      city: _selectedCity,
      jobType: _selectedJobType,
      jobCategory: _selectedJobCategory,
      experienceLevel: _selectedExperienceLevel,
      minSalary: _minSalaryController.text.isNotEmpty ? double.tryParse(_minSalaryController.text) : null,
      maxSalary: _maxSalaryController.text.isNotEmpty ? double.tryParse(_maxSalaryController.text) : null,
      requiredSkills: _selectedSkills.isNotEmpty ? _selectedSkills : null,
      requiredSpecialties: _selectedSpecialties.isNotEmpty ? _selectedSpecialties : null,
      startDate: _startDate,
      endDate: _endDate,
      isRemote: _isRemote,
      isUrgent: _isUrgent,
      userId: authProvider.user?.uid,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _minSalaryController.clear();
      _maxSalaryController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _selectedProvince = null;
      _selectedCity = null;
      _selectedJobType = null;
      _selectedJobCategory = null;
      _selectedExperienceLevel = null;
      _selectedSkills.clear();
      _selectedSpecialties.clear();
      _startDate = null;
      _endDate = null;
      _isRemote = false;
      _isUrgent = false;
    });
    _performInitialSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Jobs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search Jobs'),
            Tab(text: 'Recommended'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildRecommendedTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search jobs, companies, or keywords...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _performSearch();
                },
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),

        // Filters Section
        if (_showFilters) _buildFiltersSection(),

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
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading jobs',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(jobProvider.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _performInitialSearch,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (jobProvider.jobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No jobs found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text('Try adjusting your search criteria'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildRecommendedTab() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final recommendedJobs = jobProvider.jobs
            .where((job) => (job.matchingScore ?? 0) > 50)
            .toList();

        if (recommendedJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.recommend, size: 64, color: Colors.blue[300]),
                const SizedBox(height: 16),
                Text(
                  'No recommendations yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Complete your profile to get better job recommendations'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: const Text('Complete Profile'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recommendedJobs.length,
          itemBuilder: (context, index) {
            final job = recommendedJobs[index];
            return _buildJobCard(job, showMatchScore: true);
          },
        );
      },
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedProvince,
                  decoration: const InputDecoration(
                    labelText: 'Province',
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
                      _selectedProvince = value;
                      _selectedCity = null; // Clear city when province changes
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'City/District',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _selectedCity = value.isEmpty ? null : value;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Job type and category
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedJobType,
                  decoration: const InputDecoration(
                    labelText: 'Job Type',
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
                      _selectedJobType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedJobCategory,
                  decoration: const InputDecoration(
                    labelText: 'Job Category',
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
                      _selectedJobCategory = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Experience level
          DropdownButtonFormField<String>(
            value: _selectedExperienceLevel,
            decoration: const InputDecoration(
              labelText: 'Experience Level',
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
                _selectedExperienceLevel = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Salary range
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minSalaryController,
                  decoration: const InputDecoration(
                    labelText: 'Min Salary (THB)',
                    border: OutlineInputBorder(),
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
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Skills multi-select
          MultiSelectDialogField<String>(
            items: _dentalSkills.map((skill) => MultiSelectItem(skill, skill)).toList(),
            title: const Text('Skills'),
            selectedColor: Theme.of(context).primaryColor,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            buttonIcon: const Icon(Icons.arrow_drop_down),
            buttonText: Text(
              _selectedSkills.isEmpty 
                  ? 'Select Skills' 
                  : '${_selectedSkills.length} skills selected',
            ),
            onConfirm: (values) {
              setState(() {
                _selectedSkills = values;
              });
            },
            initialValue: _selectedSkills,
          ),
          const SizedBox(height: 16),

          // Specialties multi-select
          MultiSelectDialogField<String>(
            items: _dentalSpecialties.map((specialty) => MultiSelectItem(specialty, specialty)).toList(),
            title: const Text('Specialties'),
            selectedColor: Theme.of(context).primaryColor,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            buttonIcon: const Icon(Icons.arrow_drop_down),
            buttonText: Text(
              _selectedSpecialties.isEmpty 
                  ? 'Select Specialties' 
                  : '${_selectedSpecialties.length} specialties selected',
            ),
            onConfirm: (values) {
              setState(() {
                _selectedSpecialties = values;
              });
            },
            initialValue: _selectedSpecialties,
          ),
          const SizedBox(height: 16),

          // Boolean filters
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Remote Work'),
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
                  title: const Text('Urgent Hiring'),
                  value: _isUrgent,
                  onChanged: (value) {
                    setState(() {
                      _isUrgent = value ?? false;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Search Jobs'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobModel job, {bool showMatchScore = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to job detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Job Detail Screen - Coming Soon')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and match score
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.clinicName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showMatchScore && job.matchingScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${job.matchingScore!.round()}% match',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Location and job type
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${job.city}, ${job.province}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.work, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    job.jobType.toUpperCase(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Salary information
              if (job.minSalary != null || job.maxSalary != null)
                Row(
                  children: [
                    Icon(Icons.payments, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatSalary(job),
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // Job description preview
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),

              // Tags row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (job.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'URGENT',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        if (job.isRemote)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'REMOTE',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            job.jobCategory,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTimeAgo(job.createdAt),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
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
      return '฿${job.minSalary!.toStringAsFixed(0)} - ฿${job.maxSalary!.toStringAsFixed(0)} ${job.salaryType}';
    } else if (job.minSalary != null) {
      return '฿${job.minSalary!.toStringAsFixed(0)}+ ${job.salaryType}';
    } else if (job.maxSalary != null) {
      return 'Up to ฿${job.maxSalary!.toStringAsFixed(0)} ${job.salaryType}';
    }
    return 'Salary negotiable';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 