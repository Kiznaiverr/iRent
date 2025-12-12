import 'package:flutter/material.dart';

/// App color constants used throughout the application
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6B9FE8);
  static const Color secondary = Color(0xFF8AB4F8);

  // Background colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);

  // Status colors
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF50);

  // Alpha variants
  static Color primaryWithAlpha(double alpha) =>
      primary.withValues(alpha: alpha);
  static Color secondaryWithAlpha(double alpha) =>
      secondary.withValues(alpha: alpha);
  static Color textPrimaryWithAlpha(double alpha) =>
      textPrimary.withValues(alpha: alpha);
  static Color warningWithAlpha(double alpha) =>
      warning.withValues(alpha: alpha);
}
