import '../../../exports.dart';

class CheckEmailScreen extends UnauthenticatedScreen {
  const CheckEmailScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Check your email',
            style: AppTheme.getHeadingLarge(context),
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          const Text(
            'We have sent you a magic link to your email address. '
            'Please check your inbox and click the link to continue.',
          ),
        ],
      ),
    );
  }
}
