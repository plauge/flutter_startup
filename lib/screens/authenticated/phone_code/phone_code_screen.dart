import '../../../exports.dart';

class PhoneCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
  PhoneCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<PhoneCodeScreen> create() async {
    final screen = PhoneCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _navigateToHistory(BuildContext context) {
    log('_navigateToHistory: Navigating to phone code history from lib/screens/authenticated/phone_code/phone_code_screen.dart');
    context.go(RoutePaths.phoneCodeHistory);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Telefonopkald',
        backRoutePath: RoutePaths.home,
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Gap(AppDimensionsTheme.getLarge(context)),
                      const CustomText(
                        text: 'Ingen aktive opkald',
                        type: CustomTextType.head,
                        alignment: CustomTextAlignment.center,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      // Realtime phone codes liste
                      Consumer(
                        builder: (context, ref, child) {
                          final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);

                          return phoneCodesAsync.when(
                            data: (phoneCodes) {
                              if (phoneCodes.isEmpty) {
                                return const CustomText(
                                  text: 'Ingen aktive telefon koder',
                                  type: CustomTextType.info,
                                  alignment: CustomTextAlignment.center,
                                );
                              }

                              return Column(
                                children: phoneCodes.map((phoneCode) {
                                  return PhoneCodeItemWidget(
                                    phoneCode: phoneCode,
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) => SelectableText.rich(
                              TextSpan(
                                text: 'Fejl ved indlæsning af telefon koder: $error',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        },
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                    ],
                  ),
                ),
              ),
              // Fast knap i bunden
              Padding(
                padding: EdgeInsets.only(
                  bottom: AppDimensionsTheme.getLarge(context),
                ),
                child: CustomButton(
                  text: 'Historik',
                  onPressed: () => _navigateToHistory(context),
                  buttonType: CustomButtonType.primary,
                  icon: Icons.history,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Created: 2025-01-16 14:45:00
