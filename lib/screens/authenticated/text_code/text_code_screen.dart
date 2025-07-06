import '../../../exports.dart';

class TextCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

  TextCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<TextCodeScreen> create() async {
    final screen = TextCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _onSearchPressed(String searchValue) {
    log('_onSearchPressed: Search pressed with value: $searchValue from lib/screens/authenticated/text_code/text_code_screen.dart');
    // Pt skal der ikke ske noget
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
                                  onPressed: () => _onSearchPressed(searchController.text),
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
