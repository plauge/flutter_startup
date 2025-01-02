import '../../exports.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: AppTheme.getBodyMedium(context)?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(
              'Home',
              style: AppTheme.getBodyMedium(context),
            ),
            onTap: () {
              context.go('/home');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.double_arrow),
            title: Text(
              'Second Page',
              style: AppTheme.getBodyMedium(context),
            ),
            onTap: () {
              context.go('/second');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.contacts),
            title: Text(
              'Contacts',
              style: AppTheme.getBodyMedium(context),
            ),
            onTap: () {
              context.go('/contacts');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              'Profile',
              style: AppTheme.getBodyMedium(context),
            ),
            onTap: () {
              context.go('/profile');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.science),
            title: Text(
              'Demo',
              style: AppTheme.getBodyMedium(context),
            ),
            onTap: () {
              context.go('/demo');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(
              'Terms of Service',
              style: AppTheme.getBodyMedium(context),
            ),
            onTap: () {
              context.go(RoutePaths.termsOfService);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
