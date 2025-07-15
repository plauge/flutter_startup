abstract class ContactsTabStateConstants {
  const ContactsTabStateConstants._();

  static int _lastActiveTabIndex = 0;

  /// Get the last active tab index
  static int getLastActiveTabIndex() {
    return _lastActiveTabIndex;
  }

  /// Set the last active tab index
  static void setLastActiveTabIndex(int index) {
    _lastActiveTabIndex = index;
  }

  /// Reset to first tab
  static void resetToFirstTab() {
    _lastActiveTabIndex = 0;
  }
}

// Created on: 2025-01-27 16:15
