import '../../../exports.dart';
import '../../../widgets/auth/magic_link_form.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/custom/custom_level_label.dart';

class LoginEmailPasswordScreen extends UnauthenticatedScreen {
  const LoginEmailPasswordScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Email & Password Login',
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/images/id-truster-badge.svg',
                  height: 150,
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              Center(
                child: const CustomText(
                  text: 'Email & Password login',
                  type: CustomTextType.head,
                  alignment: CustomTextAlignment.center,
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              StatefulBuilder(
                builder: (context, setState) {
                  final TabController tabController = DefaultTabController.of(context);
                  final List<String> tabTitles = ['Login', 'Create account'];
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
              const Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: EmailPasswordForm(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CreateUserForm(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 15:30
