import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color _lightPrimaryColor =
      Color.fromARGB(255, 33, 243, 110); // Blue
  static const Color _lightSecondaryColor =
      Color.fromARGB(255, 3, 17, 218); // Teal
  static const Color _lightBackgroundColor = Color(0xFFFFFFFF); // White
  static const Color _lightSurfaceColor = Color(0xFFF5F5F5); // Light Grey
  static const Color _lightErrorColor = Color(0xFFB00020); // Red
  static const Color _lightTextColor = Color(0xFF000000); // Black
  static const Color _lightDisabledColor = Color(0xFF9E9E9E); // Grey

  // Dark Theme Colors
  //static const Color _darkPrimaryColor = Color(0xFF90CAF9); // Light Blue
  static const Color _darkPrimaryColor =
      Color.fromARGB(255, 3, 17, 218); // Light Blue
  static const Color _darkSecondaryColor = Color(0xFF018786); // Dark Teal
  static const Color _darkBackgroundColor = Color(0xFF121212); // Dark Grey
  static const Color _darkSurfaceColor =
      Color(0xFF1E1E1E); // Slightly lighter Dark
  static const Color _darkErrorColor = Color(0xFFCF6679); // Pink
  static const Color _darkTextColor = Color(0xFFFFFFFF); // White
  static const Color _darkDisabledColor = Color(0xFF6E6E6E); // Dark Grey

  // Helper functions to get the right color based on theme
  static Color primaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkPrimaryColor
        : _lightPrimaryColor;
  }

  static Color secondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkSecondaryColor
        : _lightSecondaryColor;
  }

  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBackgroundColor
        : _lightBackgroundColor;
  }

  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkSurfaceColor
        : _lightSurfaceColor;
  }

  static Color errorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkErrorColor
        : _lightErrorColor;
  }

  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkTextColor
        : _lightTextColor;
  }

  static Color disabledColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkDisabledColor
        : _lightDisabledColor;
  }

  // Opacity variants for primary color
  static Color primaryWithOpacity(BuildContext context, double opacity) {
    return primaryColor(context).withOpacity(opacity);
  }

  // Gradient colors
  static List<Color> primaryGradient(BuildContext context) {
    return [
      primaryColor(context),
      secondaryColor(context),
    ];
  }

  // Common colors (same in both themes)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
}