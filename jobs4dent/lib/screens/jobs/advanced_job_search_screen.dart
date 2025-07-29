import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/job_constants.dart';
import '../../providers/auth_provider.dart';
import 'dentist_job_search_screen.dart';
import 'job_posting_form_widgets.dart';
import 'advanced_search_form_helper.dart';

class AdvancedJobSearchScreen extends StatefulWidget {
  const AdvancedJobSearchScreen({super.key});

  @override
  State<AdvancedJobSearchScreen> createState() => _AdvancedJobSearchScreenState();
}

class _AdvancedJobSearchScreenState extends State<AdvancedJobSearchScreen> {
  late final AdvancedSearchFormHelper _formHelper;

  @override
  void initState() {
    super.initState();
    _formHelper = AdvancedSearchFormHelper();
    _loadSavedSearchState();
  }

  void _loadSavedSearchState() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    _formHelper.loadSavedSearchState(jobProvider);
  }

  @override
  void dispose() {
    _formHelper.dispose();
    super.dispose();
  }

  void _searchJobs() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    _formHelper.saveStateAndSearch(jobProvider, authProvider.userModel?.userId);

    // Navigate to job search screen with results
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
                        builder: (context) => const DentistJobSearchScreen(),
      ),
    );
  }

  void _clearFilters() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    _formHelper.clearAllFilters(jobProvider, () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาขั้นสูง'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('ล้างทั้งหมด', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicSearchSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildJobCategorySection(),
            const SizedBox(height: 24),
            _buildSalarySection(),
            const SizedBox(height: 24),
            _buildWorkScheduleSection(),
            const SizedBox(height: 24),
            _buildDateFiltersSection(),
            const SizedBox(height: 24),
            _buildAdditionalRequirementsSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JobPostingFormWidgets.buildSectionTitle('ค้นหาทั่วไป'),
        const SizedBox(height: 8),
        TextField(
          controller: _formHelper.keywordController,
          decoration: const InputDecoration(
            labelText: 'ชื่อคลินิก หรือ อื่นๆ',
            hintText: 'ค้นหาชื่อคลินิก หรือคำอธิบายงาน...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JobPostingFormWidgets.buildSectionTitle('ที่ตั้งและการเดินทาง'),
        const SizedBox(height: 8),
        JobPostingFormWidgets.buildProvinceZoneDropdown(
          selectedIndex: _formHelper.selectedProvinceZoneIndex,
          onChanged: (value) => _formHelper.onProvinceZoneChanged(value, () => setState(() {})),
        ),
        const SizedBox(height: 16),
        JobPostingFormWidgets.buildLocationDropdown(
          selectedProvinceZoneIndex: _formHelper.selectedProvinceZoneIndex,
          selectedLocation: _formHelper.selectedLocation,
          onChanged: (value) => _formHelper.onLocationChanged(value, () => setState(() {})),
        ),
        const SizedBox(height: 16),
        JobPostingFormWidgets.buildTrainLineDropdown(
          selectedIndex: _formHelper.selectedTrainLineIndex,
          onChanged: (value) => _formHelper.onTrainLineChanged(value, () => setState(() {})),
        ),
        const SizedBox(height: 16),
        JobPostingFormWidgets.buildTrainStationDropdown(
          selectedTrainLineIndex: _formHelper.selectedTrainLineIndex,
          selectedStation: _formHelper.selectedTrainStation,
          onChanged: (value) => _formHelper.onTrainStationChanged(value, () => setState(() {})),
        ),
      ],
    );
  }

  Widget _buildJobCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JobPostingFormWidgets.buildSectionTitle('เลือกความถนัดเฉพาะทาง หรือ ระดับประสบการณ์'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _formHelper.selectedJobCategory,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'หมวดหมู่งาน',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('เลือกหมวดหมู่งาน'),
            ),
            ...JobConstants.jobCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _formHelper.selectedJobCategory = value;
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _formHelper.selectedExperienceLevel,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'ระดับประสบการณ์',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('เลือกระดับประสบการณ์'),
            ),
            ...JobConstants.experienceLevels.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(level),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _formHelper.selectedExperienceLevel = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSalarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JobPostingFormWidgets.buildSectionTitle('ประกันรายได้รายวัน หรือ เงินเดือน'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _formHelper.selectedSalaryType,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'ประเภทเงินเดือน',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('อัตราส่วนรายได้'),
            ),
            ...JobConstants.salaryTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _formHelper.selectedSalaryType = value;
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _formHelper.minSalaryController,
                decoration: const InputDecoration(
                  labelText: 'ประกันรายได้ขั้นต่ำ',
                  hintText: '2500',
                  border: OutlineInputBorder(),
                  suffixText: 'บาท',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _formHelper.maxSalaryController,
                decoration: const InputDecoration(
                  labelText: 'เงินเดือนขั้นต่ำ',
                  hintText: '25000',
                  border: OutlineInputBorder(),
                  suffixText: 'บาท',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JobPostingFormWidgets.buildSectionTitle('ตารางงานและเวลาทำงาน'),
        const SizedBox(height: 8),
        JobPostingFormWidgets.buildWorkingTypeSelection(
          selectedType: _formHelper.selectedWorkingType,
          onChanged: (value) {
            setState(() {
              _formHelper.selectedWorkingType = value;
            });
          },
        ),
        const SizedBox(height: 16),
        JobPostingFormWidgets.buildWorkingDaysSelection(
          selectedDays: _formHelper.selectedWorkingDays,
          onDayToggled: (day, selected) => _formHelper.onWorkingDayToggled(day, selected, () => setState(() {})),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _formHelper.workingHoursController,
          decoration: const InputDecoration(
            labelText: 'เลือกเวลาเริ่มงาน',
            hintText: 'เช่น 08:00 น.',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JobPostingFormWidgets.buildSectionTitle('ช่วงวันทำงาน'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _formHelper.selectDate(
                  context: context,
                  isStartDate: true,
                  setState: () => setState(() {}),
                ),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'วันที่เริ่มต้น',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _formHelper.startDate?.toString().split(' ')[0] ?? 'เลือกวันที่',
                    style: TextStyle(
                      color: _formHelper.startDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _formHelper.selectDate(
                  context: context,
                  isStartDate: false,
                  setState: () => setState(() {}),
                ),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'วันที่สิ้นสุด',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _formHelper.endDate?.toString().split(' ')[0] ?? 'เลือกวันที่',
                    style: TextStyle(
                      color: _formHelper.endDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JobPostingFormWidgets.buildSectionTitle('ข้อกำหนดเพิ่มเติม'),
        const SizedBox(height: 8),
        TextField(
          controller: _formHelper.additionalRequirementsController,
          decoration: const InputDecoration(
            labelText: 'ข้อกำหนดพิเศษ',
            hintText: 'เช่น ห้องพักแพทย์, ที่จอดรถ, wifi',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _searchJobs,
            child: const Text('ค้นหา'),
          ),
        ),
      ],
    );
  }
} 