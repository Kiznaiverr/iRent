import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';

/// A container with gradient background for icons
class GradientIconContainer extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final double padding;

  const GradientIconContainer({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize = 24,
    this.padding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryWithAlpha(0.15),
            AppColors.secondaryWithAlpha(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(
          size * 0.2,
        ), // Responsive border radius
      ),
      child: Icon(icon, color: AppColors.primary, size: iconSize),
    );
  }
}
