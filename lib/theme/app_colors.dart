import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color _lightPrimaryColor =
      Color(0xFF4CAF50); // Grøn - hovedfarve
  static const Color _lightSecondaryColor =
      Color(0xFF8BC34A); // Lysere grøn - komplementær
  static const Color _lightBackgroundColor = Color(0xFFF5F5F5); // Off-white
  static const Color _lightSurfaceColor = Color(0xFFE8F5E9); // Meget lys grøn
  static const Color _lightErrorColor = Color(0xFFE57373); // Blød rød
  static const Color _lightTextColor = Color(0xFF2E2E2E); // Mørkegrå
  static const Color _lightDisabledColor = Color(0xFFBDBDBD); // Mellemgrå

  // Dark Theme Colors
  static const Color _darkPrimaryColor =
      Color(0xFF2E7D32); // Mørkere grøn - hovedfarve
  static const Color _darkSecondaryColor = Color(0xFF558B2F); // Oliven grøn
  static const Color _darkBackgroundColor = Color(0xFF121212); // Mørk baggrund
  static const Color _darkSurfaceColor = Color(0xFF1E1E1E); // Lidt lysere mørk
  static const Color _darkErrorColor = Color(0xFFEF5350); // Rød
  static const Color _darkTextColor = Color(0xFFF5F5F5); // Off-white
  static const Color _darkDisabledColor = Color(0xFF757575); // Mørkegrå

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
