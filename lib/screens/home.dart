import '../exports.dart';

class HomePage extends AuthenticatedScreen {
  const HomePage({super.key});

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    final count = ref.watch(counterProvider);

    // Funktion til at gemme data
    Future<void> _saveData() async {
      try {
        // Standard storage (ikke-krypteret)
        await ref.read(storageProvider.notifier).saveString(
              StorageConstants.themeMode,
              'light',
            );
        await ref.read(storageProvider.notifier).saveInt(
              StorageConstants.fontSize,
              16,
            );

        // Secure storage (krypteret)
        await ref.read(storageProvider.notifier).saveString(
              StorageConstants.authToken,
              'sensitive_token_123',
              secure: true,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data gemt!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fejl ved gem: $e')),
          );
        }
      }
    }

    // Funktion til at læse data
    Future<void> _readData() async {
      try {
        // Standard storage (ikke-krypteret)
        final themeMode = await ref
            .read(storageProvider.notifier)
            .getString(StorageConstants.themeMode);
        final fontSize = await ref
            .read(storageProvider.notifier)
            .getInt(StorageConstants.fontSize);

        // Secure storage (krypteret)
        final token = await ref
            .read(storageProvider.notifier)
            .getString(StorageConstants.authToken, secure: true);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Læst data:\n'
                'Theme Mode: $themeMode\n'
                'Font Size: $fontSize\n'
                'Token: $token',
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fejl ved læsning: $e')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/second');
                },
                child: Container(
                  color: AppColors.primaryColor(context),
                  child: Text(
                    'Home',
                    style: AppTheme.getBodyMedium(context),
                  ),
                  padding:
                      EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                ),
              ),
              Gap(AppDimensionsTheme.getMedium(context)),
              GestureDetector(
                onTap: () {
                  ref.read(counterProvider.notifier).increment();
                },
                child: Container(
                  color: AppColors.primaryColor(context),
                  child: Column(
                    children: [
                      Text(
                        'Klik på mig',
                        style: AppTheme.getBodyMedium(context),
                      ),
                      Text(
                        'Antal klik: $count',
                        style: AppTheme.getBodyMedium(context),
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      Text(
                        'Bruger: ${auth.user.email}',
                        style: AppTheme.getBodyMedium(context),
                      ),
                    ],
                  ),
                  padding:
                      EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              Container(
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Test',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    // Standard Storage Test
                    Text(
                      'Standard Storage (test ved navigation):',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final timeString =
                                  '${now.hour}:${now.minute}:${now.second}';
                              await ref
                                  .read(storageProvider.notifier)
                                  .saveString(
                                    'lastStandardSave',
                                    timeString,
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Standard gemt: $timeString')),
                                );
                              }
                            },
                            child: const Text('Gem Standard Tid'),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final saved = await ref
                                  .read(storageProvider.notifier)
                                  .getString('lastStandardSave');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Standard tid: ${saved ?? 'Ikke gemt endnu'}',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Vis Standard Tid'),
                          ),
                        ),
                      ],
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    // Secure Storage Test
                    Text(
                      'Secure Storage (test ved hot reload):',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final timeString =
                                  '${now.hour}:${now.minute}:${now.second}';
                              await ref
                                  .read(storageProvider.notifier)
                                  .saveString(
                                    'lastSecureSave',
                                    timeString,
                                    secure: true,
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Secure gemt: $timeString')),
                                );
                              }
                            },
                            child: const Text('Gem Secure Tid'),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final saved = await ref
                                  .read(storageProvider.notifier)
                                  .getString('lastSecureSave', secure: true);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Secure tid: ${saved ?? 'Ikke gemt endnu'}',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Vis Secure Tid'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
