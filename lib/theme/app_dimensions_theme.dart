import 'package:flutter/material.dart';

// En simplere version af app dimensioner
class AppDimensionsTheme extends ThemeExtension<AppDimensionsTheme> {
  // Padding og margin værdier
  final double small;
  final double medium;
  final double large;

  // Constants for responsive breakpoints
  static const double mobileWidth = 600;
  static const double tabletWidth = 1200;
  static const double smallScreenHeight = 800.0;

  const AppDimensionsTheme({
    required this.small,
    required this.medium,
    required this.large,
  });

  // Standard størrelser som bruges i appen
  // Disse værdier bruges ikke af getSmall(), getMedium() eller getLarge()
  // da de har deres egne hardcodede værdier
  static const AppDimensionsTheme standard = AppDimensionsTheme(
    small: 8.0,
    medium: 16.0,
    large: 32.0,
  );

  // Helper method to easily get dimensions from context
  // Denne metode bruges ikke af getSmall(), da getSmall() bruger MediaQuery direkte
  static AppDimensionsTheme of(BuildContext context) {
    return Theme.of(context).extension<AppDimensionsTheme>() ?? standard;
  }

  @override
  ThemeExtension<AppDimensionsTheme> copyWith({
    double? small,
    double? medium,
    double? large,
  }) {
    return AppDimensionsTheme(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  @override
  ThemeExtension<AppDimensionsTheme> lerp(
    covariant ThemeExtension<AppDimensionsTheme>? other,
    double t,
  ) {
    if (other is! AppDimensionsTheme) return this;

    return AppDimensionsTheme(
      small: small + (other.small - small) * t,
      medium: medium + (other.medium - medium) * t,
      large: large + (other.large - large) * t,
    );
  }

  // Tilføj disse statiske metoder til at få responsive værdier
  static double getSmall(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return width < mobileWidth
        ? 4.0 // Mobile
        : width < tabletWidth
            ? 8.0 // Tablet
            : 12.0; // Desktop
  }

  static double getMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return width < mobileWidth
        ? 8.0 // Mobile
        : width < tabletWidth
            ? 30.0 // Tablet
            : 54.0; // Desktop
  }

  static double getParentContainerPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return width < mobileWidth
        ? 20.0 // Mobile
        : width < tabletWidth
            ? 20.0 // Tablet
            : 30.0; // Desktop
  }

  static double getLarge(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return width < mobileWidth
        ? 16.0 // Mobile
        : width < tabletWidth
            ? 32.0 // Tablet
            : 48.0; // Desktop
  }

  // Opdater standard konstruktøren til at bruge context
  static AppDimensionsTheme getResponsive(BuildContext context) {
    return AppDimensionsTheme(
      small: getSmall(context),
      medium: getMedium(context),
      large: getLarge(context),
    );
  }

  // Helper method to check if screen is small (e.g., iPhone SE & Mini series)
  static bool isSmallScreen(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return height < smallScreenHeight;
  }

  // Get responsive profile image radius based on screen height
  // Returns 60.0 for small screens (< 800px height), 90.0 for larger screens
  static double getProfileImageRadius(BuildContext context) {
    return isSmallScreen(context) ? 60.0 : 90.0;
  }
}
