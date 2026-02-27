import 'package:flutter/material.dart';

class SeverityOption {
  final String value;
  final String label;
  final String description;
  final Color color;
  final IconData icon;
  final double multiplier;

  const SeverityOption({
    required this.value,
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
    required this.multiplier,
  });
}

// Order: Normal → Emergency → Urgent (low to high multiplier matches backend)
const kSeverityOptions = [
  SeverityOption(
    value: 'normal',
    label: 'Normal',
    description: 'Standard scheduling',
    color: Color(0xFF22C55E),
    icon: Icons.schedule_rounded,
    multiplier: 1.0,
  ),
  SeverityOption(
    value: 'emergency',
    label: 'Emergency',
    description: 'Immediate response',
    color: Color(0xFFF59E0B),
    icon: Icons.flash_on_rounded,
    multiplier: 1.4,
  ),
  SeverityOption(
    value: 'urgent',
    label: 'Urgent',
    description: 'Priority handling',
    color: Color(0xFFEF4444),
    icon: Icons.priority_high_rounded,
    multiplier: 1.8,
  ),
];

class SeveritySelector extends StatelessWidget {
  final String selectedSeverity;
  final ValueChanged<String> onChanged;

  const SeveritySelector({
    super.key,
    required this.selectedSeverity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Urgency Level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(kSeverityOptions.length, (index) {
            final option = kSeverityOptions[index];
            final isSelected = selectedSeverity == option.value;
            final isLast = index == kSeverityOptions.length - 1;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: isLast ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? option.color.withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    // Use same border width always to prevent size shift
                    border: Border.all(
                      color: isSelected
                          ? option.color
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        option.icon,
                        color: isSelected
                            ? option.color
                            : const Color(0xFF9CA3AF),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? option.color
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'x${option.multiplier}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? option.color.withOpacity(0.8)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}