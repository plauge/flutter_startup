import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: AppTheme.getPrimaryButtonStyle(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Text(
          text,
          style: AppTheme.getBottonMedium(context),
        ),
      ),
    );
  }
}
