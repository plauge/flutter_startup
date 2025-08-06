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
import 'dart:async';

// Dokumentation : https://docs.google.com/document/d/1GNXeWrz8iwDJsOJ1yH7WaPA5NKHVa7AJf_HpSuxuDiQ/edit?tab=t.0

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
    log('[widget_confirm_v2.dart][initState] Initializing ConfirmV2 for contactsId: ${widget.contactsId}');
  }

  /// Genererer random tal-par som kommasepareret string
  String _generateRandomQuestion() {
    final random = Random();
    final firstNumber = random.nextInt(9) + 1; // 1-9999999
    final secondNumber = random.nextInt(9) + 1; // 1-9999999
    final question = '$firstNumber, $secondNumber';
    log('[widget_confirm_v2.dart][_generateRandomQuestion] Generated question: $question');
    return question;
  }

  /// Beregner summen direkte fra ukrypteret spørgsmål (brugt i _startConfirmProcess)
  String _calculateQuestionSumDirect(String questionString) {
    try {
      log('[widget_confirm_v2.dart][_calculateQuestionSumDirect] Calculating sum for: "$questionString"');

      final parts = questionString.split(', ');
      if (parts.length != 2) {
        log('[widget_confirm_v2.dart][_calculateQuestionSumDirect] ERROR: Invalid question format - expected 2 parts, got ${parts.length}');
        return '0';
      }

      final firstNumber = int.parse(parts[0].trim());
      final secondNumber = int.parse(parts[1].trim());
      final sum = firstNumber + secondNumber;

      log('[widget_confirm_v2.dart][_calculateQuestionSumDirect] Calculated: $firstNumber + $secondNumber = $sum');
      return sum.toString();
    } catch (e, stackTrace) {
      log('[widget_confirm_v2.dart][_calculateQuestionSumDirect] Error: $e');
      return '0';
    }
  }

  /// Lægger to tal sammen fra kommasepareret string og returnerer resultatet som string
  Future<String> _calculateQuestionSum(String questionString) async {
    AppLogger.logSeparator('CALCULATE QUESTION SUM');
    try {
      log('[widget_confirm_v2.dart][_calculateQuestionSum] === STARTING CALCULATION ===');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Input questionString: "$questionString"');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] QuestionString length: ${questionString.length}');

      // Hent token til dekryptering
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Fetching token from storage...');
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();
      if (token == null) {
        log('[widget_confirm_v2.dart][_calculateQuestionSum] ERROR: No token available for decryption');
        throw Exception(I18nService().t('widget_confirm_v2.no_token_decryption', fallback: 'No token available for decryption'));
      }

      log('[widget_confirm_v2.dart][_calculateQuestionSum] Token retrieved successfully');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Token length: ${token.length}');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Full token: "$token"');

      // Dekrypter questionString før split
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Starting decryption with:');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] - questionString: "$questionString"');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] - token: "$token"');

      final decryptedQuestion = await AESGCMEncryptionUtils.decryptString(questionString, token);

      log('[widget_confirm_v2.dart][_calculateQuestionSum] Decryption completed successfully!');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Decrypted question: "$decryptedQuestion"');

      final parts = decryptedQuestion.split(', ');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Split parts: $parts (count: ${parts.length})');

      if (parts.length != 2) {
        log('[widget_confirm_v2.dart][_calculateQuestionSum] ERROR: Invalid question format - expected 2 parts, got ${parts.length}');
        throw Exception('Invalid question format: $decryptedQuestion');
      }

      final firstNumber = int.parse(parts[0].trim());
      final secondNumber = int.parse(parts[1].trim());
      final sum = firstNumber + secondNumber;

      log('[widget_confirm_v2.dart][_calculateQuestionSum] Parsed: first=$firstNumber, second=$secondNumber');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Calculated sum: $firstNumber + $secondNumber = $sum');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] === CALCULATION COMPLETED ===');

      return sum.toString();
    } catch (e, stackTrace) {
      log('[widget_confirm_v2.dart][_calculateQuestionSum] === ERROR OCCURRED ===');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Error: $e');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] Stack: $stackTrace');
      log('[widget_confirm_v2.dart][_calculateQuestionSum] === RETURNING FALLBACK VALUE: 0 ===');
      return '0';
    }
  }

  /// Sammenligner to strings og returnerer true hvis de er 100% identiske
  bool _compareQuestions(String myQuestion, String controlQuestion) {
    final isMatch = myQuestion == controlQuestion;
    log('[widget_confirm_v2.dart][_compareQuestions] Comparing "$myQuestion" with "$controlQuestion": $isMatch');
    return isMatch;
  }

  /// Udfører sammenligningen mellem encrypted_receiver_answer og question
  Future<String> _performStep6Comparison() async {
    if (confirmPayload?.encryptedReceiverAnswer == null || confirmPayload?.question == null) {
      log('[widget_confirm_v2.dart][_performStep6Comparison] Missing data for comparison');
      return 'ERROR';
    }

    final calculatedSum = await _calculateQuestionSum(confirmPayload!.encryptedReceiverAnswer!);
    final question = confirmPayload!.question!;
    final result = calculatedSum == question ? 'OK' : 'ERROR';

    log('[widget_confirm_v2.dart][_performStep6Comparison] Comparing calculated sum "$calculatedSum" with question "$question": $result');
    _scheduleConfirmsDelete();
    return result;
  }

  /// Udfører sammenligningen mellem encrypted_initiator_answer og question
  Future<String> _performStep7Comparison() async {
    if (confirmPayload?.encryptedInitiatorAnswer == null || confirmPayload?.question == null) {
      log('[widget_confirm_v2.dart][_performStep7Comparison] Missing data for comparison');
      return 'ERROR';
    }

    final calculatedSum = await _calculateQuestionSum(confirmPayload!.encryptedInitiatorAnswer!);
    final question = confirmPayload!.question!;
    final result = calculatedSum == question ? 'OK' : 'ERROR';

    log('[widget_confirm_v2.dart][_performStep7Comparison] Comparing calculated sum "$calculatedSum" with question "$question": $result');

    // Kald confirmsDelete med 2 sekunders delay efter sammenligningen
    _scheduleConfirmsDelete();

    return result;
  }

  /// Kalder confirmsDelete med 2 sekunders delay
  void _scheduleConfirmsDelete() {
    Timer(const Duration(seconds: 2), () async {
      try {
        log('[widget_confirm_v2.dart][_scheduleConfirmsDelete] Calling confirmsDelete after 2 second delay');
        await ref.read(confirmsConfirmProvider.notifier).confirmsDelete(contactsId: widget.contactsId);
        log('[widget_confirm_v2.dart][_scheduleConfirmsDelete] confirmsDelete completed successfully');
      } catch (e, stack) {
        log('[widget_confirm_v2.dart][_scheduleConfirmsDelete] Error calling confirmsDelete: $e, Stack: $stack');
      }
    });
  }

  /// Håndterer tilstandsændringer og step navigation
  void _handleStepChange(ConfirmV2Step newStep, {ConfirmPayload? newPayload, String? error}) {
    log('[widget_confirm_v2.dart][_handleStepChange] Changing from $currentStep to $newStep');

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
    log('[widget_confirm_v2.dart][_resetWidget] Resetting widget to initial state');
    setState(() {
      currentStep = ConfirmV2Step.step1;
      confirmPayload = null;
      errorMessage = null;
    });
  }

  /// Start confirm process (til Step 1)
  Future<void> _startConfirmProcess() async {
    try {
      log('[widget_confirm_v2.dart][_startConfirmProcess] Starting confirm process');

      final question = _generateRandomQuestion();

      // Hent token til kryptering
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();
      if (token == null) {
        throw Exception(I18nService().t('widget_confirm_v2.no_token_encryption', fallback: 'No token available for encryption'));
      }

      // Krypter question før transmission
      final encryptedQuestion = await AESGCMEncryptionUtils.encryptString(question, token);
      log('[widget_confirm_v2.dart][_startConfirmProcess] Question encrypted successfully');

      // Kald confirm() funktionen fra ConfirmsConfirm provider
      final response = await ref.read(confirmsConfirmProvider.notifier).confirm(
            contactsId: widget.contactsId,
            question: encryptedQuestion,
          );

      log('[widget_confirm_v2.dart][_startConfirmProcess] Response received: $response');

      // Parse response til ConfirmPayload
      if (response['status_code'] == 200 && response['data'] != null) {
        final payload = response['data']['payload'] as Map<String, dynamic>;

        final confirmData = ConfirmPayload(
          confirmsId: payload['confirms_id'],
          createdAt: DateTime.now(),
          status: payload['status'],
          contactsId: widget.contactsId,
          question: _calculateQuestionSumDirect(question),
          newRecord: payload['new_record'],
        );

        log('[widget_confirm_v2.dart][_startConfirmProcess] ConfirmPayload created successfully');
        log('[widget_confirm_v2.dart][_startConfirmProcess] new_record value: ${payload['new_record']}');

        if (payload['new_record'] == true) {
          log('[widget_confirm_v2.dart][_startConfirmProcess] Taking new_record=true branch - going to step 2');
          // Gå til step 2 - ny record
          _handleStepChange(ConfirmV2Step.step2, newPayload: confirmData);
        } else {
          log('[widget_confirm_v2.dart][_startConfirmProcess] Taking new_record=false branch - setting confirmPayload first');
          // Sæt confirmPayload FØRST så _callWatchAndUpdatePayload kan bruge den
          confirmPayload = confirmData;

          log('[widget_confirm_v2.dart][_startConfirmProcess] Calling _callWatchAndUpdatePayload');
          // Kald den nye funktion for at opdatere payload
          await _callWatchAndUpdatePayload();
          log('[widget_confirm_v2.dart][_startConfirmProcess] _callWatchAndUpdatePayload completed - going to step 3');
          // Gå til step 3 - eksisterende record
          _handleStepChange(ConfirmV2Step.step3, newPayload: confirmPayload!);
          // Kald automatisk step 3 process
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStep3Process();
          });
        }
      } else {
        throw Exception(I18nService().t('widget_confirm_v2.invalid_server_response', fallback: 'Invalid response from server'));
      }
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_startConfirmProcess] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step1, error: I18nService().t('widget_confirm_v2.error_start_confirmation', fallback: 'Error starting confirmation: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Handle Step 2 process - manual step transition
  Future<void> _handleStep2Process() async {
    try {
      log('[widget_confirm_v2.dart][_handleStep2Process] Manual step 2 process - moving to step 5');
      _handleStepChange(ConfirmV2Step.step5);
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_handleStep2Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step2, error: I18nService().t('widget_confirm_v2.error_step_2', fallback: 'Error in step 2: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Handle Step 3 process
  Future<void> _handleStep3Process() async {
    try {
      log('[widget_confirm_v2.dart][_handleStep3Process] Processing step 3');

      if (confirmPayload == null) {
        throw Exception(I18nService().t('widget_confirm_v2.confirm_payload_null', fallback: 'Confirmation data is null'));
      }

      log('[widget_confirm_v2.dart][_handleStep3Process] Calling confirmsRecieverUpdate with answer: ${confirmPayload!.encryptedInitiatorQuestion}, confirmsId: ${confirmPayload!.confirmsId}');

      final response = await ref.read(confirmsConfirmProvider.notifier).confirmsRecieverUpdate(
            answer: confirmPayload!.encryptedInitiatorQuestion ?? "",
            confirmsId: confirmPayload!.confirmsId,
          );

      log('[widget_confirm_v2.dart][_handleStep3Process] confirmsRecieverUpdate response received: $response');

      // Tjek for success før vi går videre
      if (response['status_code'] == 200) {
        // Gå til step 4 efter succesfuldt svar
        _handleStepChange(ConfirmV2Step.step4);
      } else {
        // Håndter fejl fra server
        final message = response['data']?['message'] ?? I18nService().t('widget_confirm_v2.unknown_error', fallback: 'Unknown error');
        throw Exception(I18nService().t('widget_confirm_v2.server_error', fallback: 'Server error (\$status_code): \$message', variables: {'status_code': response['status_code'].toString(), 'message': message}));
      }
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_handleStep3Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step3, error: I18nService().t('widget_confirm_v2.error_step_3', fallback: 'Error in step 3: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Handle Step 4 process
  Future<void> _handleStep4Process() async {
    try {
      log('[widget_confirm_v2.dart][_handleStep4Process] Processing step 4');
      // TODO: Add step 4 specific logic here
      // For now, move to step 5
      _handleStepChange(ConfirmV2Step.step5);
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_handleStep4Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step4, error: I18nService().t('widget_confirm_v2.error_step_4', fallback: 'Error in step 4: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Handle Step 5 process
  Future<void> _handleStep5Process() async {
    try {
      log('[widget_confirm_v2.dart][_handleStep5Process] Processing step 5');

      if (confirmPayload == null) {
        throw Exception(I18nService().t('widget_confirm_v2.confirm_payload_null', fallback: 'Confirmation data is null'));
      }

      log('[widget_confirm_v2.dart][_handleStep5Process] Calling confirmsInitiatorUpdate with answer: ${confirmPayload!.encryptedReceiverQuestion}, confirmsId: ${confirmPayload!.confirmsId}');

      final response = await ref.read(confirmsConfirmProvider.notifier).confirmsInitiatorUpdate(
            answer: confirmPayload!.encryptedReceiverQuestion ?? "",
            confirmsId: confirmPayload!.confirmsId,
          );

      log('[widget_confirm_v2.dart][_handleStep5Process] confirmsInitiatorUpdate response received: $response');

      // Tjek for success før vi går videre
      if (response['status_code'] == 200) {
        // Gå til step 6 efter succesfuldt svar
        _handleStepChange(ConfirmV2Step.step6);
      } else {
        // Håndter fejl fra server
        final message = response['data']?['message'] ?? I18nService().t('widget_confirm_v2.unknown_error', fallback: 'Unknown error');
        throw Exception(I18nService().t('widget_confirm_v2.server_error', fallback: 'Server error (\$status_code): \$message', variables: {'status_code': response['status_code'].toString(), 'message': message}));
      }
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_handleStep5Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step5, error: I18nService().t('widget_confirm_v2.error_step_5', fallback: 'Error in step 5: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Handle Step 6 process
  Future<void> _handleStep6Process() async {
    try {
      log('[widget_confirm_v2.dart][_handleStep6Process] Processing step 6');
      // TODO: Add step 6 specific logic here
      // For now, move to step 7
      _handleStepChange(ConfirmV2Step.step7);
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_handleStep6Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step6, error: I18nService().t('widget_confirm_v2.error_step_6', fallback: 'Error in step 6: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Handle Step 7 process
  Future<void> _handleStep7Process() async {
    try {
      log('[widget_confirm_v2.dart][_handleStep7Process] Processing step 7');
      // TODO: Add step 7 specific logic here
      // For now, move to step 8
      _handleStepChange(ConfirmV2Step.step8);
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_handleStep7Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step7, error: I18nService().t('widget_confirm_v2.error_step_7', fallback: 'Error in step 7: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Handle Step 8 process
  Future<void> _handleStep8Process() async {
    try {
      log('[widget_confirm_v2.dart][_handleStep8Process] Processing step 8');
      // TODO: Add step 8 specific logic here
      // For now, reset to step 1 (or show completion)
      _resetWidget();
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_handleStep8Process] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step8, error: I18nService().t('widget_confirm_v2.error_step_8', fallback: 'Error in step 8: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Kald watch og opdater confirmPayload før vi går til step 5
  Future<void> _callWatchAndMoveToStep5() async {
    try {
      log('[widget_confirm_v2.dart][_callWatchAndMoveToStep5] Calling watch before moving to step 5');

      if (confirmPayload == null) {
        throw Exception(I18nService().t('widget_confirm_v2.confirm_payload_null', fallback: 'Confirmation data is null'));
      }

      // Kald watch() funktionen fra ConfirmsWatch provider
      final response = await ref.read(confirmsWatchProvider.notifier).watch(
            confirmsId: confirmPayload!.confirmsId,
          );

      log('[widget_confirm_v2.dart][_callWatchAndMoveToStep5] Watch response received: $response');

      // Parse response og opdater confirmPayload
      if (response['status_code'] == 200 && response['data'] != null) {
        final payload = response['data']['payload'] as Map<String, dynamic>?;

        if (payload != null) {
          // Opdater confirmPayload med de nye data
          final updatedPayload = confirmPayload!.copyWith(
            encryptedReceiverQuestion: payload['encrypted_receiver_question'] as String?,
            encryptedReceiverAnswer: payload['encrypted_receiver_answer'] as String?,
          );

          log('[widget_confirm_v2.dart][_callWatchAndMoveToStep5] Updated confirmPayload with encrypted fields');
          log('[widget_confirm_v2.dart][_callWatchAndMoveToStep5] encrypted_receiver_question: ${updatedPayload.encryptedReceiverQuestion}');
          log('[widget_confirm_v2.dart][_callWatchAndMoveToStep5] encrypted_receiver_answer: ${updatedPayload.encryptedReceiverAnswer}');

          // Gå til step 5 med opdateret payload
          _handleStepChange(ConfirmV2Step.step5, newPayload: updatedPayload);
        } else {
          throw Exception(I18nService().t('widget_confirm_v2.missing_payload_watch', fallback: 'Missing payload in watch response'));
        }
      } else {
        throw Exception(I18nService().t('widget_confirm_v2.invalid_watch_response', fallback: 'Invalid response from watch: \$status_code', variables: {'status_code': response['status_code'].toString()}));
      }
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_callWatchAndMoveToStep5] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step2, error: I18nService().t('widget_confirm_v2.error_watch_call', fallback: 'Error calling watch: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Kald watch og opdater confirmPayload før vi går til step 7
  Future<void> _callWatchAndMoveToStep7() async {
    try {
      log('[widget_confirm_v2.dart][_callWatchAndMoveToStep7] Calling watch before moving to step 7');

      if (confirmPayload == null) {
        throw Exception(I18nService().t('widget_confirm_v2.confirm_payload_null', fallback: 'Confirmation data is null'));
      }

      // Kald watch() funktionen fra ConfirmsWatch provider
      final response = await ref.read(confirmsWatchProvider.notifier).watch(
            confirmsId: confirmPayload!.confirmsId,
          );

      log('[widget_confirm_v2.dart][_callWatchAndMoveToStep7] Watch response received: $response');

      // Parse response og opdater confirmPayload
      if (response['status_code'] == 200 && response['data'] != null) {
        final payload = response['data']['payload'] as Map<String, dynamic>?;

        if (payload != null) {
          // Opdater confirmPayload med de nye data - denne gang initiator felterne
          final updatedPayload = confirmPayload!.copyWith(
            encryptedInitiatorQuestion: payload['encrypted_initiator_question'] as String?,
            encryptedInitiatorAnswer: payload['encrypted_initiator_answer'] as String?,
          );

          log('[widget_confirm_v2.dart][_callWatchAndMoveToStep7] Updated confirmPayload with encrypted initiator fields');
          log('[widget_confirm_v2.dart][_callWatchAndMoveToStep7] encrypted_initiator_question: ${updatedPayload.encryptedInitiatorQuestion}');
          log('[widget_confirm_v2.dart][_callWatchAndMoveToStep7] encrypted_initiator_answer: ${updatedPayload.encryptedInitiatorAnswer}');

          // Gå til step 7 med opdateret payload
          _handleStepChange(ConfirmV2Step.step7, newPayload: updatedPayload);
        } else {
          throw Exception(I18nService().t('widget_confirm_v2.missing_payload_watch', fallback: 'Missing payload in watch response'));
        }
      } else {
        throw Exception(I18nService().t('widget_confirm_v2.invalid_watch_response', fallback: 'Invalid response from watch: \$status_code', variables: {'status_code': response['status_code'].toString()}));
      }
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_callWatchAndMoveToStep7] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step4, error: I18nService().t('widget_confirm_v2.error_watch_call', fallback: 'Error calling watch: \$error', variables: {'error': e.toString()}));
    }
  }

  /// Kald watch og opdater confirmPayload uden at ændre step
  Future<void> _callWatchAndUpdatePayload() async {
    try {
      log('[widget_confirm_v2.dart][_callWatchAndUpdatePayload] Calling watch to update payload');

      if (confirmPayload == null) {
        throw Exception(I18nService().t('widget_confirm_v2.confirm_payload_null', fallback: 'Confirmation data is null'));
      }

      // Kald watch() funktionen fra ConfirmsWatch provider
      final response = await ref.read(confirmsWatchProvider.notifier).watch(
            confirmsId: confirmPayload!.confirmsId,
          );

      log('[widget_confirm_v2.dart][_callWatchAndUpdatePayload] Watch response received: $response');

      // Parse response og opdater confirmPayload
      if (response['status_code'] == 200 && response['data'] != null) {
        final payload = response['data']['payload'] as Map<String, dynamic>?;

        if (payload != null) {
          // Opdater confirmPayload med de nye data
          final updatedPayload = confirmPayload!.copyWith(
            encryptedInitiatorQuestion: payload['encrypted_initiator_question'] as String?,
            encryptedInitiatorAnswer: payload['encrypted_initiator_answer'] as String?,
            encryptedReceiverQuestion: payload['encrypted_receiver_question'] as String?,
            encryptedReceiverAnswer: payload['encrypted_receiver_answer'] as String?,
          );

          log('[widget_confirm_v2.dart][_callWatchAndUpdatePayload] Updated confirmPayload with encrypted fields');
          log('[widget_confirm_v2.dart][_callWatchAndUpdatePayload] encrypted_initiator_question: ${updatedPayload.encryptedInitiatorQuestion}');
          log('[widget_confirm_v2.dart][_callWatchAndUpdatePayload] encrypted_initiator_answer: ${updatedPayload.encryptedInitiatorAnswer}');
          log('[widget_confirm_v2.dart][_callWatchAndUpdatePayload] encrypted_receiver_question: ${updatedPayload.encryptedReceiverQuestion}');
          log('[widget_confirm_v2.dart][_callWatchAndUpdatePayload] encrypted_receiver_answer: ${updatedPayload.encryptedReceiverAnswer}');

          // Opdater confirmPayload uden at ændre step
          setState(() {
            confirmPayload = updatedPayload;
          });
        } else {
          throw Exception(I18nService().t('widget_confirm_v2.missing_payload_watch', fallback: 'Missing payload in watch response'));
        }
      } else {
        throw Exception(I18nService().t('widget_confirm_v2.invalid_watch_response', fallback: 'Invalid response from watch: \$status_code', variables: {'status_code': response['status_code'].toString()}));
      }
    } catch (e, stack) {
      log('[widget_confirm_v2.dart][_callWatchAndUpdatePayload] Error: $e, Stack: $stack');
      setState(() {
        errorMessage = I18nService().t('widget_confirm_v2.error_watch_call', fallback: 'Error calling watch: \$error', variables: {'error': e.toString()});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log('[widget_confirm_v2.dart][build] Building with step: $currentStep');

    // Lyt til realtime opdateringer hvis vi er i step 2 eller step 4
    if ((currentStep == ConfirmV2Step.step2 || currentStep == ConfirmV2Step.step4) && confirmPayload != null) {
      final realtimeData = ref.watch(confirmsRealtimeNotifierProvider(confirmPayload!.confirmsId));

      realtimeData.when(
        data: (data) {
          if (data != null) {
            // if (data.status == 0) {
            //   // reset widget
            //   _resetWidget();
            // }
            // Check hvis status er ændret til 5 fra step 2
            if (currentStep == ConfirmV2Step.step2 && data.status == 5) {
              log('[widget_confirm_v2.dart][build] Status changed to 5, calling watch before moving to step 5');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _callWatchAndMoveToStep5();
              });
            }
            // Check hvis status er ændret til 7 fra step 4
            else if (currentStep == ConfirmV2Step.step4 && data.status == 7) {
              log('[widget_confirm_v2.dart][build] Status changed to 7, calling watch before moving to step 7');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _callWatchAndMoveToStep7();
              });
            }
          }
        },
        loading: () {
          log('[widget_confirm_v2.dart][build] Loading realtime data');
        },
        error: (error, stack) {
          log('[widget_confirm_v2.dart][build] Realtime error: $error');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStepChange(ConfirmV2Step.step1, error: I18nService().t('widget_confirm_v2.realtime_error', fallback: 'Realtime error: \$error', variables: {'error': error.toString()}));
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
              text: I18nService().t('widget_confirm_v2.no_confirmation_data', fallback: 'No confirmation data available'),
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
              text: I18nService().t('widget_confirm_v2.no_confirmation_data', fallback: 'No confirmation data available'),
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
              text: I18nService().t('widget_confirm_v2.no_confirmation_data', fallback: 'No confirmation data available'),
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
              text: I18nService().t('widget_confirm_v2.no_confirmation_data', fallback: 'No confirmation data available'),
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
              text: I18nService().t('widget_confirm_v2.no_confirmation_data', fallback: 'No confirmation data available'),
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
          );
        }
        return ConfirmV2Step6(
          confirmPayload: confirmPayload!,
          onNext: _handleStep6Process,
          onReset: _resetWidget,
          comparisonResult: _performStep6Comparison(),
        );

      case ConfirmV2Step.step7:
        if (confirmPayload == null) {
          return Center(
            child: CustomText(
              text: I18nService().t('widget_confirm_v2.no_confirmation_data', fallback: 'No confirmation data available'),
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
          );
        }
        return ConfirmV2Step7(
          confirmPayload: confirmPayload!,
          onNext: _handleStep7Process,
          onReset: _resetWidget,
          comparisonResult: _performStep7Comparison(),
        );

      case ConfirmV2Step.step8:
        if (confirmPayload == null) {
          return Center(
            child: CustomText(
              text: I18nService().t('widget_confirm_v2.no_confirmation_data', fallback: 'No confirmation data available'),
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
