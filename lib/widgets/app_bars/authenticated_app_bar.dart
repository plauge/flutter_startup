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
    return Container(
      color: const Color(0xFFECECEC),
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, _) => AppBar(
            backgroundColor: const Color(0xFFECECEC),
            iconTheme: const IconThemeData(color: Colors.black),
            // titleSpacing: Afstanden mellem title og leading/trailing widgets (20 pixels)
            // leadingWidth: Bredden af leading widget - 70px hvis der er en back-knap, ellers 20px
            titleSpacing: 0,
            leadingWidth: backRoutePath != null ? 50 : 0,
            leading: backRoutePath != null
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
            elevation: 0,
            actions: showSettings
                ? [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.settings, color: Colors.black),
                      onPressed: () {
                        if (context.mounted) {
                          context.go('/settings');
                        }
                      },
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
