/// Håndterer tilstandsændringer for swipe-knappen i bekræftelsesprocessen.
///
/// Denne fil indeholder funktionalitet til at opdatere knaptilstanden baseret på
/// den aktuelle bekræftelsestilstand.

import 'package:flutter/material.dart';
import '../../../models/confirm_state.dart';
import '../../../../widgets/confirm/slide/persistent_swipe_button.dart';

/// En klasse til at håndtere knaptilstanden i bekræftelsesprocessen
class ConfirmButtonStateHandler {
  /// Opdaterer knaptilstanden baseret på den aktuelle bekræftelsestilstand
  ///
  /// Denne metode bruger Future.microtask for at sikre, at opdateringen sker
  /// efter det aktuelle build er færdigt
  static void updateButtonStateBasedOnState({
    required ConfirmState currentState,
    required ValueNotifier<SwipeButtonState> buttonStateNotifier,
    required bool mounted,
    required VoidCallback generateNewQuestion,
  }) {
    // Brug Future.microtask for at sikre at dette kører efter det aktuelle build er færdigt
    Future.microtask(() {
      if (mounted) {
        switch (currentState) {
          case ConfirmState.initial:
            debugPrint('🔶🔶🔶 updateButtonStateBasedOnState: Setting to init');
            buttonStateNotifier.value = SwipeButtonState.init;
            // Generer nye tal når tilstanden er initial
            generateNewQuestion();
            break;
          case ConfirmState.step_7:
            debugPrint(
                '🔶🔶🔶 updateButtonStateBasedOnState: Setting to confirmed');
            buttonStateNotifier.value = SwipeButtonState.confirmed;
            break;
          case ConfirmState.watch:
            buttonStateNotifier.value = SwipeButtonState.waiting;
            break;
          case ConfirmState.error:
            buttonStateNotifier.value = SwipeButtonState.error;
            break;
          case ConfirmState.fraud:
            buttonStateNotifier.value = SwipeButtonState.fraud;
            break;
          case ConfirmState.step_2:
          case ConfirmState.step_3:
          case ConfirmState.step_4:
          case ConfirmState.step_5:
          case ConfirmState.step_6:
          case ConfirmState.dev_test:
            // Ingen ændring for disse tilstande
            break;
          default:
            // For alle andre tilfælde
            buttonStateNotifier.value = SwipeButtonState.fraud;
            break;
        }
      }
    });
  }
}
