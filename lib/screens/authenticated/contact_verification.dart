import '../../exports.dart';
import '../../providers/contact_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactVerificationScreen extends AuthenticatedScreen {
  final String contactId;

  ContactVerificationScreen({
    super.key,
    required this.contactId,
  });

  static Future<ContactVerificationScreen> create({
    required String contactId,
  }) async {
    final screen = ContactVerificationScreen(contactId: contactId);
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    // Call the API when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactProvider.notifier).markAsVisited(contactId);
    });

    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Verification',
        backRoutePath: '/contacts',
        showSettings: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  AssetImage('assets/images/profile.jpg'), // Example image
            ),
            const SizedBox(height: 16),
            Text(
              'Name Nameson',
              style: AppTheme.getBodyMedium(context),
            ),
            Text(
              'Company Ltd',
              style: AppTheme.getBodyMedium(context),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Security Level 1',
                style: AppTheme.getBodyMedium(context)
                    .copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: AppTheme.getPrimaryButtonStyle(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_forward),
                  SizedBox(width: 8),
                  Text('Swipe To Confirm'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'To verify a contact, ensure they have you saved as a contact. Ask them to open your card and swipe to confirm.',
              style: AppTheme.getBodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Contact ID: $contactId',
              style: AppTheme.getBodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: const [
                    Icon(Icons.star_border),
                    SizedBox(height: 4),
                    Text('Star'),
                  ],
                ),
                Column(
                  children: const [
                    Icon(Icons.delete_outline),
                    SizedBox(height: 4),
                    Text('Delete'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
