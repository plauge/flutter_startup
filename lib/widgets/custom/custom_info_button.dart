import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomInfoButton extends StatelessWidget {
  const CustomInfoButton({
    super.key,
    this.text = 'Tekst mangler ...',
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 9, 25, 9),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              // border: Border.all(
              //   color: const Color(0xFF005272),
              //   width: 1,
              // ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/info-icon.svg',
                  width: 20,
                  height: 20,
                  color: const Color(0xFF005272),
                ),
                const Gap(10),
                CustomText(
                  text: text,
                  type: CustomTextType.infoButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Created: 2024-07-02 14:12
