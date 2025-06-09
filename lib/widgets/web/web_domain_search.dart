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
    // Fjern focus fra alle input felter og luk keyboardet
    FocusScope.of(context).unfocus();

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
          type: CustomTextType.button,
          backgroundColor: const Color(0xFF2E7D32),
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

  /// Helper to extract only the domain from a URL or text
  String _extractDomain(String input) {
    log('[web/web_domain_search.dart][_extractDomain] Raw input: "$input"');
    try {
      // Remove protocol if present
      String url = input.trim();
      url = url.replaceFirst(RegExp(r'^https?://'), '');
      url = url.replaceFirst(RegExp(r'^www\.'), '');
      // Split by '/' and take the first part
      final domain = url.split('/').first;
      // Remove port if present
      final cleanDomain = domain.split(':').first;
      log('[web/web_domain_search.dart][_extractDomain] Extracted domain: $cleanDomain');
      return cleanDomain;
    } catch (e) {
      log('[web/web_domain_search.dart][_extractDomain] Error extracting domain: $e');
      return input;
    }
  }

  Future<void> _startTestButton() async {
    // Fjern focus fra alle input felter og luk keyboardet
    FocusScope.of(context).unfocus();

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

    final cleanedDomain = _extractDomain(input);
    log('[web/web_domain_search.dart][_startTestButton] Renset domæne: $cleanedDomain');

    setState(() {
      _inputDomain = cleanedDomain;
      _hasCalledApi = true;
      _isLoading = true;
      _inputError = null;
    });
    log('[web/web_domain_search.dart][_startTestButton] Starter API-kald med: $_inputDomain');
  }

  void _resetState() {
    // Fjern focus fra alle input felter og luk keyboardet
    FocusScope.of(context).unfocus();

    // Ryd inputfeltet
    _codeController.clear();

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

  // Funktion til at åbne verificerings URL
  Future<void> _openVerificationUrl() async {
    // Fjern focus fra alle input felter og luk keyboardet
    FocusScope.of(context).unfocus();

    AppLogger.logSeparator('_openVerificationUrl');
    const url = 'https://idtruster.com/virksomheder/';
    final uri = Uri.parse(url);
    log('[web/web_domain_search.dart][_openVerificationUrl] URL: $url');
    log('[web/web_domain_search.dart][_openVerificationUrl] Uri: $uri');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        log('[web/web_domain_search.dart][_openVerificationUrl] Launched URL: $url');
      } else {
        log('[web/web_domain_search.dart][_openVerificationUrl] Could not launch $url');
      }
    } catch (e) {
      log('[web/web_domain_search.dart][_openVerificationUrl] Error launching URL: $e');
    }
  }

  /// Helper to format date as dd/mm YYYY
  String _formatDateDdMmYyyy(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.tryParse(dateStr);
      if (date == null) return dateStr;
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month $year';
    } catch (e) {
      log('[web/web_domain_search.dart][_formatDateDdMmYyyy] Error: $e');
      return dateStr;
    }
  }

  /// Helper method to get container style based on trust level
  Widget _buildTrustLevelIndicator(int trustLevel) {
    Color backgroundColor;
    IconData iconData;
    double iconSize;

    switch (trustLevel) {
      case 1:
        backgroundColor = Colors.orange;
        iconData = Icons.warning;
        iconSize = 20;
        break;
      case 2:
        backgroundColor = Colors.blue;
        iconData = Icons.info;
        iconSize = 20;
        break;
      case 3:
        backgroundColor = const Color(0xFF2E7D32);
        iconData = Icons.check;
        iconSize = 16;
        break;
      default:
        backgroundColor = Colors.grey;
        iconData = Icons.help;
        iconSize = 20;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  /// Helper method to get main text based on trust level
  String _getTrustLevelMainText(int trustLevel, String domain, String customerName) {
    switch (trustLevel) {
      case 1:
        return '$domain ejes af $customerName - Lav sikkerhed';
      case 2:
        return '$domain ejes af $customerName - Medium sikkerhed';
      case 3:
        return '$domain ejes af $customerName';
      default:
        return '$domain ejes af $customerName';
    }
  }

  /// Helper method to get subtitle text based on trust level
  String _getTrustLevelSubtitleText(int trustLevel, String validatedAt) {
    final formattedDate = _formatDateDdMmYyyy(validatedAt);
    switch (trustLevel) {
      case 1:
        return 'Grundlæggende verifikation gennemført $formattedDate';
      case 2:
        return 'Udvidet verifikation gennemført $formattedDate';
      case 3:
        return 'Ejerskab og adresse er kontrolleret $formattedDate';
      default:
        return 'Ejerskab og adresse er kontrolleret $formattedDate';
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
        // CustomText(
        //   text: 'Tjek ejeren af side',
        //   type: CustomTextType.head,
        // ),
        // const Gap(24),
        CustomText(
          text: 'Indsæt link her',
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
              width: 120,
              child: CustomButton(
                onPressed: _handleClipboardButton,
                text: 'Indsæt',
                buttonType: CustomButtonType.orange,
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
              text: 'Tjek linket',
              buttonType: CustomButtonType.primary,
            ),
          ),
        ),
        const Gap(20),
        // Resultat vises herunder, hvis der er kaldt API
        if (_hasCalledApi)
          Padding(
            padding: EdgeInsets.only(top: AppDimensionsTheme.getLarge(context)),
            child: Builder(
              builder: (context) {
                if (_isLoading && domainOwnerResult == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (domainOwnerResult == null) {
                  return const SizedBox();
                }
                return domainOwnerResult.when(
                  data: (data) {
                    if (_isLoading) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    }
                    if (data.statusCode == 200) {
                      final responseData = data.data;
                      final payload = responseData.payload;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(AppDimensionsTheme.getLarge(context)),
                          Container(
                            padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFF2E7D32), width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTrustLevelIndicator(payload.trustLevel),
                                Gap(AppDimensionsTheme.getSmall(context)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: _getTrustLevelMainText(payload.trustLevel, payload.domain, payload.customerName),
                                        type: CustomTextType.head,
                                      ),
                                      Gap(AppDimensionsTheme.getSmall(context)),
                                      CustomText(
                                        text: _getTrustLevelSubtitleText(payload.trustLevel, payload.validatedAt),
                                        type: CustomTextType.bread,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(AppDimensionsTheme.getLarge(context)),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  onPressed: _resetState,
                                  text: 'Tjek andet link',
                                  buttonType: CustomButtonType.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CustomText(
                          //   text: '⚠️ Vi kender ikke virksomheden bag denne side',
                          //   type: CustomTextType.head,
                          // ),
                          // CustomText(
                          //   text: 'Vi kender ikke til $_inputDomain',
                          //   type: CustomTextType.bread,
                          // ),
                          Container(
                            padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFF2E7D32), width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTrustLevelIndicator(1), // Unknown domain gets trust level 1
                                Gap(AppDimensionsTheme.getSmall(context)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: 'Vi kender ikke til $_inputDomain',
                                        type: CustomTextType.head,
                                      ),
                                      Gap(AppDimensionsTheme.getSmall(context)),
                                      CustomText(
                                        text: 'Vær forsigtig på denne hjemmeside.',
                                        type: CustomTextType.bread,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) {
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
                        Container(
                          padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF2E7D32), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTrustLevelIndicator(1), // Error case gets trust level 1
                              Gap(AppDimensionsTheme.getSmall(context)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: 'Vi kender ikke til $_inputDomain',
                                      type: CustomTextType.head,
                                    ),
                                    Gap(AppDimensionsTheme.getSmall(context)),
                                    CustomText(
                                      text: 'Vær forsigtig på denne hjemmeside.',
                                      type: CustomTextType.bread,
                                    ),
                                    Gap(AppDimensionsTheme.getLarge(context)),
                                    CustomText(
                                      text: 'Er du ejer af $_inputDomain så kan du få verifiseret din hjemmeside.',
                                      type: CustomTextType.bread,
                                    ),
                                    const Gap(24),
                                    CustomButton(
                                      onPressed: _openVerificationUrl,
                                      text: 'Ansøg om verifisering',
                                      buttonType: CustomButtonType.secondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(24),
                        CustomButton(
                          onPressed: _resetState,
                          text: 'Tjek andet link',
                          buttonType: CustomButtonType.secondary,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

// Created: 2024-06-07 13:00:00
