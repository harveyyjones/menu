import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryBackground = Color(0xFFF5F5F5);
  static const Color secondaryBackground = Colors.white;
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Colors.black54;
  
  // Accent Color
  static const Color accent = Color(0xFFE65100); // Red accent color
  
  // UI Element Colors
  static const Color cardBackground = Colors.white;
  static const Color divider = Colors.black12;
  static const Color disabledBackground = Colors.black12;
  static const Color border = Color(0xFFE0E0E0);
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: primaryText,
  );
  
  static const TextStyle priceStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: accent,
  );
}
