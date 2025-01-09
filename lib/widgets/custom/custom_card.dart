import 'package:flutter/material.dart';
import '../../exports.dart';

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String headerText;
  final String bodyText;
  final VoidCallback onPressed;
  final bool showArrow;
  final bool isAlert;
  final bool enableTapAnimation;

  const CustomCard({
    super.key,
    required this.icon,
    required this.headerText,
    required this.bodyText,
    required this.onPressed,
    this.showArrow = false,
    this.isAlert = false,
    this.enableTapAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      constraints: const BoxConstraints(minWidth: 50),
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDFDFDF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isAlert ? const Color(0xFFC42121) : Colors.black,
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
                      fontSize: 10,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
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
                child: Icon(Icons.arrow_forward_ios, size: 20),
              ),
            ],
          ],
        ),
      ),
    );

    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(20),
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
