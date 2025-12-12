import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App text style constants used throughout the application
class AppTextStyles {
  // Headlines
  static TextStyle get headlineLarge => GoogleFonts.manrope(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
    color: Colors.white,
  );

  static TextStyle get headlineMedium => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );

  static TextStyle get headlineSmall => GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  // Body text
  static TextStyle get bodyLarge => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade600,
  );

  static TextStyle get bodyMedium => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static TextStyle get bodySmall => GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade500,
  );

  // Button text
  static TextStyle get button => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Label text
  static TextStyle get labelLarge => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  // Custom styles for specific use cases
  static TextStyle get appBarTitle => GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get cardTitle => GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get priceText => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );

  static TextStyle get hintText => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade500,
  );
}
