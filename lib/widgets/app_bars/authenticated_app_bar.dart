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
        backgroundColor: const Color(0xFFECECEC),
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 20,
        leadingWidth: backRoutePath != null ? 70 : 20,
        leading: backRoutePath != null
            ? Padding(
                padding: const EdgeInsets.only(left: 20),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    if (context.mounted) {
                      context.go(backRoutePath!);
                    }
                  },
                ),
              )
            : null,
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(color: Colors.black),
              )
            : null,
        elevation: 0,
        actions: showSettings
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                      if (context.mounted) {
                        context.go('/settings');
                      }
                    },
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
