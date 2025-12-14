import '../../exports.dart';
import 'package:showcaseview/showcaseview.dart';

/// Helper to create custom showcase buttons styled like CustomButtonType.primary but 25% smaller
class ShowcaseButtonHelper {
  /// Creates a custom TooltipActionButton styled like CustomButtonType.primary but 25% smaller
  static TooltipActionButton createPrimaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return TooltipActionButton.custom(
      button: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF005272), // Same as CustomButtonType.primary
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12, // Reduced horizontal padding for smaller button
            vertical: 11.25, // 15 * 0.75 = 11.25 (25% smaller)
          ),
          minimumSize: const Size(0, 0), // Remove default minimum size
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12, // 16 * 0.75 = 12 (25% smaller)
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// Created on 2025-12-14 at 07:00:00
