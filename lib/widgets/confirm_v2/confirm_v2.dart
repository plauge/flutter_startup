import '../../exports.dart';
import 'dart:math';
import 'steps/confirm_v2_step1.dart';
import 'steps/confirm_v2_step2.dart';
import 'steps/confirm_v2_step3.dart';
import 'steps/confirm_v2_step4.dart';
import 'steps/confirm_v2_step5.dart';
import 'steps/confirm_v2_step6.dart';
import 'steps/confirm_v2_step7.dart';
import 'steps/confirm_v2_step8.dart';

class ConfirmV2 extends ConsumerStatefulWidget {
  final String contactsId;

  const ConfirmV2({
    super.key,
    required this.contactsId,
  });

  @override
  ConsumerState<ConfirmV2> createState() => _ConfirmV2State();
}

class _ConfirmV2State extends ConsumerState<ConfirmV2> {
  static final log = scopedLogger(LogCategory.other);

  ConfirmV2Step currentStep = ConfirmV2Step.step1;
  ConfirmPayload? confirmPayload;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    log('[confirm_v2.dart][initState] Initializing ConfirmV2 for contactsId: ${widget.contactsId}');
  }

  /// Genererer random string på 10 tegn
  String _generateRandomQuestion() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final question = String.fromCharCodes(
      Iterable.generate(10, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    log('[confirm_v2.dart][_generateRandomQuestion] Generated question: $question');
    return question;
  }

  /// Håndterer tilstandsændringer og step navigation
  void _handleStepChange(ConfirmV2Step newStep, {ConfirmPayload? newPayload, String? error}) {
    log('[confirm_v2.dart][_handleStepChange] Changing from $currentStep to $newStep');

    setState(() {
      currentStep = newStep;
      if (newPayload != null) {
        confirmPayload = newPayload;
      }
      errorMessage = error;
    });
  }

  /// Reset hele mother-widget til initial state
  void _resetWidget() {
    log('[confirm_v2.dart][_resetWidget] Resetting widget to initial state');
    setState(() {
      currentStep = ConfirmV2Step.step1;
      confirmPayload = null;
      errorMessage = null;
    });
  }

  /// Start confirm process (til Step 1)
  Future<void> _startConfirmProcess() async {
    try {
      log('[confirm_v2.dart][_startConfirmProcess] Starting confirm process');

      final question = _generateRandomQuestion();

      // Kald confirm() funktionen fra ConfirmsConfirm provider
      final response = await ref.read(confirmsConfirmProvider.notifier).confirm(
            contactsId: widget.contactsId,
            question: question,
          );

      log('[confirm_v2.dart][_startConfirmProcess] Response received: $response');

      // Parse response til ConfirmPayload
      if (response['status_code'] == 200 && response['data'] != null) {
        final payload = response['data']['payload'] as Map<String, dynamic>;

        final confirmData = ConfirmPayload(
          confirmsId: payload['confirms_id'],
          createdAt: DateTime.now(),
          status: payload['status'],
          contactsId: widget.contactsId,
          question: question,
          newRecord: payload['new_record'],
        );

        log('[confirm_v2.dart][_startConfirmProcess] ConfirmPayload created successfully');

        if (payload['new_record'] == true) {
          // Gå til step 2 - ny record
          _handleStepChange(ConfirmV2Step.step2, newPayload: confirmData);
        } else {
          // Gå til step 3 - eksisterende record
          _handleStepChange(ConfirmV2Step.step3, newPayload: confirmData);
          // Kald automatisk step 3 process
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStep3Process();
          });
        }
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e, stack) {
      log('[confirm_v2.dart][_startConfirmProcess] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step1, error: 'Fejl ved start af bekræftelse: $e');
    }
  }

  /// Handle Step 2 process - manual step transition
  Future<void> _handleStep2Process() async {
    try {
      log('[confirm_v2.dart][_handleStep2Process] Manual step 2 process - moving to step 5');
      _handleStepChange(ConfirmV2Step.step5);
    } catch (e, stack) {
      log('[confirm_v2.dart][_handleStep2Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step2, error: 'Fejl i step 2: $e');
    }
  }

  /// Handle Step 3 process
  Future<void> _handleStep3Process() async {
    try {
      log('[confirm_v2.dart][_handleStep3Process] Processing step 3');

      if (confirmPayload == null) {
        throw Exception('ConfirmPayload is null');
      }

      // Kald confirmsRecieverUpdate med answer = "1234"
      log('[confirm_v2.dart][_handleStep3Process] Calling confirmsRecieverUpdate with answer: 1234, confirmsId: ${confirmPayload!.confirmsId}');

      final response = await ref.read(confirmsConfirmProvider.notifier).confirmsRecieverUpdate(
            answer: "1234",
            confirmsId: confirmPayload!.confirmsId,
          );

      log('[confirm_v2.dart][_handleStep3Process] confirmsRecieverUpdate response received: $response');

      // Tjek for success før vi går videre
      if (response['status_code'] == 200) {
        // Gå til step 4 efter succesfuldt svar
        _handleStepChange(ConfirmV2Step.step4);
      } else {
        // Håndter fejl fra server
        final message = response['data']?['message'] ?? 'Ukendt fejl';
        throw Exception('Server fejl (${response['status_code']}): $message');
      }
    } catch (e, stack) {
      log('[confirm_v2.dart][_handleStep3Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step3, error: 'Fejl i step 3: $e');
    }
  }

  /// Handle Step 4 process
  Future<void> _handleStep4Process() async {
    try {
      log('[confirm_v2.dart][_handleStep4Process] Processing step 4');
      // TODO: Add step 4 specific logic here
      // For now, move to step 5
      _handleStepChange(ConfirmV2Step.step5);
    } catch (e, stack) {
      log('[confirm_v2.dart][_handleStep4Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step4, error: 'Fejl i step 4: $e');
    }
  }

  /// Handle Step 5 process
  Future<void> _handleStep5Process() async {
    try {
      log('[confirm_v2.dart][_handleStep5Process] Processing step 5');

      if (confirmPayload == null) {
        throw Exception('ConfirmPayload is null');
      }

      // Kald confirmsInitiatorUpdate med answer = "1234"
      log('[confirm_v2.dart][_handleStep5Process] Calling confirmsInitiatorUpdate with answer: 1234, confirmsId: ${confirmPayload!.confirmsId}');

      final response = await ref.read(confirmsConfirmProvider.notifier).confirmsInitiatorUpdate(
            answer: "1234",
            confirmsId: confirmPayload!.confirmsId,
          );

      log('[confirm_v2.dart][_handleStep5Process] confirmsInitiatorUpdate response received: $response');

      // Tjek for success før vi går videre
      if (response['status_code'] == 200) {
        // Gå til step 6 efter succesfuldt svar
        _handleStepChange(ConfirmV2Step.step6);
      } else {
        // Håndter fejl fra server
        final message = response['data']?['message'] ?? 'Ukendt fejl';
        throw Exception('Server fejl (${response['status_code']}): $message');
      }
    } catch (e, stack) {
      log('[confirm_v2.dart][_handleStep5Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step5, error: 'Fejl i step 5: $e');
    }
  }

  /// Handle Step 6 process
  Future<void> _handleStep6Process() async {
    try {
      log('[confirm_v2.dart][_handleStep6Process] Processing step 6');
      // TODO: Add step 6 specific logic here
      // For now, move to step 7
      _handleStepChange(ConfirmV2Step.step7);
    } catch (e, stack) {
      log('[confirm_v2.dart][_handleStep6Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step6, error: 'Fejl i step 6: $e');
    }
  }

  /// Handle Step 7 process
  Future<void> _handleStep7Process() async {
    try {
      log('[confirm_v2.dart][_handleStep7Process] Processing step 7');
      // TODO: Add step 7 specific logic here
      // For now, move to step 8
      _handleStepChange(ConfirmV2Step.step8);
    } catch (e, stack) {
      log('[confirm_v2.dart][_handleStep7Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step7, error: 'Fejl i step 7: $e');
    }
  }

  /// Handle Step 8 process
  Future<void> _handleStep8Process() async {
    try {
      log('[confirm_v2.dart][_handleStep8Process] Processing step 8');
      // TODO: Add step 8 specific logic here
      // For now, reset to step 1 (or show completion)
      _resetWidget();
    } catch (e, stack) {
      log('[confirm_v2.dart][_handleStep8Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step8, error: 'Fejl i step 8: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    log('[confirm_v2.dart][build] Building with step: $currentStep');

    // Lyt til realtime opdateringer hvis vi er i step 2 eller step 4
    if ((currentStep == ConfirmV2Step.step2 || currentStep == ConfirmV2Step.step4) && confirmPayload != null) {
      final realtimeData = ref.watch(confirmsRealtimeNotifierProvider(confirmPayload!.confirmsId));

      realtimeData.when(
        data: (data) {
          if (data != null) {
            // Check hvis status er ændret til 5 fra step 2
            if (currentStep == ConfirmV2Step.step2 && data.status == 5) {
              log('[confirm_v2.dart][build] Status changed to 5, moving to step 5');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleStepChange(ConfirmV2Step.step5);
              });
            }
            // Check hvis status er ændret til 7 fra step 4
            else if (currentStep == ConfirmV2Step.step4 && data.status == 7) {
              log('[confirm_v2.dart][build] Status changed to 7, moving to step 7');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleStepChange(ConfirmV2Step.step7);
              });
            }
          }
        },
        loading: () {
          log('[confirm_v2.dart][build] Loading realtime data');
        },
        error: (error, stack) {
          log('[confirm_v2.dart][build] Realtime error: $error');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStepChange(ConfirmV2Step.step1, error: 'Realtime fejl: $error');
          });
        },
      );
    }

    return Container(
      padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Debug info (kan fjernes senere)
          if (errorMessage != null)
            Container(
              padding: EdgeInsets.all(AppDimensionsTheme.getSmall(context)),
              margin: EdgeInsets.only(bottom: AppDimensionsTheme.getMedium(context)),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: CustomText(
                text: errorMessage!,
                type: CustomTextType.bread,
                alignment: CustomTextAlignment.center,
              ),
            ),

          // Step content
          _buildStepContent(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case ConfirmV2Step.step1:
        return ConfirmV2Step1(
          contactsId: widget.contactsId,
          onStartConfirm: _startConfirmProcess,
          errorMessage: errorMessage,
        );

      case ConfirmV2Step.step2:
        if (confirmPayload == null) {
          return Center(
            child: CustomText(
              text: 'Ingen bekræftelsesdata tilgængelig',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
          );
        }
        return ConfirmV2Step2(
          confirmPayload: confirmPayload!,
          onNext: _handleStep2Process,
          onReset: _resetWidget,
          onStepChange: _handleStepChange,
        );

      case ConfirmV2Step.step3:
        if (confirmPayload == null) {
          return Center(
            child: CustomText(
              text: 'Ingen bekræftelsesdata tilgængelig',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
          );
        }
        return ConfirmV2Step3(
          confirmPayload: confirmPayload!,
          onNext: _handleStep3Process,
          onReset: _resetWidget,
        );

      case ConfirmV2Step.step4:
        if (confirmPayload == null) {
          return Center(
            child: CustomText(
              text: 'Ingen bekræftelsesdata tilgængelig',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
          );
        }
        return ConfirmV2Step4(
          confirmPayload: confirmPayload!,
          onNext: _handleStep4Process,
          onReset: _resetWidget,
        );

      case ConfirmV2Step.step5:
        if (confirmPayload == null) {
          return Center(
            child: CustomText(
              text: 'Ingen bekræftelsesdata tilgængelig',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
          );
        }
        return ConfirmV2Step5(
          confirmPayload: confirmPayload!,
          onNext: _handleStep5Process,
          onReset: _resetWidget,
          onAutoProcess: _handleStep5Process,
        );

      case ConfirmV2Step.step6:
        if (confirmPayload == null) {
          return Center(
            child: CustomText(
              text: 'Ingen bekræftelsesdata tilgængelig',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
          );
        }
        return ConfirmV2Step6(
          confirmPayload: confirmPayload!,
          onNext: _handleStep6Process,
          onReset: _resetWidget,
        );

      case ConfirmV2Step.step7:
        if (confirmPayload == null) {
          return Center(
            child: CustomText(
              text: 'Ingen bekræftelsesdata tilgængelig',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
          );
        }
        return ConfirmV2Step7(
          confirmPayload: confirmPayload!,
          onNext: _handleStep7Process,
          onReset: _resetWidget,
        );

      case ConfirmV2Step.step8:
        if (confirmPayload == null) {
          return Center(
            child: CustomText(
              text: 'Ingen bekræftelsesdata tilgængelig',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
          );
        }
        return ConfirmV2Step8(
          confirmPayload: confirmPayload!,
          onNext: _handleStep8Process,
          onReset: _resetWidget,
        );
    }
  }
}

// Created on 2025-01-27 at 13:50:00
