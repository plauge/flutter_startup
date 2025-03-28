/// Definerer reglerne for tilstandsændringer i bekræftelsesprocessen.
///
/// Denne fil indeholder funktionalitet til at bestemme næste tilstand
/// baseret på aktuel status og om det er en ny optegnelse.

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../models/confirm_state.dart';
import '../../../models/confirm_payload.dart';

/// En klasse til at håndtere regler for tilstandsændringer i bekræftelsesprocessen
class ConfirmStateRules {
  /// Bestemmer næste tilstand baseret på bekræftelsesdata og answerString
  ///
  /// Returnerer et map med den nye tilstand og om tilstanden blev sat
  static Map<String, dynamic> determineNextState({
    required ConfirmPayload? confirmData,
    String answerString = '',
  }) {
    debugPrint('🔍 determineNextState called');
    debugPrint('🔍 newRecord value: ${confirmData?.newRecord}');
    debugPrint('🔍 status value: ${confirmData?.status}');

    ConfirmState resultState = ConfirmState.error;
    bool currentStateIsSet = false;

    if (confirmData == null) {
      debugPrint('❌ No confirmData provided');
      return {
        'state': resultState,
        'currentStateIsSet': currentStateIsSet,
      };
    }

    if (confirmData.newRecord == true) {
      debugPrint('🔍 newRecord == true');
      if (confirmData.status == 1) {
        debugPrint('🔍 confirmData.status == 1');
        resultState = ConfirmState.watch;
        currentStateIsSet = true;
      }

      if (confirmData.status == 2) {
        debugPrint('🔍 confirmData.status == 2');
        resultState = ConfirmState.watch;
        currentStateIsSet = true;
      }

      if (confirmData.status == 3) {
        // Svar: confirms_initiator_update
        debugPrint('🔍>>>>>> confirmData.status == 3');
        debugPrint('🔍>>>>>> answerString: $answerString');
        debugPrint(
            '🔍>>>>>> confirmData.encryptedReceiverAnswer: ${confirmData.encryptedReceiverAnswer}');
        if (confirmData.encryptedInitiatorAnswer == answerString) {
          resultState = ConfirmState.step_4;
        } else {
          //resultState = ConfirmState.fraud;
          resultState = ConfirmState.step_4;
        }
        currentStateIsSet = true;
      }

      if (confirmData.status == 4) {
        debugPrint('🔍 confirmData.status == 4');
        resultState = ConfirmState.step_5;
        currentStateIsSet = true;
      }

      if (confirmData.status == 5) {
        debugPrint('🔍 confirmData.status == 5');
        resultState = ConfirmState.watch;
        currentStateIsSet = true;
      }
      if (confirmData.status == 6) {
        debugPrint('🔍 confirmData.status == 6');
        resultState = ConfirmState.step_7;
        currentStateIsSet = true;
      }
    } else {
      debugPrint('🔍 newRecord == false');
      if (confirmData.status == 2) {
        debugPrint('🔍 confirmData.status == 2');
        resultState = ConfirmState.step_3;
        currentStateIsSet = true;
      }

      if (confirmData.status == 3) {
        // Svar: confirms_reciever_update
        debugPrint('❤️❤️🇩🇰❤️❤️ confirmData.status == 3');
        resultState = ConfirmState.watch;
        currentStateIsSet = true;
      }

      if (confirmData.status == 4) {
        debugPrint('❤️❤️🇩🇰❤️❤️ confirmData.status == 4');
        resultState = ConfirmState.watch;
        currentStateIsSet = true;

        //resultState = ConfirmState.fraud;
      }
      if (confirmData.status == 5) {
        debugPrint('❤️❤️🇩🇰❤️❤️ confirmData.status == 5');
        resultState = ConfirmState.step_6;
        currentStateIsSet = true;
      }
      if (confirmData.status == 6) {
        debugPrint('🔍 confirmData.status == 6');
        resultState = ConfirmState.step_7;
        currentStateIsSet = true;
      }
    }

    // Hvis tilstanden ikke er sat, så er der sket en fejl
    if (!currentStateIsSet) {
      debugPrint(
          '🔍 Unexpected state combination - Status: ${confirmData.status}, New Record: ${confirmData.newRecord}');
      resultState = ConfirmState.error;
    }

    debugPrint('🔍 Final determined state: $resultState');
    debugPrint('🔍 Final currentStateIsSet: $currentStateIsSet');

    return {
      'state': resultState,
      'currentStateIsSet': currentStateIsSet,
    };
  }
}
