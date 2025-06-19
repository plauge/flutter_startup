abstract class NavigationStateConstants {
  const NavigationStateConstants._();

  // Storage for the route path before PIN code validation
  static String? _previousRoutePath;

  /// Save the current route path before navigating to PIN code screen
  static void savePreviousRoute(String routePath) {
    _previousRoutePath = routePath;
  }

  /// Get the saved route path and clear it
  static String? getPreviousRouteAndClear() {
    final savedRoute = _previousRoutePath;
    _previousRoutePath = null;
    return savedRoute;
  }

  /// Get the saved route path without clearing it
  static String? getPreviousRoute() {
    return _previousRoutePath;
  }

  /// Clear the saved route path
  static void clearPreviousRoute() {
    _previousRoutePath = null;
  }
}

// Created on: 2024-12-24 18:00
