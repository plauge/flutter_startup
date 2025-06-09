import 'package:flutter/material.dart';
import '../../exports.dart';

class CustomSnackBar {
  static void show({required BuildContext context, required String text, required CustomTextType type, Color? backgroundColor, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(
          text: text,
          type: type,
        ),
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }
}
