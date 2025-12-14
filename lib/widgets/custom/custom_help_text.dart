import '../../exports.dart';

class CustomHelpText extends StatelessWidget {
  final String text;
  final CustomTextType type;
  final CustomTextAlignment alignment;
  final VoidCallback? onClose;

  const CustomHelpText({
    super.key,
    required this.text,
    this.type = CustomTextType.label,
    this.alignment = CustomTextAlignment.left,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF014459),
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (onClose != null)
            Positioned(
              top: -24,
              right: -20,
              child: GestureDetector(
                key: const Key('help_text_close_button'),
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF014459),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// File created: 2024-12-28 at 15:45
