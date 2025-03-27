import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AnimationHandler {
  static AnimationController? setupPulseAnimation({
    required TickerProvider vsync,
    required int pulseSpeed,
    required int pulseCount,
    required VoidCallback onAnimationComplete,
  }) {
    developer.log('Setting up pulse animation', name: 'AnimationHandler');

    // Opret ny controller med hastighed fra widget
    final controller = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: pulseSpeed),
    );

    // Opret en curved animation for mere naturlig pulsering
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    // Lyt til animation status
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        onAnimationComplete();
      }
    });

    // Start animation
    controller.forward();

    return controller;
  }

  static BoxDecoration getPulseDecoration({
    required double animationValue,
    required double intensity,
    required Color glowColor,
    required bool showConfirmationEffect,
  }) {
    // Beregn effekter baseret på intensitet og animationsværdi
    final double extraOpacity =
        showConfirmationEffect ? (animationValue * intensity) : 0.0;

    final double shadowSpread = 0.5 + (animationValue * 3.0 * intensity);
    final double glowSpread = 1.0 + (animationValue * 5.0 * intensity);

    final double shadowBlur = 2.0 + (animationValue * 8.0 * intensity);
    final double glowBlur = 8.0 + (animationValue * 12.0 * intensity);

    return BoxDecoration(
      color: const Color(0xFF0E5D4A),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        // Standard skygge (primær)
        BoxShadow(
          color: Colors.black.withOpacity(0.2 + extraOpacity),
          spreadRadius: shadowSpread,
          blurRadius: shadowBlur,
          offset: const Offset(0, 1),
        ),
        // Glød-effekt (sekundær)
        if (showConfirmationEffect)
          BoxShadow(
            color: glowColor.withOpacity(extraOpacity),
            spreadRadius: glowSpread,
            blurRadius: glowBlur,
            offset: const Offset(0, 0),
          ),
      ],
    );
  }
}
