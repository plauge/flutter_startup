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
            leadingWidth: backRoutePath != null
                ? (40 + AppDimensionsTheme.getParentContainerPadding(context))
                : 0,
            leading: backRoutePath != null
                ? Padding(
                    padding: EdgeInsets.only(
                      left:
                          AppDimensionsTheme.getParentContainerPadding(context),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (context.mounted) {
                          context.go(backRoutePath!);
                        }
                      },
                      onLongPress: () {
                        if (context.mounted) {
                          context.go(RoutePaths.home);
                        }
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
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
                    Padding(
                      padding: EdgeInsets.only(
                        right: AppDimensionsTheme.getParentContainerPadding(
                            context),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (context.mounted) {
                            context.go('/settings');
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          child: const Icon(
                            Icons.settings,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
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
