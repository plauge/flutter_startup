import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_dimensions_theme.dart';
import 'app_colors.dart';

class AppTheme {
  static const mobileWidth = 600;
  static const tabletWidth = 1200;

  // Responsive Text Styles
  static TextStyle getHeadingLarge(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    double fontSize = width < mobileWidth
        ? 30 // Mobile
        : width < tabletWidth
            ? 32 // Tablet
            : 60; // Desktop

    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      letterSpacing: -1.0,
    );
  }

  // Responsive Text Styles
  static TextStyle getButtonText(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    double fontSize = width < mobileWidth
        ? 22 // Mobile
        : width < tabletWidth
            ? 32 // Tablet
            : 60; // Desktop

    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      letterSpacing: -1.0,
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

  static TextStyle getBottonMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    double fontSize = width < mobileWidth
        ? 16 // Mobile
        : width < tabletWidth
            ? 24 // Tablet
            : 28; // Desktop

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
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
        ? 20 // Mobile
        : width < tabletWidth
            ? 22 // Tablet
            : 25; // Desktop

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.black,
    );
  }

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFE5E5E5),
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
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFE5E5E5),
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

  static InputDecoration getTextFieldDecoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: AppColors.primaryColor(context),
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: AppColors.primaryColor(context).withOpacity(0.5),
          width: 2.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: AppColors.primaryColor(context),
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 2.0,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensionsTheme.getMedium(context),
        vertical: AppDimensionsTheme.getSmall(context),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      labelStyle: getBodyMedium(context).copyWith(
        color: AppColors.primaryColor(context),
      ),
    );
  }

  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.errorColor(context),
      foregroundColor: Colors.white,
      padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
    );
  }

  static BoxDecoration getParentContainerDecoration(BuildContext context, {bool transparent = false}) {
    final Map<String, Color> colorMap = {};
    if (transparent) {
      colorMap['color'] = const Color(0xFF005272).withAlpha(191);
    } else {
      colorMap['color'] = const Color(0xFFE5E5E5);
    }

    return BoxDecoration(
      color: colorMap['color'],
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static ContainerStyle getParentContainerStyle(BuildContext context, {bool transparent = false}) {
    return ContainerStyle(
      padding: EdgeInsets.only(
        top: AppDimensionsTheme.getParentContainerPadding(context),
        left: AppDimensionsTheme.getParentContainerPadding(context),
        right: AppDimensionsTheme.getParentContainerPadding(context),
        bottom: AppDimensionsTheme.getParentContainerPadding(context),
      ),
      width: double.infinity,
      decoration: getParentContainerDecoration(context, transparent: transparent),
      alignment: Alignment.topCenter,
      constraints: const BoxConstraints(
        maxWidth: 1200, // Max width for desktop
        minHeight: 100,
      ),
    );
  }
}

class ContainerStyle {
  final EdgeInsetsGeometry padding;
  final double? width;
  final BoxDecoration? decoration;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;

  const ContainerStyle({
    required this.padding,
    this.width,
    this.decoration,
    this.alignment,
    this.constraints,
  });

  // Helper method to apply style to a Container
  Container applyToContainer({required Widget child}) {
    return Container(
      padding: padding,
      width: width,
      decoration: decoration,
      alignment: alignment,
      constraints: constraints,
      child: child,
    );
  }
}
