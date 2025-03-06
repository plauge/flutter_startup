import '../../../exports.dart';
import 'dart:developer' as developer;

class SwipeTestScreen extends StatelessWidget {
  const SwipeTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    developer.log('Building SwipeTestScreen', name: 'SwipeTestScreen');

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: 'Swipe Test',
        backRoutePath: RoutePaths.home,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Center(
          child: CustomText(
            text: 'Test',
            type: CustomTextType.head,
          ),
        ),
      ),
    );
  }
}
