import '../../../exports.dart';
//import 'package:go_router/go_router.dart';
import 'base_screen.dart';

abstract class UnauthenticatedScreen extends BaseScreen {
  const UnauthenticatedScreen({super.key});

  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implementer din auth check her når du har din auth provider klar
    // final user = ref.watch(authProvider).user;
    // if (user != null) {
    //   context.go('/home');
    //   return const SizedBox.shrink();
    // }

    return buildUnauthenticatedWidget(context, ref);
  }
}
