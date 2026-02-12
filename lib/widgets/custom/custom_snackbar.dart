import '../../exports.dart';

enum CustomSnackBarVariant {
  success,
  error,
  info,
}

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String text,
    CustomTextType type = CustomTextType.info,
    CustomSnackBarVariant? variant,
    Color? backgroundColor,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    Color resolvedBackgroundColor;
    if (backgroundColor != null) {
      resolvedBackgroundColor = backgroundColor;
    } else if (variant != null) {
      switch (variant) {
        case CustomSnackBarVariant.success:
          resolvedBackgroundColor = AppColors.success;
          break;
        case CustomSnackBarVariant.error:
          resolvedBackgroundColor = AppColors.errorColor(context);
          break;
        case CustomSnackBarVariant.info:
          resolvedBackgroundColor = Theme.of(context).primaryColor;
          break;
      }
    } else {
      resolvedBackgroundColor = Theme.of(context).primaryColor;
    }

    final Widget content;
    if (actionLabel != null && onActionPressed != null) {
      content = Row(
        children: [
          Expanded(
            child: CustomText(
              text: text,
              type: type,
            ),
          ),
          TextButton(
            key: const Key('snackbar_action_button'),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              onActionPressed();
            },
            child: Text(
              actionLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    } else {
      content = CustomText(
        text: text,
        type: type,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: resolvedBackgroundColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
