import '../../../exports.dart';

class ConnectScreen extends AuthenticatedScreen {
  ConnectScreen({super.key});

  @override
  Widget buildAuthenticatedWidget(
      BuildContext context, WidgetRef ref, AuthenticatedState state) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Add Contact'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Security Level',
              style: AppTheme.getBodyMedium(context),
            ),
            const SizedBox(height: 16),
            Container(
              decoration:
                  AppTheme.getParentContainerStyle(context).applyToContainer,
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.green),
                title: Text('Meet In Person',
                    style: AppTheme.getBodyMedium(context)),
                subtitle: Text(
                  'When meeting your new contact in person, and they can present their phone to you for verification or interaction.',
                  style: AppTheme.getBodyMedium(context),
                ),
                trailing:
                    Text('Level 1', style: TextStyle(color: Colors.green)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration:
                  AppTheme.getParentContainerStyle(context).applyToContainer,
              child: ListTile(
                leading: Icon(Icons.wifi, color: Colors.orange),
                title: Text('Connect Online',
                    style: AppTheme.getBodyMedium(context)),
                subtitle: Text(
                  'If meeting in person isn\'t possible, use email, text, or other remote methods to establish contact.',
                  style: AppTheme.getBodyMedium(context),
                ),
                trailing:
                    Text('Level 3', style: TextStyle(color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Connections are assigned different security levels based on how they are created, each with varying degrees of trust and authenticity.',
              style: AppTheme.getBodyMedium(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: AppTheme.getPrimaryButtonStyle(context),
              onPressed: () {},
              child: const Text('Read About Security Levels'),
            ),
          ],
        ),
      ),
    );
  }
}
