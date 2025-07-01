/// Utility function to flatten nested JSON structures into dot-notation key-value pairs.
///
/// Example:
/// Input: {"screen_home": {"welcome_message": "Welcome", "logout": "Log out"}}
/// Output: {"screen_home.welcome_message": "Welcome", "screen_home.logout": "Log out"}

/// Flattens a nested JSON structure into a flat map with dot-notation keys.
///
/// [json] The nested JSON structure to flatten
/// [prefix] The prefix to use for keys (used internally for recursion)
///
/// Returns a flat map where nested keys are joined with dots
Map<String, String> flatten(Map<String, dynamic> json, [String prefix = '']) {
  final Map<String, String> result = {};

  json.forEach((key, value) {
    final String newKey = prefix.isEmpty ? key : '$prefix.$key';

    if (value is Map<String, dynamic>) {
      // Recursively flatten nested objects
      result.addAll(flatten(value, newKey));
    } else {
      // Convert all values to strings
      result[newKey] = value.toString();
    }
  });

  return result;
}

// Created: 2024-12-30 at 10:00 AM
