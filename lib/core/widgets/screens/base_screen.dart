import '../../../exports.dart';

abstract class BaseScreen extends ConsumerWidget {
  const BaseScreen({super.key});

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @override
  Widget build(BuildContext context, WidgetRef ref);
}
