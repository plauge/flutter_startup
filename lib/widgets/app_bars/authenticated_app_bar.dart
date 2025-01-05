import '../../exports.dart';

class AuthenticatedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final String? backRoutePath;
  final bool showSettings;

  const AuthenticatedAppBar({
    super.key,
    this.title,
    this.backRoutePath,
    this.showSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: backRoutePath != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (context.mounted) {
                    context.go(backRoutePath!);
                  }
                },
              )
            : null,
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(color: Colors.white),
              )
            : null,
        elevation: 0,
        actions: showSettings
            ? [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
                ),
              ]
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
