import '../../../exports.dart';

class PhoneCodeHistoryScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
  PhoneCodeHistoryScreen({super.key}) : super(pin_code_protected: false);

  static Future<PhoneCodeHistoryScreen> create() async {
    final screen = PhoneCodeHistoryScreen();
    return AuthenticatedScreen.create(screen);
  }

  Widget _buildPhoneCodeItem(PhoneCode phoneCode, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: AppDimensionsTheme.getSmall(context),
        horizontal: AppDimensionsTheme.getMedium(context),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: 'Kode: ${phoneCode.confirmCode}',
                  type: CustomTextType.info,
                ),
                Text(
                  phoneCode.receiverRead ? 'Læst' : 'Ulæst',
                  style: TextStyle(
                    color: phoneCode.receiverRead ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Gap(AppDimensionsTheme.getSmall(context)),
            CustomText(
              text: 'Medarbejder ID: ${phoneCode.customerEmployeeId}',
              type: CustomTextType.bread,
            ),
            Gap(AppDimensionsTheme.getSmall(context)),
            CustomText(
              text: 'Oprettet: ${phoneCode.createdAt.toLocal().toString().split('.')[0]}',
              type: CustomTextType.bread,
            ),
            if (phoneCode.initiatorCancel) ...[
              Gap(AppDimensionsTheme.getSmall(context)),
              const Text(
                'Status: Annulleret',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    final phoneCodesLogAsync = ref.watch(getPhoneCodesLogProvider);

    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Phone Code History',
        backRoutePath: RoutePaths.phoneCode,
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: phoneCodesLogAsync.when(
            data: (phoneCodesResponses) {
              log('PhoneCodeHistoryScreen: Received ${phoneCodesResponses.length} responses');

              if (phoneCodesResponses.isEmpty) {
                return const Center(
                  child: CustomText(
                    text: 'Ingen historik fundet',
                    type: CustomTextType.head,
                    alignment: CustomTextAlignment.center,
                  ),
                );
              }

              // Tag det første response (der skulle kun være ét)
              final response = phoneCodesResponses.first;
              final phoneCodes = response.data.payload.phoneCodes;

              if (phoneCodes.isEmpty) {
                return const Center(
                  child: CustomText(
                    text: 'Ingen phone codes fundet',
                    type: CustomTextType.head,
                    alignment: CustomTextAlignment.center,
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Gap(AppDimensionsTheme.getMedium(context)),
                    CustomText(
                      text: 'Antal codes: ${response.data.payload.count}',
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.center,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    ...phoneCodes.map((phoneCode) => _buildPhoneCodeItem(phoneCode, context)),
                    Gap(AppDimensionsTheme.getLarge(context)),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) {
              log('PhoneCodeHistoryScreen: Error loading data: $error');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Fejl ved indlæsning af historik',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    SelectableText.rich(
                      TextSpan(
                        text: error.toString(),
                        style: AppTheme.getBodyMedium(context).copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Created: 2025-01-16 14:46:00
