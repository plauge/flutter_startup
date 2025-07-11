import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomCodeValidation extends StatelessWidget {
  final String content;
  final bool valid;

  const CustomCodeValidation({
    super.key,
    required this.content,
    required this.valid,
  });

  @override
  Widget build(BuildContext context) {
    final Color validationColor = valid
        ? const Color(0xFF0E5D4A) // Green
        : const Color(0xFFC42121); // Red

    final String iconPath = valid ? 'assets/icons/phone/check_circle.svg' : 'assets/icons/phone/cancel_circle.svg';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First column - Text with background color
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            child: Center(
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF014459),
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          // Second column - SVG with validation color background
          Container(
            decoration: BoxDecoration(
              color: validationColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// File created: 2024-12-28 at 18:30
