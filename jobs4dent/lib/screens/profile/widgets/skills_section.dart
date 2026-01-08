import 'package:flutter/material.dart';

class SkillsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> availableSkills;
  final List<String> selectedSkills;
  final Function(String, bool) onSkillToggle;
  final IconData icon;
  final Color? iconColor;

  const SkillsSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.availableSkills,
    required this.selectedSkills,
    required this.onSkillToggle,
    required this.icon,
    this.iconColor,
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
                icon,
                color: iconColor ?? Colors.green[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableSkills.map((skill) {
              final isSelected = selectedSkills.contains(skill);
              return FilterChip(
                label: Text(
                  skill,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) => onSkillToggle(skill, selected),
                selectedColor: iconColor ?? Colors.green[600],
                backgroundColor: Colors.grey[100],
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
} 