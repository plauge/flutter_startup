import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../exports.dart';
import '../../providers/web_code_provider.dart';
import '../../models/web_code_receive_response.dart';
import 'package:flutter/services.dart';
import '../../utils/app_logger.dart';
import '../../providers/get_domain_owner_provider.dart';
import '../../models/get_domain_owner_response.dart';

class WebDomainSearch extends ConsumerStatefulWidget {
  const WebDomainSearch({super.key});

  @override
  ConsumerState<WebDomainSearch> createState() => _WebDomainSearchState();
}

class _WebDomainSearchState extends ConsumerState<WebDomainSearch> {
  static final log = scopedLogger(LogCategory.other);
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _hasCalledApi = false;
  String _inputDomain = '';
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
      log('[web/web_domain_search.dart][_handleClipboardButton] Clipboard raw: "$clipboardTextRaw"');
      log('[web/web_domain_search.dart][_handleClipboardButton] Clipboard trimmed: "$clipboardTextTrimmed"');
      log('[web/web_domain_search.dart][_handleClipboardButton] Clipboard no-whitespace: "$clipboardText"');
      if (clipboardText != null && clipboardText.isNotEmpty) {
        _codeController.text = clipboardText;
        setState(() {
          _isLoading = false;
        });
        log('[web/web_domain_search.dart][_handleClipboardButton] Clipboard value sat i inputfelt: $clipboardText');
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
        log('[web/web_domain_search.dart][_handleClipboardButton] Clipboard was empty');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('[web/web_domain_search.dart][_handleClipboardButton] Error reading clipboard: $e');
    }
  }

  Future<void> _startTestButton() async {
    AppLogger.logSeparator('_startTestButton');
    final input = _codeController.text.trim().replaceAll(RegExp(r'\s+'), '');
    log('[web/web_domain_search.dart][_startTestButton] Inputfelt værdi: "$input"');
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
      log('[web/web_domain_search.dart][_startTestButton] Feltet er tomt');
      return;
    }

    setState(() {
      _inputDomain = input;
      _hasCalledApi = true;
      _isLoading = true;
      _inputError = null;
    });
    log('[web/web_domain_search.dart][_startTestButton] Starter API-kald med: $_inputDomain');
  }

  void _resetState() {
    setState(() {
      _isLoading = false;
      _hasCalledApi = false;
    });
    log('[web/web_domain_search.dart][_resetState] State reset');
  }

  // Funktion til at åbne browser med den sammensatte URL
  Future<void> _openBrowser(WebCodePayload payload) async {
    AppLogger.logSeparator('_openBrowser');
    // Byg URL korrekt med Uri
    var domain = payload.domain;
    if (!domain.startsWith('http://') && !domain.startsWith('https://')) {
      domain = 'https://$domain';
    }
    domain = domain.endsWith('/') ? domain.substring(0, domain.length - 1) : domain;
    final path = payload.encryptedUrlPath.startsWith('/') ? payload.encryptedUrlPath : '/${payload.encryptedUrlPath}';
    final url = '$domain$path';
    final uri = Uri.parse(url);
    log('[web/web_domain_search.dart][_openBrowser] URL: $url');
    log('[web/web_domain_search.dart][_openBrowser] Uri: $uri');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        log('[web/web_domain_search.dart][_openBrowser] Launched URL: $url');
      } else {
        log('[web/web_domain_search.dart][_openBrowser] Could not launch $url');
      }
    } catch (e) {
      log('[web/web_domain_search.dart][_openBrowser] Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logSeparator('web/web_domain_search.dart');
    // Kun kald provideren når vi har kaldt API'en

    log('[web/web_domain_search.dart][build] _inputDomain: $_inputDomain');
    final domainOwnerResult = _hasCalledApi ? ref.watch(getDomainOwnerNotifierProvider(_inputDomain)) : null;

    log('[web/web_domain_search.dart][build] domainOwnerResult: $domainOwnerResult');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          text: 'Test domæne',
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
            text: 'Indsæt eller indsæt link fra clipboard',
            type: CustomTextType.label,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _codeController,
                  labelText: 'Indsæt link',
                  errorText: _inputError,
                  onChanged: (value) {
                    setState(() {
                      _inputError = null;
                    });
                  },
                ),
              ),
              Gap(AppDimensionsTheme.getSmall(context)),
              SizedBox(
                width: 148,
                child: CustomButton(
                  onPressed: _handleClipboardButton,
                  text: 'Indsæt',
                  buttonType: CustomButtonType.orange,
                  icon: Icons.paste,
                ),
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
        ] else if (_isLoading && domainOwnerResult == null)
          // Loading state
          const Center(child: CircularProgressIndicator())
        else
          // Result state
          domainOwnerResult!.when(
            data: (data) {
              // Stop loading when data is received
              if (_isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _isLoading = false;
                  });
                });
              }

              if (data.statusCode == 200) {
                // Success case - status code 200
                final responseData = data.data;
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
                          text: 'Status: ${payload.status}',
                          type: CustomTextType.bread,
                        ),
                        CustomText(
                          text: 'Trust Level: ${payload.trustLevel}',
                          type: CustomTextType.bread,
                        ),
                        CustomText(
                          text: 'Validated At: ${payload.validatedAt}',
                          type: CustomTextType.bread,
                        ),
                        CustomText(
                          text: 'Customer Name: ${payload.customerName}',
                          type: CustomTextType.bread,
                        ),
                      ],
                    ),
                    const Gap(24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed: _resetState,
                            text: 'Ny test',
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
                      text: 'Ukendt domæne',
                      type: CustomTextType.head,
                    ),
                    const Gap(24),
                    CustomButton(
                      onPressed: _resetState,
                      text: 'Ny test',
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
                    text: 'Ukendt domæne',
                    type: CustomTextType.head,
                  ),
                  const Gap(24),
                  CustomButton(
                    onPressed: _resetState,
                    text: 'Test igen',
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

// Created: 2024-06-07 13:00:00
