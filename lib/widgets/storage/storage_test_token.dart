import 'dart:convert';
import '../../exports.dart';
import '../../models/user_storage_data.dart';
import '../../providers/storage/storage_provider.dart';

class StorageTestToken extends ConsumerStatefulWidget {
  const StorageTestToken({super.key});

  @override
  ConsumerState<StorageTestToken> createState() => _StorageTestTokenState();
}

class _StorageTestTokenState extends ConsumerState<StorageTestToken> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<List<UserStorageData>>(
        future: ref.read(storageProvider.notifier).getUserStorageData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final storageData = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String?>(
                future: ref.read(storageProvider.notifier).getCurrentUserToken(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return Text(
                    snapshot.data != null ? 'Token: ${snapshot.data}' : 'Mangler token',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                },
              ),
              const Gap(8),
              FutureBuilder<String?>(
                future: ref.read(storageProvider.notifier).getCurrentUserTestKey(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return Text(
                    snapshot.data != null ? 'TestKey: ${snapshot.data}' : 'Mangler testKey',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                },
              ),
              const Gap(40),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      key: const Key('add_user_button'),
                      onPressed: () => _addCurrentUserIfNotExists(),
                      text: 'Tilføj',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      key: const Key('delete_user_button'),
                      onPressed: () => _deleteCurrentUser(),
                      text: 'Slet',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (storageData.isEmpty)
                const Text('Ingen brugere gemt i storage')
              else
                ...storageData.map((data) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${data.email}'),
                          Text('Token: ${data.token}'),
                          Text('Test Key: ${data.testkey}'),
                        ],
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteCurrentUser() async {
    final user = ref.read(authProvider);
    if (user == null) return;

    final storage = ref.read(storageProvider.notifier);
    final currentData = await storage.getUserStorageData();
    final updatedData = currentData.where((data) => data.email != user.email).toList();

    await storage.saveString(
      kUserStorageKey,
      jsonEncode(updatedData.map((e) => e.toJson()).toList()),
      secure: true,
    );

    // Opdater UI efter sletning
    setState(() {});
  }

  Future<void> _addCurrentUserIfNotExists() async {
    return;
    final user = ref.read(authProvider);
    if (user == null) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    final storage = ref.read(storageProvider.notifier);
    final existingUser = await storage.getUserStorageDataByEmail(user.email);

    if (existingUser != null) {
      return;
    }

    final newUserData = UserStorageData(
      email: user.email,
      token: AESGCMEncryptionUtils.generateSecureToken(),
      testkey: AESGCMEncryptionUtils.generateSecureTestKey(),
    );

    final currentData = await storage.getUserStorageData();
    final updatedData = [...currentData, newUserData];
    await storage.saveString(
      kUserStorageKey,
      jsonEncode(updatedData.map((e) => e.toJson()).toList()),
      secure: true,
    );

    // Opdater UI efter tilføjelse
    setState(() {});
  }
}
