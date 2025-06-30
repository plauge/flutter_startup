import '../../exports.dart';
import 'dart:math';
import 'steps/confirm_v2_step1.dart';
import 'steps/confirm_v2_step2.dart';
import 'steps/confirm_v2_step3.dart';

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
  static final log = scopedLogger(LogCategory.gui);

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
        );

        log('[confirm_v2.dart][_startConfirmProcess] ConfirmPayload created successfully');

        // Gå til step 2
        _handleStepChange(ConfirmV2Step.step2, newPayload: confirmData);
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e, stack) {
      log('[confirm_v2.dart][_startConfirmProcess] Error: $e, Stack: $stack');
      _handleStepChange(ConfirmV2Step.step1, error: 'Fejl ved start af bekræftelse: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    log('[confirm_v2.dart][build] Building with step: $currentStep');

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
          onReset: _resetWidget,
        );
    }
  }
}

// Created on 2025-01-27 at 13:50:00
