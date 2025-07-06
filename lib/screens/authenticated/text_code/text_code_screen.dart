import '../../../exports.dart';

class TextCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

  TextCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<TextCodeScreen> create() async {
    final screen = TextCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _onSearchPressed(String searchValue, WidgetRef ref, BuildContext context) {
    log('_onSearchPressed: Search pressed with value: $searchValue from lib/screens/authenticated/text_code/text_code_screen.dart');

    ref.read(readTextCodeByConfirmCodeProvider(searchValue).future).then(
      (results) {
        log('_onSearchPressed: Received results: ${results.length} items');

        if (results.isNotEmpty && results.first.statusCode == 200) {
          log('_onSearchPressed: Success - status code 200');
          CustomSnackBar.show(
            context: context,
            text: 'OK',
            type: CustomTextType.button,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          );
        } else {
          log('_onSearchPressed: Failed - status code: ${results.isNotEmpty ? results.first.statusCode : 'no results'}');
          CustomSnackBar.show(
            context: context,
            text: 'Koden er ikke kendt',
            type: CustomTextType.button,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          );
        }
      },
      onError: (error) {
        log('_onSearchPressed: Error occurred: $error');
        CustomSnackBar.show(
          context: context,
          text: 'Koden er ikke kendt',
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      },
    );
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<bool> isSearchEnabled = ValueNotifier<bool>(false);

    // Lyt til ændringer i input feltet
    searchController.addListener(() {
      isSearchEnabled.value = searchController.text.trim().isNotEmpty;
    });

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_text_code.title', fallback: 'SMS / Email validation'),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Gap(AppDimensionsTheme.getLarge(context)),
                      CustomText(
                        text: I18nService().t('screen_text_code.heading', fallback: 'SMS / Email validation'),
                        type: CustomTextType.head,
                        alignment: CustomTextAlignment.center,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      // Input felt med søgeknap i en row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: searchController,
                              hintText: I18nService().t('screen_text_code.search_hint', fallback: 'Enter code to validate'),
                            ),
                          ),
                          Gap(AppDimensionsTheme.getMedium(context)),
                          ValueListenableBuilder<bool>(
                            valueListenable: isSearchEnabled,
                            builder: (context, isEnabled, child) {
                              return SizedBox(
                                width: 75,
                                child: CustomButton(
                                  onPressed: () => _onSearchPressed(searchController.text, ref, context),
                                  buttonType: CustomButtonType.primary,
                                  icon: Icons.search,
                                  enabled: isEnabled,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Created on 2024-12-19 at 14:00
