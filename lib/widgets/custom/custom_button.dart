import '../../exports.dart';

enum CustomButtonType {
  primary,
  secondary,
  alert,
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonType = CustomButtonType.primary,
    this.icon,
  });

  final String text;
  final VoidCallback onPressed;
  final CustomButtonType buttonType;
  final IconData? icon;

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (buttonType) {
      case CustomButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      case CustomButtonType.secondary:
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
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (buttonType) {
      case CustomButtonType.primary:
        return Colors.black;
      case CustomButtonType.secondary:
      case CustomButtonType.alert:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
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
