/// Hovedkomponent til bekræftelsesprocessen.
///
/// Denne fil fungerer som indgangspunkt til bekræftelsesprocessen og koordinerer
/// de forskellige komponenter, der håndterer tilstandsændringer, knaptilstand,
/// spørgsmålsgenerering og widget-bygning.

import '../../exports.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/confirm_state.dart';
import '../../models/confirm_payload.dart';
import 'dart:developer' as developer;
import 'slide/persistent_swipe_button.dart';

// Importer de nye komponenter
import 'confirm_extra/index.dart';

class Confirm extends ConsumerStatefulWidget {
  final String contactId;
  final String contactFirstName;

  const Confirm({
    super.key,
    required this.contactId,
    required this.contactFirstName,
  });

  @override
  ConsumerState<Confirm> createState() => _ConfirmState();
}

class _ConfirmState extends ConsumerState<Confirm> {
  ConfirmState currentState = ConfirmState.initial;
  ConfirmPayload? confirmData;
  String? errorMessage;
  final ValueNotifier<SwipeButtonState> buttonStateNotifier = ValueNotifier<SwipeButtonState>(SwipeButtonState.init);
  ConfirmState? _previousState;
  String _questionString = ""; // Ingen default værdi
  String _answerString = ""; // Variabel til at gemme summen af tallene

  @override
  void initState() {
    super.initState();
    _previousState = currentState;
    _generateNewQuestionString(); // Generer en ny streng ved initialisering
    developer.log('Initial _answerString: $_answerString', name: 'Confirm');
  }

  /// Genererer en ny spørgsmålsstreng og sætter svaret
  void _generateNewQuestionString() {
    final questionAndAnswer = ConfirmQuestionGenerator.generateQuestionAndAnswer();
    setState(() {
      _questionString = questionAndAnswer['question']!;
      _answerString = questionAndAnswer['answer']!;
    });
    developer.log('Generated new _answerString: $_answerString', name: 'Confirm');
  }

  @override
  void didUpdateWidget(Confirm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Hvis tilstanden er ændret, opdater knaptilstanden
    if (_previousState != currentState) {
      _previousState = currentState;
      _updateButtonStateBasedOnCurrentState();
    }
  }

  /// Opdaterer knaptilstanden baseret på den aktuelle bekræftelsestilstand
  void _updateButtonStateBasedOnCurrentState() {
    ConfirmButtonStateHandler.updateButtonStateBasedOnState(
      currentState: currentState,
      buttonStateNotifier: buttonStateNotifier,
      mounted: mounted,
      generateNewQuestion: () {
        setState(() {
          _generateNewQuestionString();
        });
      },
    );
  }

  /// Opdaterer newRecord status
  void updateNewRecordStatus(bool newValue) {
    if (confirmData != null) {
      setState(() {
        confirmData = confirmData!.copyWith(newRecord: newValue);
      });
    }
  }

  /// Håndterer tilstandsændringer
  void _handleStateChange(ConfirmState newState, Map<String, dynamic>? data) {
    developer.log('Handling state change to $newState with _answerString: $_answerString', name: 'Confirm');

    final result = ConfirmStateManager.handleStateChange(
      newState: newState,
      data: data,
      contactId: widget.contactId,
      currentConfirmData: confirmData,
      answerString: _answerString,
    );

    setState(() {
      currentState = result['state'] as ConfirmState;
      confirmData = result['confirmData'] as ConfirmPayload?;
      errorMessage = result['errorMessage'] as String?;
    });

    // Opdater knaptilstanden baseret på den nye state
    _updateButtonStateBasedOnCurrentState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🚩🚩🚩🚩 new_record: ${confirmData?.newRecord}');

    // Log ekstra data hvis de findes
    if (confirmData != null) {
      developer.log(
        'Confirm data i build: receiverStatus=${confirmData?.receiverStatus}, initiatorStatus=${confirmData?.initiatorStatus}, '
        'encryptedReceiverAnswer=${confirmData?.encryptedReceiverAnswer}, encryptedInitiatorAnswer=${confirmData?.encryptedInitiatorAnswer}',
        name: 'Confirm',
      );
    }

    return SizedBox(
      height: 200.0,
      child: Column(
        children: [
          ValueListenableBuilder<SwipeButtonState>(
              valueListenable: buttonStateNotifier,
              builder: (context, buttonState, _) {
                return Column(
                  children: [
                    PersistentSwipeButton(
                      buttonState: buttonState,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensionsTheme.getMedium(context),
                        vertical: AppDimensionsTheme.getSmall(context),
                      ),
                      question: confirmData?.question ?? _questionString,
                      onSwipe: () {
                        // Vi behøver ikke at gøre noget her, da _handleConfirm() allerede kaldes i PersistentSwipeButton
                        developer.log('PersistentSwipeButton swiped', name: 'Confirm');
                        // Ingen yderligere handling nødvendig, da _handleConfirm() håndteres internt i PersistentSwipeButton
                      },
                      onStateChange: (SwipeButtonState newState) {
                        // Update button state based on widget's suggestion
                        buttonStateNotifier.value = newState;
                      },
                      // Tilføj de nye parametre
                      contactId: widget.contactId,
                      contactFirstName: widget.contactFirstName,
                      onConfirmStateChange: _handleStateChange,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    // Må ikke slettes
                    // _buildStateDropdown(buttonState, buttonStateNotifier),
                  ],
                );
              }),
          Gap(AppDimensionsTheme.getMedium(context)),
          Expanded(
            child: Builder(
              builder: (context) {
                return ConfirmWidgetBuilder.buildWidgetForState(
                  currentState: currentState,
                  confirmData: confirmData,
                  errorMessage: errorMessage,
                  onStateChange: _handleStateChange,
                  answerString: _answerString,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Beholdes for fremtidig brug
  Widget _buildStateDropdown(SwipeButtonState currentState, ValueNotifier<SwipeButtonState> stateNotifier) {
    return DropdownButton<SwipeButtonState>(
      value: currentState,
      onChanged: (SwipeButtonState? newValue) {
        if (newValue != null) {
          stateNotifier.value = newValue;
        }
      },
      items: SwipeButtonState.values.map<DropdownMenuItem<SwipeButtonState>>((SwipeButtonState value) {
        return DropdownMenuItem<SwipeButtonState>(
          value: value,
          child: Text(value.toString().split('.').last),
        );
      }).toList(),
    );
  }
}
