import '../../exports.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/confirms_provider.dart';
import '../../models/confirm_state.dart';
import '../../models/api_response.dart';
import '../../models/confirm_payload.dart';
import '../../widgets/custom/custom_text.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'initiator_widget.dart';
import 'confirm_success_widget.dart';
import 'confirm_existing_widget.dart';
import 'confirm_error_widget.dart';
import 'step_2.dart';
import 'step_3.dart';
import 'step_4.dart';
import 'step_5.dart';
import 'step_6.dart';
import 'step_7.dart';
import 'step_watch.dart';
import 'dev_test.dart';
import '../../../screens/authenticated/test/persistent_swipe_button.dart';

class Confirm extends ConsumerStatefulWidget {
  final String contactId;

  const Confirm({
    super.key,
    required this.contactId,
  });

  @override
  ConsumerState<Confirm> createState() => _ConfirmState();
}

class _ConfirmState extends ConsumerState<Confirm> {
  ConfirmState currentState = ConfirmState.initial;
  ConfirmPayload? confirmData;
  String? errorMessage;
  final ValueNotifier<SwipeButtonState> buttonStateNotifier =
      ValueNotifier<SwipeButtonState>(SwipeButtonState.init);
  ConfirmState? _previousState;
  String _questionString = ""; // Ingen default værdi
  String _answerString = ""; // Variabel til at gemme summen af tallene

  @override
  void initState() {
    super.initState();
    _previousState = currentState;
    _generateNewQuestionString(); // Generer en ny streng ved initialisering
  }

  /// Genererer en streng med to tilfældige tal (1-999) adskilt af et komma
  /// og beregner summen af tallene som gemmes i _answerString
  String _generateNewQuestionString() {
    final random = math.Random();
    final int firstNumber = random.nextInt(999) + 1; // 1-999
    final int secondNumber = random.nextInt(999) + 1; // 1-999
    _questionString = "$firstNumber,$secondNumber";

    // Beregn summen og gem den i _answerString
    final int sum = firstNumber + secondNumber;
    _answerString = sum.toString();

    developer.log(
        'Genererede ny spørgsmålsstreng: $_questionString, svar: $_answerString',
        name: 'Confirm');
    return _questionString;
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

  void _updateButtonStateBasedOnCurrentState() {
    // Brug Future.microtask for at sikre at dette kører efter det aktuelle build er færdigt
    Future.microtask(() {
      if (mounted) {
        switch (currentState) {
          case ConfirmState.initial:
            debugPrint(
                '🔶🔶🔶 _updateButtonStateBasedOnCurrentState: Setting to init');
            buttonStateNotifier.value = SwipeButtonState.init;
            // Generer nye tal når tilstanden er initial
            setState(() {
              _generateNewQuestionString();
            });
            break;
          case ConfirmState.step_7:
            debugPrint(
                '🔶🔶🔶 _updateButtonStateBasedOnCurrentState: Setting to confirmed');
            buttonStateNotifier.value = SwipeButtonState.confirmed;
            break;
          case ConfirmState.watch:
            buttonStateNotifier.value = SwipeButtonState.waiting;
            break;
          case ConfirmState.error:
            buttonStateNotifier.value = SwipeButtonState.error;
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
            // For alle andre tilfælde (som i original default case)
            buttonStateNotifier.value = SwipeButtonState.fraud;
            break;
        }
      }
    });
  }

  void updateNewRecordStatus(bool newValue) {
    if (confirmData != null) {
      setState(() {
        confirmData = confirmData!.copyWith(newRecord: newValue);
      });
    }
  }

  void _handleStateChange(ConfirmState newState, Map<String, dynamic>? data) {
    debugPrint('🔍 _handleStateChange called with state: $newState');
    debugPrint('🔍 Raw data received: $data');

    bool currentStateIsSet = false;

    setState(() {
      currentState = newState;

      if (data != null) {
        try {
          // Hvis det er en error, så skal vi udskrive errorMessage
          if (data['status_code'] == null || data['status_code'] != 200) {
            debugPrint('🔍 🇩🇰🔍 🇩🇰🔍 🇩🇰🔍 🇩🇰 Error data: $data');
            currentState = ConfirmState.error;
            errorMessage =
                data['message'] == null || data['message'].toString().isEmpty
                    ? 'Der skete en fejl du'
                    : data['message'];
            return;
          }

          // Udpak payload fra response
          if (data['data'] != null && data['data']['payload'] != null) {
            final payload = data['data']['payload'] as Map<String, dynamic>;
            debugPrint('🔍 Extracted payload: $payload');

            final Map<String, dynamic> confirmData = {
              'confirms_id': payload['confirms_id'],
              'created_at': DateTime.now().toIso8601String(),
              'status': payload['status'],
              'contacts_id': widget.contactId,
              'question': payload['question'] ?? '',
            };

            // Kun sæt new_record hvis den er med i payload
            if (payload.containsKey('new_record')) {
              confirmData['new_record'] = payload['new_record'];
            } else if (this.confirmData != null) {
              // Behold eksisterende værdi hvis den findes
              confirmData['new_record'] = this.confirmData!.newRecord;
            }
            // Ellers bruges default værdien fra modellen (false)

            debugPrint('🔍 Prepared data for ConfirmPayload: $confirmData');
            this.confirmData = ConfirmPayload.fromJson(confirmData);
            debugPrint(
                '🔍 Successfully created ConfirmPayload: ${this.confirmData}');
            debugPrint('🔍 new_record value: ${this.confirmData?.newRecord}');

            // Her!
            debugPrint('🔍 🔍 🔍 🔍 TEST VALUES: 🔍 🔍 🔍 🔍');
            debugPrint('🔍 Status: ${this.confirmData?.status}');
            debugPrint('🔍 New Record: ${this.confirmData?.newRecord}');
            debugPrint('🔍 Full confirmData: ${this.confirmData?.toJson()}');

            if (this.confirmData?.newRecord == true) {
              debugPrint('🔍 newRecord == true');
              if (this.confirmData?.status == 1) {
                debugPrint('🔍 this.confirmData?.status == 1');
                currentState = ConfirmState.watch;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }

              if (this.confirmData?.status == 2) {
                debugPrint('🔍 this.confirmData?.status == 2');
                currentState = ConfirmState.watch;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }

              if (this.confirmData?.status == 3) {
                debugPrint('🔍 this.confirmData?.status == 3');
                currentState = ConfirmState.step_4;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }

              if (this.confirmData?.status == 4) {
                debugPrint('🔍 this.confirmData?.status == 4');
                currentState = ConfirmState.step_5;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }

              if (this.confirmData?.status == 5) {
                debugPrint('🔍 this.confirmData?.status == 5');
                currentState = ConfirmState.watch;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }
              if (this.confirmData?.status == 6) {
                debugPrint('🔍 this.confirmData?.status == 6');
                currentState = ConfirmState.step_7;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }
            } else {
              debugPrint('🔍 newRecord == false');
              if (this.confirmData?.status == 2) {
                debugPrint('🔍 this.confirmData?.status == 2');
                currentState = ConfirmState.step_3;
                currentStateIsSet = true;
              }

              if (this.confirmData?.status == 3) {
                debugPrint('❤️❤️🇩🇰❤️❤️ this.confirmData?.status == 3');
                currentState = ConfirmState.watch;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }

              if (this.confirmData?.status == 4) {
                debugPrint('❤️❤️🇩🇰❤️❤️ this.confirmData?.status == 4');
                currentState = ConfirmState.watch;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }
              if (this.confirmData?.status == 5) {
                debugPrint('❤️❤️🇩🇰❤️❤️ this.confirmData?.status == 5');
                currentState = ConfirmState.step_6;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }
              if (this.confirmData?.status == 6) {
                debugPrint('🔍 this.confirmData?.status == 6');
                currentState = ConfirmState.step_7;
                // set variabel currentStateIsSet to true
                currentStateIsSet = true;
              }
            }

            // Hvis tilstanden ikke er sat, så er der sket en fejl
            if (!currentStateIsSet) {
              debugPrint(
                  '🔍 Unexpected state combination - Status: ${this.confirmData?.status}, New Record: ${this.confirmData?.newRecord}');
              currentState = ConfirmState.error;
              errorMessage = 'Uventet tilstand';
            }
          } else {
            throw Exception('Mangler payload data i svaret fra serveren');
          }
        } catch (e, stackTrace) {
          debugPrint('❌ Error creating ConfirmPayload: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          currentState = ConfirmState.error;
          errorMessage = 'Kunne ikke behandle data: $e';
        }
      } else {
        debugPrint('❌ No data received, setting confirmData to null');
        confirmData = null;
      }
    });
    debugPrint('🔍 Final state: $currentState');
    debugPrint('🔍 Final confirmData: $confirmData');
    debugPrint('🔍 Final new_record value: ${confirmData?.newRecord}');
    debugPrint('🔍 Final errorMessage: $errorMessage');

    // Opdater knaptilstanden baseret på den nye state
    _updateButtonStateBasedOnCurrentState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🚩🚩🚩🚩 new_record: ${confirmData?.newRecord}');

    return SizedBox(
      height: 250.0,
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
                        developer.log('PersistentSwipeButton swiped',
                            name: 'Confirm');
                        // Ingen yderligere handling nødvendig, da _handleConfirm() håndteres internt i PersistentSwipeButton
                      },
                      onStateChange: (SwipeButtonState newState) {
                        // Update button state based on widget's suggestion
                        buttonStateNotifier.value = newState;
                      },
                      // Tilføj de nye parametre
                      contactId: widget.contactId,
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
                switch (currentState) {
                  case ConfirmState.initial:
                    return Container();
                  case ConfirmState.step_2:
                    return Step2Widget(
                      rawData: confirmData!.toJson(),
                      onStateChange: _handleStateChange,
                    );
                  case ConfirmState.step_3:
                    return Step3Widget(
                      rawData: confirmData!.toJson(),
                      onStateChange: _handleStateChange,
                      answer: _answerString,
                    );
                  case ConfirmState.step_4:
                    return Step4Widget(
                      rawData: confirmData!.toJson(),
                      onStateChange: _handleStateChange,
                      answer: _answerString,
                    );
                  case ConfirmState.step_5:
                    return Step5Widget(
                      rawData: confirmData!.toJson(),
                      onStateChange: _handleStateChange,
                    );
                  case ConfirmState.step_6:
                    return Step6Widget(
                      rawData: confirmData!.toJson(),
                      onStateChange: _handleStateChange,
                    );
                  case ConfirmState.step_7:
                    // Fjern direkte ændring af tilstand her
                    // buttonStateNotifier.value = SwipeButtonState.confirmed;
                    debugPrint('🔶🔶🔶 BuildContext for step_7');
                    return Step7Widget(
                      rawData: confirmData!.toJson(),
                      onStateChange: _handleStateChange,
                    );
                  case ConfirmState.watch:
                    // Fjern direkte ændring af tilstand her
                    // buttonStateNotifier.value = SwipeButtonState.waiting;
                    return StepWatchWidget(
                      rawData: confirmData!.toJson(),
                      onStateChange: _handleStateChange,
                    );
                  case ConfirmState.dev_test:
                    return DevTestWidget(
                      rawData: confirmData!.toJson(),
                      onStateChange: _handleStateChange,
                    );
                  case ConfirmState.error:
                    // Fjern direkte ændring af tilstand her
                    // buttonStateNotifier.value = SwipeButtonState.error;
                    return ConfirmErrorWidget(
                      errorMessage: errorMessage ?? 'Der opstod en ukendt fejl',
                      onStateChange: _handleStateChange,
                    );
                  default:
                    // Fjern direkte ændring af tilstand her
                    // buttonStateNotifier.value = SwipeButtonState.fraud;
                    return ConfirmErrorWidget(
                      errorMessage: 'Ukendt tilstand',
                      onStateChange: _handleStateChange,
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateDropdown(SwipeButtonState currentState,
      ValueNotifier<SwipeButtonState> stateNotifier) {
    return DropdownButton<SwipeButtonState>(
      value: currentState,
      onChanged: (SwipeButtonState? newValue) {
        if (newValue != null) {
          stateNotifier.value = newValue;
        }
      },
      items: SwipeButtonState.values
          .map<DropdownMenuItem<SwipeButtonState>>((SwipeButtonState value) {
        return DropdownMenuItem<SwipeButtonState>(
          value: value,
          child: Text(value.toString().split('.').last),
        );
      }).toList(),
    );
  }
}
