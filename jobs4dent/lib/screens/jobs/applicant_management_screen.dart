import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_application_model.dart';

class ApplicantManagementScreen extends StatefulWidget {
  const ApplicantManagementScreen({super.key});

  @override
  State<ApplicantManagementScreen> createState() => _ApplicantManagementScreenState();
}

class _ApplicantManagementScreenState extends State<ApplicantManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadApplications() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    if (authProvider.userModel != null) {
      jobProvider.getApplicantsForMyJobs(authProvider.userModel!.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Applicants'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'New'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationsList(),
          _buildApplicationsList(statusFilter: 'new'),
          _buildApplicationsList(statusFilter: 'in_progress'),
          _buildApplicationsList(statusFilter: 'completed'),
        ],
      ),
    );
  }

  Widget _buildApplicationsList({String? statusFilter}) {
    return Consumer<JobProvider>(
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
                  'Error loading applications',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(jobProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadApplications,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<JobApplicationModel> applications = jobProvider.applicantsForMyJobs;

        // Apply status filter
        if (statusFilter == 'new') {
          applications = applications.where((app) => app.isPending).toList();
        } else if (statusFilter == 'in_progress') {
          applications = applications.where((app) => app.isInProgress).toList();
        } else if (statusFilter == 'completed') {
          applications = applications.where((app) => app.isCompleted).toList();
        }

        if (applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  statusFilter == null 
                      ? 'No applications yet'
                      : 'No ${statusFilter.replaceAll('_', ' ')} applications',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Applications will appear here when people apply for your jobs'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadApplications(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return _buildApplicationCard(application);
            },
          ),
        );
      },
    );
  }

  Widget _buildApplicationCard(JobApplicationModel application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showApplicationDetails(application),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with applicant name and status
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    backgroundImage: application.applicantProfilePhoto != null 
                        ? NetworkImage(application.applicantProfilePhoto!)
                        : null,
                    child: application.applicantProfilePhoto == null
                        ? Text(
                            application.applicantName.isNotEmpty 
                                ? application.applicantName[0].toUpperCase()
                                : 'A',
                            style: TextStyle(color: Colors.blue[700]),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.applicantName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.applicantEmail,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(application.status),
                ],
              ),
              const SizedBox(height: 12),

              // Application info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Applied: ${_formatDate(application.appliedAt)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  if (application.matchingScore != null) ...[
                    Icon(Icons.star, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${application.matchingScore!.round()}% match',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              // Phone number if available
              if (application.applicantPhone != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      application.applicantPhone!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],

              // Cover letter preview
              const SizedBox(height: 12),
              Text(
                'Cover Letter:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                application.coverLetter,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),

              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateStatusDialog(application),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Update Status'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApplicationDetails(application),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Details'),
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

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'submitted':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        break;
      case 'under_review':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        break;
      case 'shortlisted':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        break;
      case 'interview_scheduled':
        backgroundColor = Colors.indigo[100]!;
        textColor = Colors.indigo[700]!;
        break;
      case 'interview_completed':
        backgroundColor = Colors.teal[100]!;
        textColor = Colors.teal[700]!;
        break;
      case 'offered':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        break;
      case 'hired':
        backgroundColor = Colors.green[200]!;
        textColor = Colors.green[800]!;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'submitted':
        return 'New';
      case 'under_review':
        return 'Reviewing';
      case 'shortlisted':
        return 'Shortlisted';
      case 'interview_scheduled':
        return 'Interview';
      case 'interview_completed':
        return 'Interviewed';
      case 'offered':
        return 'Offered';
      case 'hired':
        return 'Hired';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showApplicationDetails(JobApplicationModel application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header with actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      application.applicantName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showUpdateStatusDialog(application);
                    },
                    child: const Text('Update Status'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Applicant profile information
                      if (application.applicantProfile != null) ...[
                        _buildSectionTitle('Applicant Profile'),
                        _buildProfileCard(application.applicantProfile!),
                        const SizedBox(height: 16),
                      ],

                      // Cover letter
                      _buildSectionTitle('Cover Letter'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(application.coverLetter),
                      ),
                      const SizedBox(height: 16),

                      // Additional documents
                      if (application.additionalDocuments.isNotEmpty) ...[
                        _buildSectionTitle('Additional Documents'),
                        ...application.additionalDocuments.map((doc) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.description),
                            title: Text(doc),
                            trailing: IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () {
                                // TODO: Implement document download
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Document download - Coming Soon')),
                                );
                              },
                            ),
                          ),
                        )),
                        const SizedBox(height: 16),
                      ],

                      // Application timeline
                      _buildSectionTitle('Application Timeline'),
                      _buildTimelineCard(application),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile['currentPosition'] != null)
              _buildProfileRow('Position', profile['currentPosition']),
            if (profile['yearsOfExperience'] != null)
              _buildProfileRow('Experience', '${profile['yearsOfExperience']} years'),
            if (profile['skills'] != null && (profile['skills'] as List).isNotEmpty)
              _buildProfileRow('Skills', (profile['skills'] as List).join(', ')),
            if (profile['specialties'] != null && (profile['specialties'] as List).isNotEmpty)
              _buildProfileRow('Specialties', (profile['specialties'] as List).join(', ')),
            if (profile['education'] != null && (profile['education'] as List).isNotEmpty)
              _buildProfileRow('Education', '${(profile['education'] as List).length} entries'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(JobApplicationModel application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimelineItem('Applied', application.appliedAt, true),
            _buildTimelineItem('Last Updated', application.updatedAt, false),
            if (application.interviewDate != null)
              _buildTimelineItem('Interview Scheduled', application.interviewDate!, false),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date, bool isFirst) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isFirst ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                _formatDate(date),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateStatusDialog(JobApplicationModel application) {
    String selectedStatus = application.status;
    final notesController = TextEditingController(text: application.notes ?? '');
    DateTime? interviewDate = application.interviewDate;
    final interviewLocationController = TextEditingController(text: application.interviewLocation ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Update Application Status'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Applicant: ${application.applicantName}'),
                const SizedBox(height: 16),
                
                // Status dropdown
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: JobProvider.applicationStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusDisplayName(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Interview fields (if interview status selected)
                if (selectedStatus == 'interview_scheduled') ...[
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: interviewDate ?? DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          interviewDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Interview Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        interviewDate != null 
                            ? _formatDate(interviewDate!)
                            : 'Select interview date',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: interviewLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Interview Location',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Clinic office, Video call',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes field
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Add any notes for the applicant...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _updateApplicationStatus(
                application.applicationId,
                selectedStatus,
                notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                interviewDate,
                interviewLocationController.text.trim().isEmpty ? null : interviewLocationController.text.trim(),
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateApplicationStatus(
    String applicationId,
    String newStatus,
    String? notes,
    DateTime? interviewDate,
    String? interviewLocation,
  ) async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    Navigator.pop(context); // Close dialog

    final success = await jobProvider.updateApplicationStatus(
      applicationId: applicationId,
      newStatus: newStatus,
      notes: notes,
      interviewDate: interviewDate,
      interviewLocation: interviewLocation,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application status updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jobProvider.error ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
