import '../../exports.dart';
import '../../../services/i18n_service.dart';

class LoginCreateAccountTabs extends StatelessWidget {
  final VoidCallback onForgotPassword;

  const LoginCreateAccountTabs({
    super.key,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatefulBuilder(
          builder: (context, setState) {
            final TabController tabController = DefaultTabController.of(context);
            final List<String> tabTitles = [
              I18nService().t('screen_login_email_and_password.login_email_and_password_login', fallback: 'Login'),
              I18nService().t('screen_login_email_and_password.login_email_and_password_create_account', fallback: 'Create account')
            ];
            final theme = Theme.of(context);
            tabController.removeListener(() {}); // Fjern evt. gamle lyttere
            tabController.addListener(() {
              setState(() {});
            });
            final int currentIndex = tabController.index;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD), // Baggrundsfarve #DDD
                borderRadius: BorderRadius.circular(7), // 7 px radius
                // Ingen border
              ),
              child: Row(
                children: List.generate(tabTitles.length, (index) {
                  final bool isSelected = currentIndex == index;
                  Color bgColor;
                  Color textColor;
                  if (isSelected) {
                    bgColor = const Color(0xFF014459); // Brug ønsket grøn/blå farve
                    textColor = Colors.white;
                  } else {
                    bgColor = const Color(0xFFDDDDDD); // Samme som tabbarens baggrund
                    textColor = const Color(0xFF014459); // Tekstfarve for inaktive tabs
                  }
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        tabController.animateTo(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            tabTitles[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EmailPasswordForm(),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    GestureDetector(
                      key: const Key('login_forgot_password_link'),
                      onTap: onForgotPassword,
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: I18nService().t('screen_login_email_and_password.login_email_and_password_forgot_password_text', fallback: 'Missing or forgot your password? '),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
                          children: [
                            TextSpan(
                              text: I18nService().t('screen_login_email_and_password.login_email_and_password_forgot_password_link', fallback: 'Click here to reset it'),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF014459),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CreateUserForm(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// File created: 2025-01-27
