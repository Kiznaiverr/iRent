import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';

class DatePickerCard extends StatelessWidget {
  final String title;
  final String? selectedDate;
  final String placeholder;
  final VoidCallback onTap;
  final bool isEnabled;

  const DatePickerCard({
    super.key,
    required this.title,
    this.selectedDate,
    required this.placeholder,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEnabled
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: isEnabled ? AppColors.primary : Colors.grey[400],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? dateFormat.format(DateTime.parse(selectedDate!))
                          : placeholder,
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: isEnabled ? AppColors.primary : Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
