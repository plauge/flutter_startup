/// Bygger widgets baseret på den aktuelle bekræftelsestilstand.
///
/// Denne fil indeholder funktionalitet til at bygge de korrekte widgets
/// baseret på den aktuelle bekræftelsestilstand.

import 'package:flutter/material.dart';
import '../../../models/confirm_state.dart';
import '../../../models/confirm_payload.dart';
import '../step_2.dart';
import '../step_3.dart';
import '../step_4.dart';
import '../step_5.dart';
import '../step_6.dart';
import '../step_7.dart';
import '../step_watch.dart';
import '../confirm_error_widget.dart';
import '../fraud_widget.dart';

/// En klasse til at bygge widgets baseret på bekræftelsestilstanden
class ConfirmWidgetBuilder {
  /// Bygger den korrekte widget baseret på den aktuelle bekræftelsestilstand
  static Widget buildWidgetForState({
    required ConfirmState currentState,
    required ConfirmPayload? confirmData,
    required String? errorMessage,
    required Function(ConfirmState, Map<String, dynamic>?) onStateChange,
    required String answerString,
  }) {
    switch (currentState) {
      case ConfirmState.initial:
        return Container();
      case ConfirmState.step_2:
        return Step2Widget(
          rawData: confirmData!.toJson(),
          onStateChange: onStateChange,
        );
      case ConfirmState.step_3:
        return Step3Widget(
          rawData: confirmData!.toJson(),
          onStateChange: onStateChange,
          answer: answerString,
        );
      case ConfirmState.step_4:
        return Step4Widget(
          rawData: confirmData!.toJson(),
          onStateChange: onStateChange,
          answer: answerString,
        );
      case ConfirmState.step_5:
        return Step5Widget(
          rawData: confirmData!.toJson(),
          onStateChange: onStateChange,
        );
      case ConfirmState.step_6:
        return Step6Widget(
          rawData: confirmData!.toJson(),
          onStateChange: onStateChange,
        );
      case ConfirmState.step_7:
        debugPrint('🔶🔶🔶 BuildContext for step_7');
        return Step7Widget(
          rawData: confirmData!.toJson(),
          onStateChange: onStateChange,
        );
      case ConfirmState.watch:
        return StepWatchWidget(
          rawData: confirmData!.toJson(),
          onStateChange: onStateChange,
        );
      case ConfirmState.error:
        return ConfirmErrorWidget(
          errorMessage: errorMessage ?? 'Der opstod en ukendt fejl',
          onStateChange: onStateChange,
        );
      case ConfirmState.fraud:
        // return FraudWidget(
        //   rawData: confirmData!.toJson(),
        //   onStateChange: onStateChange,
        // );
        return Container();
      default:
        return ConfirmErrorWidget(
          errorMessage: 'Ukendt tilstand',
          onStateChange: onStateChange,
        );
    }
  }
}
