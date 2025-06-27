import '../../../exports.dart';

class ResetPasswordScreen extends UnauthenticatedScreen {
  const ResetPasswordScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    // Hent query parameters fra URL'en
    final queryParams = GoRouterState.of(context).queryParameters;
    final token = queryParams['token'];
    final code = queryParams['code'];
    final type = queryParams['type'];

    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Reset password',
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Reset Password Debug Info',
                  type: CustomTextType.head,
                ),
                Gap(AppDimensionsTheme.of(context).medium),

                // Vis alle query parameters
                const CustomText(
                  text: 'Query Parameters:',
                  type: CustomTextType.helper,
                ),
                Gap(AppDimensionsTheme.of(context).small),

                if (queryParams.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(AppDimensionsTheme.of(context).medium),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryColor(context).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: queryParams.entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppDimensionsTheme.of(context).small),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: '${entry.key}:',
                                type: CustomTextType.info,
                              ),
                              Gap(AppDimensionsTheme.of(context).small),
                              SelectableText(
                                entry.value,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF0A3751),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ] else ...[
                  const CustomText(
                    text: 'Ingen query parameters fundet',
                    type: CustomTextType.bread,
                  ),
                ],

                Gap(AppDimensionsTheme.of(context).large),

                // Specifik token information
                if (token != null) ...[
                  const CustomText(
                    text: 'Supabase Token:',
                    type: CustomTextType.helper,
                  ),
                  Gap(AppDimensionsTheme.of(context).small),
                  Container(
                    padding: EdgeInsets.all(AppDimensionsTheme.of(context).medium),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: SelectableText(
                      token,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF0A3751),
                      ),
                    ),
                  ),
                  Gap(AppDimensionsTheme.of(context).medium),
                ],

                if (code != null) ...[
                  const CustomText(
                    text: 'Supabase Code:',
                    type: CustomTextType.helper,
                  ),
                  Gap(AppDimensionsTheme.of(context).small),
                  Container(
                    padding: EdgeInsets.all(AppDimensionsTheme.of(context).medium),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info),
                    ),
                    child: SelectableText(
                      code,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF0A3751),
                      ),
                    ),
                  ),
                  Gap(AppDimensionsTheme.of(context).medium),
                ],

                if (type != null) ...[
                  const CustomText(
                    text: 'Type:',
                    type: CustomTextType.helper,
                  ),
                  Gap(AppDimensionsTheme.of(context).small),
                  CustomText(
                    text: type,
                    type: CustomTextType.info,
                  ),
                  Gap(AppDimensionsTheme.of(context).medium),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Created: 2024-12-19 15:30:00
