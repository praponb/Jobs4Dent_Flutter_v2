import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../providers/job_constants.dart';

/// Reusable form widgets for job posting screen
class JobPostingFormWidgets {
  
  /// Build a section header with styled text
  static Widget buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  /// Build a multi-select field using multi_select_flutter package
  static Widget buildMultiSelectField(
    BuildContext context,
    String title,
    List<String> items,
    List<String> selectedValues,
    Function(List<String>) onConfirm,
  ) {
    return MultiSelectDialogField(
      items: items.map((item) => MultiSelectItem(item, item)).toList(),
      title: Text(title),
      selectedColor: Theme.of(context).primaryColor,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      buttonIcon: const Icon(Icons.arrow_drop_down),
      buttonText: Text(
        selectedValues.isEmpty 
            ? 'เลือก$title' 
            : 'เลือก ${selectedValues.length} รายการ',
      ),
      onConfirm: onConfirm,
      initialValue: selectedValues,
    );
  }

  /// Build a select field modal - the requested function
  /// Opens a modal bottom sheet for selecting multiple values from a list
  static Widget buildSelectFieldModal(
    BuildContext context,
    String title,
    List<String> items,
    List<String> selectedValues,
    Function(List<String>) onConfirm,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        title: Text(
          selectedValues.isEmpty 
              ? 'เลือก$title' 
              : '${selectedValues.join(", ")}',
          style: TextStyle(
            color: selectedValues.isEmpty ? Colors.grey[600] : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: () => _showSelectModal(context, title, items, selectedValues, onConfirm),
      ),
    );
  }

  /// Show the modal bottom sheet for selection
  static void _showSelectModal(
    BuildContext context,
    String title,
    List<String> items,
    List<String> selectedValues,
    Function(List<String>) onConfirm,
  ) {
    List<String> tempSelectedValues = List.from(selectedValues);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'เลือก$title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // Select/Deselect All buttons
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempSelectedValues = List.from(items);
                          });
                        },
                        child: const Text('เลือกทั้งหมด'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempSelectedValues.clear();
                          });
                        },
                        child: const Text('ยกเลิกทั้งหมด'),
                      ),
                    ],
                  ),
                  
                  // Items list
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = tempSelectedValues.contains(item);
                        
                        return CheckboxListTile(
                          title: Text(item),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (!tempSelectedValues.contains(item)) {
                                  tempSelectedValues.add(item);
                                }
                              } else {
                                tempSelectedValues.remove(item);
                              }
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                        );
                      },
                    ),
                  ),
                  
                  // Action buttons
                  const SizedBox(height: 16),
                  Row(
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
                          onPressed: () {
                            onConfirm(tempSelectedValues);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('ยืนยัน'),
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
  }

  /// Build a dropdown field for categories
  static Widget buildDropdownField<T>(
    String labelText,
    T value,
    List<T> items,
    ValueChanged<T?> onChanged, {
    String? Function(T?)? validator,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item.toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  /// Build a text form field with standard styling
  static Widget buildTextFormField(
    TextEditingController controller,
    String labelText, {
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  /// Build the job category dropdown
  static Widget buildJobCategoryDropdown(
    String selectedCategory,
    ValueChanged<String?> onChanged,
  ) {
    return buildDropdownField<String>(
      'หมวดหมู่งาน',
      selectedCategory,
      JobConstants.jobCategories,
      onChanged,
      isRequired: true,
    );
  }

  /// Build the experience level dropdown
  static Widget buildExperienceLevelDropdown(
    String selectedLevel,
    ValueChanged<String?> onChanged,
  ) {
    return buildDropdownField<String>(
      'ประสบการณ์(กี่ปี)',
      selectedLevel,
      JobConstants.experienceLevels,
      onChanged,
      isRequired: true,
    );
  }

  /// Build the salary type dropdown
  static Widget buildSalaryTypeDropdown(
    String selectedType,
    ValueChanged<String?> onChanged,
  ) {
    return buildDropdownField<String>(
      'อัตราส่วนรายได้ (Doctor Fee)',
      selectedType,
      JobConstants.salaryTypes,
      onChanged,
      isRequired: true,
    );
  }

  /// Build a loading button
  static Widget buildLoadingButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String text,
    double? width,
    double height = 50,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  /// Build standard validators
  static String? requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'ต้องระบุ$fieldName';
    }
    return null;
  }

  static String? numberValidator(String? value, {bool allowEmpty = true}) {
    if (allowEmpty && (value == null || value.trim().isEmpty)) {
      return null;
    }
    if (value != null && value.isNotEmpty) {
      if (double.tryParse(value) == null) {
        return 'กรุณาใส่ตัวเลขที่ถูกต้อง';
      }
    }
    return null;
  }
} 