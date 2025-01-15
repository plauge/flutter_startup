import '../../../exports.dart';

class ResultScreen extends AuthenticatedScreen {
  final Map<String, String> formData;

  ResultScreen({required this.formData});

  static Future<ResultScreen> create(
      {required Map<String, String> formData}) async {
    final screen = ResultScreen(formData: formData);
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return ResultScreenContent(formData: formData);
  }
}

class ResultScreenContent extends StatelessWidget {
  final Map<String, String> formData;

  const ResultScreenContent({required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Test Result',
        backRoutePath: '/home',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Form Results',
              type: CustomTextType.head,
            ),
            const Gap(32),
            CustomText(
              text: 'First Name: ${formData['firstName']}',
              type: CustomTextType.bread,
            ),
            const Gap(16),
            CustomText(
              text: 'Last Name: ${formData['lastName']}',
              type: CustomTextType.bread,
            ),
            const Gap(32),
            CustomButton(
              onPressed: () => context.pop(),
              text: 'Back to Form',
            ),
          ],
        ),
      ),
    );
  }
}
