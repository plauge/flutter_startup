import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ValidationState {
  valid,
  invalid,
  waiting,
}

class CustomCodeValidation extends StatelessWidget {
  final String content;
  final ValidationState state;

  const CustomCodeValidation({
    super.key,
    required this.content,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color validationColor;
    String iconPath;

    switch (state) {
      case ValidationState.valid:
        validationColor = const Color(0xFF0E5D4A); // Green
        iconPath = 'assets/icons/contact/confirm_icon.svg';
        break;
      case ValidationState.invalid:
        validationColor = const Color(0xFFC42121); // Red
        iconPath = 'assets/icons/contact/invalid_icon.svg';
        break;
      case ValidationState.waiting:
        validationColor = const Color(0xFFDFDFDF); // Gray
        iconPath = 'assets/icons/contact/waiting_icon.svg'; // Same as valid for now
        break;
    }

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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// File created: 2024-12-28 at 18:30
