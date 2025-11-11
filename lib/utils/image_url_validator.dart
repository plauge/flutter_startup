/// Utility functions for validating image URLs
class ImageUrlValidator {
  /// Check if a profile image URL is valid for use with NetworkImage
  /// Returns true if URL is valid, false otherwise
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    // Check for invalid file:// URLs
    if (url.startsWith('file://')) {
      // Check if it's just "file:///" or similar invalid patterns
      if (url == 'file:///' || url.length <= 10 || !url.contains('/') || url.endsWith('//')) {
        return false;
      }
    }

    // Check if URL starts with http:// or https://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }

    return true;
  }
}

// Created: 2025-01-15 15:00:00
