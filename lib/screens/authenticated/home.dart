import '../../exports.dart';
import 'dart:io'; // Added for Platform detection
//import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class HomePage extends AuthenticatedScreen {
  // Protected constructor
  HomePage({super.key}) : super(pin_code_protected: false);

  static final log = scopedLogger(LogCategory.gui);

  // Static create method - den eneste måde at instantiere siden
  static Future<HomePage> create() async {
    final page = HomePage();
    //log('HomePage created ❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️');
    return AuthenticatedScreen.create(page);
  }

  void _trackCardNavigation(WidgetRef ref, String cardType, String destination) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('home_card_pressed', {
      'card_type': cardType,
      'destination': destination,
      'screen': 'home',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _trackSettingsButtonPressed(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('home_settings_button_pressed', {
      'button_type': 'settings',
      'screen': 'home',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _showFCMTokenModal(BuildContext context, String token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'FCM Token',
                      type: CustomTextType.head,
                    ),
                    IconButton(
                      key: const Key('fcm_modal_close_button'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                Gap(AppDimensionsTheme.getMedium(context)),
                // Token display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: SelectableText(
                    token,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                Gap(AppDimensionsTheme.getSmall(context)),
                CustomText(
                  text: 'Length: ${token.length} characters',
                  type: CustomTextType.small_bread,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyFCMToken(BuildContext context) async {
    try {
      // Get FCM token
      final String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        // Copy to clipboard
        await Clipboard.setData(ClipboardData(text: token));

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('FCM Token copied to clipboard!\nLength: ${token.length} characters'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Show FCM token in modal
          _showFCMTokenModal(context, token);
        }

        log('FCM Token copied to clipboard: ${token.substring(0, 20)}...');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get FCM token'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Error getting FCM token: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    AppLogger.log(LogCategory.security, 'HomePage buildAuthenticatedWidget');

    // Navigate to PhoneCode screen as soon as active calls are detected
    ref.listen(phoneCodesRealtimeStreamProvider, (previous, next) {
      final bool prevHasActiveCalls = previous?.maybeWhen(data: (codes) => codes.isNotEmpty, orElse: () => false) ?? false;
      final bool nextHasActiveCalls = next.maybeWhen(data: (codes) => codes.isNotEmpty, orElse: () => false);
      if (!prevHasActiveCalls && nextHasActiveCalls) {
        log('Redirecting to phone_code due to active calls from lib/screens/authenticated/home.dart');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go(RoutePaths.phoneCode);
          }
        });
      }
    });

    return Scaffold(
      appBar: const AuthenticatedAppBar(showSettings: false),
      //drawer: const MainDrawer(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(AppDimensionsTheme.getMedium(context)),
                    SvgPicture.asset(
                      'assets/images/id-truster-badge.svg',
                      height: 100,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomText(
                      text: I18nService().t('screen_home.what_to_check', fallback: 'What to check?'),
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.webCode),
                    //   icon: CardIcon.trash,
                    //   headerText: 'Hjemmeside / Webshop',
                    //   bodyText: 'Tjek hvem som ejer hjemmesiden',
                    //   backgroundColor: CardBackgroundColor.blue,
                    // ),
                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.qrCodeScanning),
                    //   icon: CardIcon.qrCode,
                    //   headerText: 'QR-kode',
                    //   bodyText: 'Scan QR-koder på en sikker måde',
                    //   backgroundColor: CardBackgroundColor.green,
                    // ),
                    // Gap(AppDimensionsTheme.getLarge(context)),

                    CustomCard(
                      onPressed: () {
                        _trackCardNavigation(ref, 'contacts', 'contacts');
                        context.go(RoutePaths.contacts);
                      },
                      icon: CardIcon.contacts,
                      headerText: I18nService().t('screen_home.contacts_header', fallback: 'Contacts'),
                      bodyText: I18nService().t('screen_home.contacts_description', fallback: 'Validate contacts, family, friends and network'),
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCard(
                      onPressed: () {
                        _trackCardNavigation(ref, 'text_code', 'text_code');
                        context.go(RoutePaths.textCode);
                      },
                      icon: CardIcon.email,
                      headerText: I18nService().t('screen_home.text_code_header', fallback: 'Email & Text Messages'),
                      bodyText: I18nService().t('screen_home.text_code_description', fallback: 'Check if the sender is who they say they are'),
                      backgroundColor: CardBackgroundColor.green,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    Consumer(
                      builder: (context, ref, child) {
                        final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);

                        return phoneCodesAsync.maybeWhen(
                          data: (phoneCodes) {
                            final hasActiveCalls = phoneCodes.isNotEmpty;
                            final activeCallsCount = phoneCodes.length;

                            return Stack(
                              children: [
                                CustomCard(
                                  onPressed: () {
                                    _trackCardNavigation(ref, 'phone_code', 'phone_code');
                                    context.go(RoutePaths.phoneCode);
                                  },
                                  icon: CardIcon.phone,
                                  headerText: I18nService().t('screen_home.phone_number_header', fallback: 'Phone calls'),
                                  bodyText: I18nService().t('screen_home.phone_number_description', fallback: 'Check if you are talking to the right person'),
                                  backgroundColor: CardBackgroundColor.green,
                                ),
                                if (hasActiveCalls)
                                  Positioned(
                                    top: 0,
                                    left: 50,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        activeCallsCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          orElse: () => CustomCard(
                            onPressed: () {
                              _trackCardNavigation(ref, 'phone_code', 'phone_code');
                              context.go(RoutePaths.phoneCode);
                            },
                            icon: CardIcon.phone,
                            headerText: I18nService().t('screen_home.phone_number_header', fallback: 'Phone calls'),
                            bodyText: I18nService().t('screen_home.phone_number_description', fallback: 'Check if you are talking to the right person'),
                            backgroundColor: CardBackgroundColor.green,
                          ),
                        );
                      },
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    //const StorageTestToken(),

                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.contacts),
                    //   icon: CardIcon.email,
                    //   headerText: 'Email & Text Messages',
                    //   bodyText: 'Validate an email or SMS/text message',
                    // ),
                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.contacts),
                    //   icon: CardIcon.phone,
                    //   headerText: 'Phone Calls',
                    //   bodyText: 'Check the ID of who you are talking with',
                    // ),

                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.invalidSecureKey),
                    //   icon: CardIcon.dots,
                    //   headerText: 'Invalid Secure Key',
                    //   bodyText: 'Invalid secure key screen',
                    // ),
                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // if (kDebugMode)
                    //   CustomCard(
                    //     onPressed: () => context.go(RoutePaths.routeExplorer),
                    //     icon: CardIcon.dots,
                    //     headerText: 'Route Explorer',
                    //     bodyText: 'View all available routes in the app',
                    //     backgroundColor: CardBackgroundColor.blue,
                    //   ),
                    // if (kDebugMode) Gap(AppDimensionsTheme.getLarge(context)),
                    if (true) ...[
                      // CustomButton(
                      //   text: 'Create PIN Code',
                      //   onPressed: () => context.go(RoutePaths.onboardingBegin),
                      //   buttonType: CustomButtonType.primary,
                      //   icon: Icons.pin,
                      // ),
                      // CustomCard(
                      //   onPressed: () => context.go(RoutePaths.enterPincode),
                      //   icon: CardIcon.dots,
                      //   headerText: 'Enter PIN Code',
                      //   bodyText: 'Verify your identity with your PIN code',
                      // ),
                      // Gap(AppDimensionsTheme.getLarge(context)),
                      // FutureBuilder<List<dynamic>>(
                      //   future: ref.read(securityVerificationProvider.notifier).doCaretaking((Platform.isIOS ? AppVersionConstants.appVersionIntIOS : AppVersionConstants.appVersionIntAndroid).toString()),
                      //   builder: (context, snapshot) {
                      //     if (snapshot.hasData) {
                      //       return Column(
                      //         children: [
                      //           CustomText(
                      //             text: snapshot.data.toString(),
                      //             type: CustomTextType.bread,
                      //             alignment: CustomTextAlignment.left,
                      //           ),
                      //           Gap(AppDimensionsTheme.getLarge(context)),
                      //         ],
                      //       );
                      //     }
                      //     if (snapshot.hasError) {
                      //       return Column(
                      //         children: [
                      //           CustomText(
                      //             text: 'Error: ${snapshot.error}',
                      //             type: CustomTextType.bread,
                      //             alignment: CustomTextAlignment.left,
                      //           ),
                      //           Gap(AppDimensionsTheme.getLarge(context)),
                      //         ],
                      //       );
                      //     }
                      //     return const CircularProgressIndicator();
                      //   },
                      // ),
                      // CustomButton(
                      //   text: 'Create PIN Code',
                      //   onPressed: () => context.go(RoutePaths.onboardingBegin),
                      //   buttonType: CustomButtonType.primary,
                      //   icon: Icons.pin,
                      // ),
                      // Gap(AppDimensionsTheme.getLarge(context)),
                      // Gap(AppDimensionsTheme.getLarge(context)),
                      // StorageTestWidget(),
                      //Gap(AppDimensionsTheme.getLarge(context)),

                      // CustomButton(
                      //   text: 'Personal Information',
                      //   onPressed: () => context.go(RoutePaths.personalInfo),
                      //   buttonType: CustomButtonType.primary,
                      //   icon: Icons.person,
                      // ),
                      // Gap(AppDimensionsTheme.getLarge(context)),
                      // CustomButton(
                      //   text: 'Onboarding Complete',
                      //   onPressed: () => context.go(RoutePaths.onboardingComplete),
                      //   buttonType: CustomButtonType.primary,
                      //   icon: Icons.check_circle,
                      // ),
                      // Gap(AppDimensionsTheme.getLarge(context)),
                      // CustomButton(
                      //   text: 'Test Form',
                      //   onPressed: () => context.go(RoutePaths.testForm),
                      //   buttonType: CustomButtonType.primary,
                      //   icon: Icons.edit_document,
                      // ),
                      // GestureDetector(
                      //   onTap: () {
                      //     ref.read(counterProvider.notifier).increment();
                      //     final newCount = ref.read(counterProvider);
                      //     _trackCounterIncrement(ref, newCount);
                      //   },
                      //   child: Container(
                      //     color: AppColors.primaryColor(context),
                      //     child: Column(
                      //       children: [
                      //         Text(
                      //           'Klik på mig',
                      //           style: AppTheme.getBodyMedium(context),
                      //         ),
                      //         Text(
                      //           'Antal klik: $count',
                      //           style: AppTheme.getBodyMedium(context),
                      //         ),
                      //         Gap(AppDimensionsTheme.getMedium(context)),
                      //         Text(
                      //           'Bruger: ${auth.user.email}',
                      //           style: AppTheme.getBodyMedium(context),
                      //         ),
                      //         const FaceIdButton(),
                      //       ],
                      //     ),
                      //     padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                      //   ),
                      // ),
                      // Gap(AppDimensionsTheme.getLarge(context)),
                      // StorageTestWidget(),
                    ],
                    // if (kDebugMode) ...[
                    //   Gap(AppDimensionsTheme.getLarge(context)),
                    //   const StorageTestToken(),
                    // ],
                  ],
                ),
              ),
            ),
            Builder(
              builder: (context) {
                final buttons = Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      // FCM Token Button (Debug/Test only)
                      // CustomButton(
                      //   key: const Key('home_fcm_token_button'),
                      //   text: 'Copy FCM Token 📋',
                      //   onPressed: () => _copyFCMToken(context),
                      //   buttonType: CustomButtonType.primary,
                      //   icon: Icons.copy,
                      // ),
                      // Gap(AppDimensionsTheme.getSmall(context)),
                      // Settings Button
                      CustomButton(
                        key: const Key('home_settings_button'),
                        text: I18nService().t('screen_home.settings_button', fallback: 'Settings'),
                        onPressed: () {
                          _trackSettingsButtonPressed(ref);
                          context.go(RoutePaths.settings);
                        },
                        buttonType: CustomButtonType.secondary,
                        icon: Icons.settings,
                      ),
                    ],
                  ),
                );

                return Platform.isAndroid ? SafeArea(top: false, child: buttons) : buttons;
              },
            ),
          ],
        ),
      ),
    );
  }
}
