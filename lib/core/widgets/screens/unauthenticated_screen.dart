import '../../../exports.dart';

abstract class UnauthenticatedScreen extends BaseScreen {
  const UnauthenticatedScreen({super.key});

  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildUnauthenticatedWidget(context, ref);
  }
}
