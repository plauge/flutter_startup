import 'package:flutter/material.dart';
import '../../exports.dart';

enum CardBackgroundColor {
  green,
  lightBlue,
  orange,
  blue,
  lightGreen,
  gray,
  lightOrange,
}

extension CardBackgroundColorExtension on CardBackgroundColor {
  Color toColor() {
    switch (this) {
      case CardBackgroundColor.green:
        return const Color(0xFF1A576A);
      case CardBackgroundColor.lightBlue:
        return const Color(0xFF6CA5D2);
      case CardBackgroundColor.orange:
        return const Color(0xFFE59D4B);
      case CardBackgroundColor.blue:
        return const Color(0xFF4676EF);
      case CardBackgroundColor.lightGreen:
        return const Color(0xFF7DC271);
      case CardBackgroundColor.gray:
        return const Color(0xFF656565);
      case CardBackgroundColor.lightOrange:
        return const Color(0xFFEA7A18);
    }
  }
}

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String headerText;
  final String bodyText;
  final VoidCallback onPressed;
  final bool showArrow;
  final bool isAlert;
  final bool enableTapAnimation;
  final CardBackgroundColor backgroundColor;

  const CustomCard({
    super.key,
    required this.icon,
    required this.headerText,
    required this.bodyText,
    required this.onPressed,
    this.showArrow = false,
    this.isAlert = false,
    this.enableTapAnimation = true,
    this.backgroundColor = CardBackgroundColor.green,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      constraints: const BoxConstraints(minWidth: 50),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor.toColor(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isAlert ? const Color(0xFFC42121) : Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      color: isAlert ? const Color(0xFFC42121) : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    bodyText,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.2,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF656565),
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 10),
              const SizedBox(
                width: 20,
                child: Icon(Icons.arrow_forward_ios, size: 13),
              ),
            ],
          ],
        ),
      ),
    );

    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
      child: enableTapAnimation
          ? InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(20),
              child: cardWidget,
            )
          : GestureDetector(
              onTap: onPressed,
              child: cardWidget,
            ),
    );
  }
}
