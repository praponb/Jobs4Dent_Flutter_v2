import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

class EducationExperienceScreen extends StatefulWidget {
  const EducationExperienceScreen({super.key});

  @override
  State<EducationExperienceScreen> createState() => _EducationExperienceScreenState();
}

class _EducationExperienceScreenState extends State<EducationExperienceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _educationList = [];
  List<Map<String, dynamic>> _experienceList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user != null) {
      _educationList = List<Map<String, dynamic>>.from(user.education ?? []);
      _experienceList = List<Map<String, dynamic>>.from(user.experience ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Education & Experience'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveData,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Education'),
            Tab(text: 'Experience'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEducationTab(),
          _buildExperienceTab(),
        ],
      ),
    );
  }

  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddButton(
            title: 'Add Education',
            onPressed: () => _showEducationDialog(),
          ),
          const SizedBox(height: 16),
          if (_educationList.isEmpty)
            _buildEmptyState(
              icon: Icons.school_outlined,
              title: 'No education added yet',
              subtitle: 'Add your educational qualifications',
            )
          else
            ..._educationList.asMap().entries.map((entry) {
              final index = entry.key;
              final education = entry.value;
              return _buildEducationCard(education, index);
            }),
        ],
      ),
    );
  }

  Widget _buildExperienceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddButton(
            title: 'Add Experience',
            onPressed: () => _showExperienceDialog(),
          ),
          const SizedBox(height: 16),
          if (_experienceList.isEmpty)
            _buildEmptyState(
              icon: Icons.work_outlined,
              title: 'No experience added yet',
              subtitle: 'Add your work experience',
            )
          else
            ..._experienceList.asMap().entries.map((entry) {
              final index = entry.key;
              final experience = entry.value;
              return _buildExperienceCard(experience, index);
            }),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> education, int index) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      education['degree'] ?? 'Degree',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      education['institution'] ?? 'Institution',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEducationDialog(education: education, index: index);
                  } else if (value == 'delete') {
                    _deleteEducation(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  education['graduationYear']?.toString() ?? 'Year',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (education['gpa'] != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'GPA: ${education['gpa']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience, int index) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience['position'] ?? 'Position',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience['company'] ?? 'Company',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showExperienceDialog(experience: experience, index: index);
                  } else if (value == 'delete') {
                    _deleteExperience(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${experience['startYear']?.toString() ?? ''} - ${experience['endYear']?.toString() ?? 'Present'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (experience['description'] != null && experience['description'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              experience['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEducationDialog({Map<String, dynamic>? education, int? index}) {
    final degreeController = TextEditingController(text: education?['degree'] ?? '');
    final institutionController = TextEditingController(text: education?['institution'] ?? '');
    final graduationYearController = TextEditingController(
      text: education?['graduationYear']?.toString() ?? '',
    );
    final gpaController = TextEditingController(text: education?['gpa']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(education == null ? 'Add Education' : 'Edit Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: degreeController,
                decoration: const InputDecoration(
                  labelText: 'Degree',
                  hintText: 'e.g., Doctor of Dental Surgery',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: institutionController,
                decoration: const InputDecoration(
                  labelText: 'Institution',
                  hintText: 'e.g., University of California',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: graduationYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Graduation Year',
                  hintText: 'e.g., 2020',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gpaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'GPA (Optional)',
                  hintText: 'e.g., 3.8',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newEducation = {
                'degree': degreeController.text.trim(),
                'institution': institutionController.text.trim(),
                'graduationYear': int.tryParse(graduationYearController.text.trim()),
                'gpa': gpaController.text.trim().isNotEmpty 
                    ? double.tryParse(gpaController.text.trim())
                    : null,
              };

              if ((newEducation['degree'] as String).isNotEmpty && 
                  (newEducation['institution'] as String).isNotEmpty) {
                setState(() {
                  if (index != null) {
                    _educationList[index] = newEducation;
                  } else {
                    _educationList.add(newEducation);
                  }
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in degree and institution'),
                  ),
                );
              }
            },
            child: Text(education == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showExperienceDialog({Map<String, dynamic>? experience, int? index}) {
    final positionController = TextEditingController(text: experience?['position'] ?? '');
    final companyController = TextEditingController(text: experience?['company'] ?? '');
    final startYearController = TextEditingController(
      text: experience?['startYear']?.toString() ?? '',
    );
    final endYearController = TextEditingController(
      text: experience?['endYear']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(text: experience?['description'] ?? '');
    bool isCurrentJob = experience?['isCurrent'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(experience == null ? 'Add Experience' : 'Edit Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    hintText: 'e.g., General Dentist',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company/Clinic',
                    hintText: 'e.g., Smile Dental Clinic',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startYearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Start Year',
                    hintText: 'e.g., 2018',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isCurrentJob,
                      onChanged: (value) {
                        setState(() {
                          isCurrentJob = value ?? false;
                        });
                      },
                    ),
                    const Text('Current Position'),
                  ],
                ),
                if (!isCurrentJob) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: endYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'End Year',
                      hintText: 'e.g., 2020',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Brief description of your role...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newExperience = {
                  'position': positionController.text.trim(),
                  'company': companyController.text.trim(),
                  'startYear': int.tryParse(startYearController.text.trim()),
                  'endYear': isCurrentJob ? null : int.tryParse(endYearController.text.trim()),
                  'isCurrent': isCurrentJob,
                  'description': descriptionController.text.trim(),
                };

                if ((newExperience['position'] as String).isNotEmpty && 
                    (newExperience['company'] as String).isNotEmpty) {
                  this.setState(() {
                    if (index != null) {
                      _experienceList[index] = newExperience;
                    } else {
                      _experienceList.add(newExperience);
                    }
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in position and company'),
                    ),
                  );
                }
              },
              child: Text(experience == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEducation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Education'),
        content: const Text('Are you sure you want to delete this education entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _educationList.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteExperience(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Experience'),
        content: const Text('Are you sure you want to delete this experience entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _experienceList.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;
      if (user == null) return;

      final updatedUser = user.copyWith(
        education: _educationList,
        experience: _experienceList,
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .update(updatedUser.toMap());

      authProvider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Education and experience updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
} 