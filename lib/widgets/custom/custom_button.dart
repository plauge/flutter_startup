import '../../exports.dart';

enum CustomButtonType {
  primary,
  secondary,
  alert,
  orange,
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonType = CustomButtonType.primary,
    this.icon,
    this.enabled = true,
  });

  final String text;
  final VoidCallback onPressed;
  final CustomButtonType buttonType;
  final IconData? icon;
  final bool enabled;

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (buttonType) {
      case CustomButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: Color(0xFF005272),
              width: 1,
            ),
          ),
        );
      case CustomButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF005272),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      case CustomButtonType.alert:
        return ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC42121),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      case CustomButtonType.orange:
        return ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800), // Orange
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (buttonType) {
      case CustomButtonType.secondary:
        return Colors.black;
      case CustomButtonType.primary:
        return Colors.white;
      case CustomButtonType.alert:
        return Colors.white;
      case CustomButtonType.orange:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: _getButtonStyle(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Gap(AppDimensionsTheme.getSmall(context)),
                Icon(icon, color: _getTextColor(context)),
                Gap(AppDimensionsTheme.getSmall(context)),
              ],
              Text(
                text,
                style: AppTheme.getBodyMedium(context).copyWith(
                  color: _getTextColor(context),
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
