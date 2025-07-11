import '../../exports.dart';

class CustomHelpText extends StatelessWidget {
  final String text;
  final CustomTextType type;
  final CustomTextAlignment alignment;

  const CustomHelpText({
    super.key,
    required this.text,
    this.type = CustomTextType.label,
    this.alignment = CustomTextAlignment.left,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF014459),
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 15:45
