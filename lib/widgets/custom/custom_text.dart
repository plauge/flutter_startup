import 'package:flutter/material.dart';

enum CustomTextType {
  top, // Poppins Bold 16
  head, // Poppins Bold 28
  bread, // Poppins Regular 16
  cardHead, // Poppins SemiBold 14
  cardDescription, // Poppins Regular 10
  button, // Poppins SemiBold 16
  info, // Poppins SemiBold 16
  label, // Poppins Medium 16
  placeholder, // Poppins Regular 16
  helper, // Poppins Bold 22
  helpBread, // Poppins Regular 14/22
}

enum CustomTextAlignment {
  left,
  center,
  right,
  justify,
  start,
  end,
}

class CustomText extends StatelessWidget {
  final String text;
  final CustomTextType type;
  final CustomTextAlignment alignment;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool selectable;

  const CustomText({
    super.key,
    required this.text,
    required this.type,
    this.alignment = CustomTextAlignment.left,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  });

  TextAlign _getTextAlign() {
    switch (alignment) {
      case CustomTextAlignment.left:
        return TextAlign.left;
      case CustomTextAlignment.center:
        return TextAlign.center;
      case CustomTextAlignment.right:
        return TextAlign.right;
      case CustomTextAlignment.justify:
        return TextAlign.justify;
      case CustomTextAlignment.start:
        return TextAlign.start;
      case CustomTextAlignment.end:
        return TextAlign.end;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (type) {
      case CustomTextType.top:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
      case CustomTextType.head:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0A3751),
        );
      case CustomTextType.bread:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF0A3751),
        );
      case CustomTextType.cardHead:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        );
      case CustomTextType.cardDescription:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.normal,
          color: Color(0xFF656565),
        );
      case CustomTextType.button:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        );
      case CustomTextType.info:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0A3751),
        );
      case CustomTextType.label:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        );
      case CustomTextType.placeholder:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF656565),
        );
      case CustomTextType.helper:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0A3751),
        );
      case CustomTextType.helpBread:
        return const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          height: 22 / 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF656565),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle(context);
    final textAlign = _getTextAlign();

    return selectable
        ? SelectableText(
            text,
            style: textStyle,
            textAlign: textAlign,
            maxLines: maxLines,
          )
        : Text(
            text,
            style: textStyle,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
  }
}
