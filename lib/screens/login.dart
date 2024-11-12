import '../exports.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Login'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  context.go('/home');
                },
                child: Container(
                  color: AppColors.primaryColor(context),
                  child: Text(
                    'Login',
                    style: AppTheme.getHeadingLarge(context),
                  ),
                  padding:
                      EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                ),
              ),
              Gap(AppDimensionsTheme.getMedium(context)),
            ],
          ),
        ),
      ),
    );
  }
}
