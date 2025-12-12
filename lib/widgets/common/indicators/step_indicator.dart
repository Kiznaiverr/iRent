import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';

/// A step indicator widget for multi-step processes
class StepIndicator extends StatelessWidget {
  final int stepNumber;
  final String label;
  final bool isActive;
  final bool isCompleted;
  final double size;

  const StepIndicator({
    super.key,
    required this.stepNumber,
    required this.label,
    this.isActive = false,
    this.isCompleted = false,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = isActive || isCompleted;

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isHighlighted
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  )
                : null,
            color: isHighlighted ? null : Colors.grey[300],
            border: isHighlighted
                ? null
                : Border.all(color: Colors.grey[400]!, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: size * 0.5,
                  )
                : Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      color: isHighlighted ? Colors.white : Colors.grey[600],
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isHighlighted ? AppColors.primary : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
