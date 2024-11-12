import 'package:flutter/material.dart';
import 'app_dimensions_theme.dart';

class AppTheme {
  static const mobileWidth = 600;
  static const tabletWidth = 1200;

  // Responsive Text Styles
  static TextStyle getHeadingLarge(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    double fontSize = width < mobileWidth
        ? 14 // Mobile
        : width < tabletWidth
            ? 32 // Tablet
            : 60; // Desktop

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      letterSpacing: -1.0,
      color: Colors.white,
    );
  }

  static TextStyle getHeadingMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    double fontSize = width < mobileWidth
        ? 20 // Mobile
        : width < tabletWidth
            ? 24 // Tablet
            : 28; // Desktop

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    );
  }

  static TextStyle getBodyLarge(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    double fontSize = width < mobileWidth
        ? 14 // Mobile
        : width < tabletWidth
            ? 16 // Tablet
            : 18; // Desktop

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.15,
    );
  }

  static TextStyle getBodyMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    double fontSize = width < mobileWidth
        ? 18 // Mobile
        : width < tabletWidth
            ? 22 // Tablet
            : 25; // Desktop

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.white,
    );
  }

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      extensions: [
        AppDimensionsTheme.standard,
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      extensions: [
        AppDimensionsTheme.standard,
      ],
    );
  }

  // Bemærk: TextTheme skal nu også bruge BuildContext
  static TextTheme getTextTheme(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return TextTheme(
      displayLarge: getHeadingLarge(context),
      displayMedium: TextStyle(
        fontSize: width < mobileWidth
            ? 36 // Mobile
            : width < tabletWidth
                ? 44 // Tablet
                : 52, // Desktop
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: getBodyLarge(context),
      bodyMedium: getBodyMedium(context),
    );
  }
}
