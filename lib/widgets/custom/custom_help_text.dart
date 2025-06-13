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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF005272), width: 1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomText(
        text: text,
        type: type,
        alignment: alignment,
      ),
    );
  }
}

// File created: 2024-12-28 at 15:45
