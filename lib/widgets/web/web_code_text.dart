import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../exports.dart';
import '../../providers/web_code_provider.dart';
import '../../models/web_code_receive_response.dart';

class WebCodeText extends ConsumerStatefulWidget {
  const WebCodeText({super.key});

  @override
  ConsumerState<WebCodeText> createState() => _WebCodeTextState();
}

class _WebCodeTextState extends ConsumerState<WebCodeText> {
  bool _isLoading = false;
  bool _hasCalledApi = false;
  final String _webCodesId = '74246482-fc61-4d41-b622-8835d0565dc5'; // Dette bør erstattes med den rigtige ID

  void _handleButtonPress() {
    setState(() {
      _isLoading = true;
      _hasCalledApi = true;
    });
  }

  void _resetState() {
    setState(() {
      _isLoading = false;
      _hasCalledApi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kun kald provideren når vi har kaldt API'en
    final webCodeResult = _hasCalledApi ? ref.watch(receiveWebCodeProvider(webCodesId: _webCodesId)) : null;

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
        if (!_hasCalledApi)
          // Initial state: viser kun knappen
          CustomButton(
            onPressed: _handleButtonPress,
            text: 'Click to insert code',
            buttonType: CustomButtonType.primary,
          )
        else if (_isLoading && webCodeResult == null)
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
                              // Confirm knappen skal ikke gøre noget endnu
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
