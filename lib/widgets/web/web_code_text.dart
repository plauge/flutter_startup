import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../exports.dart';
import '../../providers/web_code_provider.dart';
import '../../models/web_code_receive_response.dart';
import 'package:flutter/services.dart';
import '../../utils/app_logger.dart';

class WebCodeText extends ConsumerStatefulWidget {
  const WebCodeText({super.key});

  @override
  ConsumerState<WebCodeText> createState() => _WebCodeTextState();
}

class _WebCodeTextState extends ConsumerState<WebCodeText> {
  static final log = scopedLogger(LogCategory.other);
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _hasCalledApi = false;
  String _webCodesId = '';
  String? _inputError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleClipboardButton() async {
    AppLogger.logSeparator('_handleClipboardButton');
    setState(() {
      _isLoading = true;
      _inputError = null;
    });
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardTextRaw = clipboardData?.text;
      final clipboardTextTrimmed = clipboardTextRaw?.trim();
      final clipboardText = clipboardTextTrimmed?.replaceAll(RegExp(r'\s+'), '');
      log('[web/web_code_text.dart][_handleClipboardButton] Clipboard raw: "$clipboardTextRaw"');
      log('[web/web_code_text.dart][_handleClipboardButton] Clipboard trimmed: "$clipboardTextTrimmed"');
      log('[web/web_code_text.dart][_handleClipboardButton] Clipboard no-whitespace: "$clipboardText"');
      if (clipboardText != null && clipboardText.isNotEmpty) {
        _codeController.text = clipboardText;
        setState(() {
          _isLoading = false;
        });
        log('[web/web_code_text.dart][_handleClipboardButton] Clipboard value sat i inputfelt: $clipboardText');
      } else {
        setState(() {
          _isLoading = false;
          _inputError = 'Ingen kode fundet i clipboard';
        });
        CustomSnackBar.show(
          context: context,
          text: 'Ingen kode fundet i clipboard',
          type: CustomTextType.head,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        log('[web/web_code_text.dart][_handleClipboardButton] Clipboard was empty');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('[web/web_code_text.dart][_handleClipboardButton] Error reading clipboard: $e');
    }
  }

  Future<void> _startTestButton() async {
    AppLogger.logSeparator('_startTestButton');
    final input = _codeController.text.trim().replaceAll(RegExp(r'\s+'), '');
    log('[web/web_code_text.dart][_startTestButton] Inputfelt værdi: "$input"');
    if (input.isEmpty) {
      setState(() {
        _inputError = 'Feltet må ikke være tomt';
      });
      CustomSnackBar.show(
        context: context,
        text: 'Feltet må ikke være tomt',
        type: CustomTextType.head,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      log('[web/web_code_text.dart][_startTestButton] Feltet er tomt');
      return;
    }

    setState(() {
      _webCodesId = input;
      _hasCalledApi = true;
      _isLoading = true;
      _inputError = null;
    });
    log('[web/web_code_text.dart][_startTestButton] Starter API-kald med: $_webCodesId');
  }

  void _resetState() {
    setState(() {
      _isLoading = false;
      _hasCalledApi = false;
    });
    log('[web/web_code_text.dart][_resetState] State reset');
  }

  // Funktion til at åbne browser med den sammensatte URL
  Future<void> _openBrowser(WebCodePayload payload) async {
    AppLogger.logSeparator('_openBrowser');
    final url = '${payload.domain}${payload.encryptedUrlPath}';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        log('[web/web_code_text.dart][_openBrowser] Launched URL: $url');
      } else {
        log('[web/web_code_text.dart][_openBrowser] Could not launch $url');
      }
    } catch (e) {
      log('[web/web_code_text.dart][_openBrowser] Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logSeparator('web/web_code_text.dart');
    // Kun kald provideren når vi har kaldt API'en

    log('[web/web_code_text.dart][build] _webCodesId: $_webCodesId');
    final webCodeResult = _hasCalledApi ? ref.watch(receiveWebCodeProvider(webCodesId: _webCodesId)) : null;

    log('[web/web_code_text.dart][build] webCodeResult: $webCodeResult');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          text: 'Test a website og shop',
          type: CustomTextType.head,
        ),
        const Gap(16),
        CustomText(
          text: 'Dette er en test',
          type: CustomTextType.bread,
        ),
        const Gap(24),
        if (!_hasCalledApi) ...[
          CustomText(
            text: 'Indsæt eller indsæt kode fra clipboard',
            type: CustomTextType.label,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _codeController,
                  labelText: 'Indsæt kode',
                  errorText: _inputError,
                  onChanged: (value) {
                    setState(() {
                      _inputError = null;
                    });
                  },
                ),
              ),
              Gap(AppDimensionsTheme.getSmall(context)),
              IconButton(
                onPressed: _handleClipboardButton,
                icon: const Icon(Icons.paste),
                tooltip: 'Indsæt fra clipboard',
              ),
            ],
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          Opacity(
            opacity: _codeController.text.isNotEmpty ? 1.0 : 0.5,
            child: IgnorePointer(
              ignoring: _codeController.text.isEmpty,
              child: CustomButton(
                onPressed: () {
                  _startTestButton();
                },
                text: 'Start test',
                buttonType: CustomButtonType.primary,
              ),
            ),
          ),
        ] else if (_isLoading && webCodeResult == null)
          // Loading state
          const Center(child: CircularProgressIndicator())
        else
          // Result state
          webCodeResult!.when(
            data: (data) {
              // Stop loading when data is received
              if (_isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _isLoading = false;
                  });
                });
              }

              if (data.isNotEmpty && data.first.statusCode == 200) {
                // Success case - status code 200
                final responseData = data.first.data;
                final payload = responseData.payload; // Henter payload data
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: responseData.message,
                      type: CustomTextType.head,
                    ),
                    const Gap(16),
                    CustomText(
                      text: 'Success: ${responseData.success}',
                      type: CustomTextType.bread,
                    ),
                    const Gap(16),
                    // Vis payload data
                    CustomText(
                      text: 'Payload Data:',
                      type: CustomTextType.head,
                    ),
                    const Gap(8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Domain: ${payload.domain}',
                          type: CustomTextType.bread,
                        ),
                        CustomText(
                          text: 'Created At: ${payload.createdAt}',
                          type: CustomTextType.bread,
                        ),
                        CustomText(
                          text: 'Web Codes ID: ${payload.webCodesId}',
                          type: CustomTextType.bread,
                        ),
                        CustomText(
                          text: 'Customer Name: ${payload.customerName}',
                          type: CustomTextType.bread,
                        ),
                        CustomText(
                          text: 'Customer User ID: ${payload.customerUserId}',
                          type: CustomTextType.bread,
                        ),
                        CustomText(
                          text: 'Receiver User ID: ${payload.receiverUserId}',
                          type: CustomTextType.bread,
                        ),
                      ],
                    ),
                    const Gap(24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed: () {
                              // Åbn browser med sammensat URL
                              _openBrowser(payload);
                            },
                            text: 'Confirm',
                            buttonType: CustomButtonType.primary,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: CustomButton(
                            onPressed: _resetState,
                            text: 'New test',
                            buttonType: CustomButtonType.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Error case - status code not 200
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Unknown website og shop',
                      type: CustomTextType.head,
                    ),
                    // const Gap(16),
                    // CustomText(
                    //   text: 'Error: $error',
                    //   type: CustomTextType.bread,
                    // ),
                    const Gap(24),
                    CustomButton(
                      onPressed: _resetState,
                      text: 'New test',
                      buttonType: CustomButtonType.secondary,
                    ),
                  ],
                );
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) {
              // Stop loading when error is received
              if (_isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _isLoading = false;
                  });
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Unknown website og shop',
                    type: CustomTextType.head,
                  ),
                  // const Gap(16),
                  // CustomText(
                  //   text: 'Error: $error',
                  //   type: CustomTextType.bread,
                  // ),
                  const Gap(24),
                  CustomButton(
                    onPressed: _resetState,
                    text: 'New test',
                    buttonType: CustomButtonType.secondary,
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

// Created: 2023-10-02 16:45:00
