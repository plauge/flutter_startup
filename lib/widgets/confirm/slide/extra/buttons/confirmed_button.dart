import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/animation_handler.dart';

class ConfirmedButton extends StatelessWidget {
  final Animation<double>? pulseAnimation;
  final bool showConfirmationEffect;
  final double intensity;
  final Color glowColor;

  const ConfirmedButton({
    Key? key,
    this.pulseAnimation,
    required this.showConfirmationEffect,
    required this.intensity,
    required this.glowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final double animationValue = pulseAnimation?.value ?? 0.0;

        return Container(
          width: double.infinity,
          height: 60,
          decoration: AnimationHandler.getPulseDecoration(
            animationValue: animationValue,
            intensity: intensity,
            glowColor: glowColor,
            showConfirmationEffect: showConfirmationEffect,
          ),
          child: Stack(
            children: [
              // Centreret tekst
              const Align(
                alignment: Alignment(-0.15, 0), // Forskyd teksten lidt til venstre
                child: Text(
                  "Bekræftet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Thumb fastgjort til højre side
              Positioned(
                right: 1,
                top: 1,
                bottom: 1,
                child: Material(
                  elevation: 0,
                  color: const Color(0xFF0E5D4A),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                  child: Container(
                    width: 60,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/confirmation/confirmed.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
