import 'package:flutter/material.dart';
import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

enum CardIcon {
  camera,
  connectOnline,
  contacts,
  dots,
  email,
  meetInPerson,
  myProfile,
  phone,
  qrCode,
  textMessage,
  trash,
  security,
}

extension CardIconExtension on CardIcon {
  String get path {
    switch (this) {
      case CardIcon.camera:
        return 'assets/icons/custom_card/camera.svg';
      case CardIcon.connectOnline:
        return 'assets/icons/custom_card/connect_online.svg';
      case CardIcon.contacts:
        return 'assets/icons/custom_card/contacts.svg';
      case CardIcon.dots:
        return 'assets/icons/custom_card/dots.svg';
      case CardIcon.email:
        return 'assets/icons/custom_card/email.svg';
      case CardIcon.meetInPerson:
        return 'assets/icons/custom_card/meet_in_person.svg';
      case CardIcon.myProfile:
        return 'assets/icons/custom_card/my_profile.svg';
      case CardIcon.phone:
        return 'assets/icons/custom_card/phone.svg';
      case CardIcon.qrCode:
        return 'assets/icons/custom_card/qr_code.svg';
      case CardIcon.textMessage:
        return 'assets/icons/custom_card/text_message.svg';
      case CardIcon.trash:
        return 'assets/icons/custom_card/trash.svg';
      case CardIcon.security:
        return 'assets/icons/custom_card/security_key.svg';
    }
  }
}

class CustomCard extends StatelessWidget {
  final CardIcon icon;
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
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Center(
                child: SvgPicture.asset(
                  icon.path,
                  fit: BoxFit.contain,
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
