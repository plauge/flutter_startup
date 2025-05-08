import 'package:flutter/material.dart';
import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CardBatchBackgroundColor {
  green,
  lightBlue,
  orange,
  blue,
  lightGreen,
  gray,
  lightOrange,
}

extension CardBatchBackgroundColorExtension on CardBatchBackgroundColor {
  Color toColor() {
    switch (this) {
      case CardBatchBackgroundColor.green:
        return const Color(0xFF1A576A);
      case CardBatchBackgroundColor.lightBlue:
        return const Color(0xFF6CA5D2);
      case CardBatchBackgroundColor.orange:
        return const Color(0xFFE59D4B);
      case CardBatchBackgroundColor.blue:
        return const Color(0xFF4676EF);
      case CardBatchBackgroundColor.lightGreen:
        return const Color(0xFF7DC271);
      case CardBatchBackgroundColor.gray:
        return const Color(0xFF656565);
      case CardBatchBackgroundColor.lightOrange:
        return const Color(0xFFEA7A18).withAlpha(128);
    }
  }
}

enum CardBatchIcon {
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
}

extension CardBatchIconExtension on CardBatchIcon {
  String get path {
    switch (this) {
      case CardBatchIcon.camera:
        return 'assets/icons/custom_card/camera.svg';
      case CardBatchIcon.connectOnline:
        return 'assets/icons/custom_card/connect_online.svg';
      case CardBatchIcon.contacts:
        return 'assets/icons/custom_card/contacts.svg';
      case CardBatchIcon.dots:
        return 'assets/icons/custom_card/dots.svg';
      case CardBatchIcon.email:
        return 'assets/icons/custom_card/email.svg';
      case CardBatchIcon.meetInPerson:
        return 'assets/icons/custom_card/meet_in_person.svg';
      case CardBatchIcon.myProfile:
        return 'assets/icons/custom_card/my_profile.svg';
      case CardBatchIcon.phone:
        return 'assets/icons/custom_card/phone.svg';
      case CardBatchIcon.qrCode:
        return 'assets/icons/custom_card/qr_code.svg';
      case CardBatchIcon.textMessage:
        return 'assets/icons/custom_card/text_message.svg';
      case CardBatchIcon.trash:
        return 'assets/icons/custom_card/trash.svg';
    }
  }
}

class CustomCardBatch extends StatelessWidget {
  final CardBatchIcon icon;
  final String headerText;
  final String bodyText;
  final VoidCallback onPressed;
  final bool showArrow;
  final bool isAlert;
  final bool enableTapAnimation;
  final CardBatchBackgroundColor backgroundColor;
  final ImageProvider? image;
  final String level;

  const CustomCardBatch({
    super.key,
    required this.icon,
    required this.headerText,
    required this.bodyText,
    required this.onPressed,
    this.showArrow = false,
    this.isAlert = false,
    this.enableTapAnimation = true,
    this.backgroundColor = CardBatchBackgroundColor.green,
    this.image,
    required this.level,
  });

  Level _convertToLevel(String levelStr) {
    switch (levelStr) {
      case '1':
        return Level.level_1;
      case '2':
        return Level.level_2;
      case '3':
        return Level.level_3;
      default:
        return Level.level_1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      constraints: const BoxConstraints(minWidth: 50),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (image != null) ...[
              Container(
                width: 58,
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Container(
                      width: 55,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        image: DecorationImage(
                          image: image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white,
                    ),
                    CustomLevelLabel(level: _convertToLevel(level)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              Container(
                width: 58,
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Container(
                      width: 55,
                      height: 50,
                      decoration: BoxDecoration(
                        color: backgroundColor.toColor(),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          icon.path,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white,
                    ),
                    CustomLevelLabel(level: _convertToLevel(level)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
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
