import '../../exports.dart';

class StorageTestWidget extends ConsumerWidget {
  const StorageTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
            'Standard Storage (ikke-krypteret):',
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
                    await ref.read(storageProvider.notifier).saveString(
                          'lastStandardSave',
                          timeString,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Standard gemt: $timeString')),
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
            'Secure Storage (krypteret):',
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
                    await ref.read(storageProvider.notifier).saveString(
                          'lastSecureSave',
                          timeString,
                          secure: true,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Secure gemt: $timeString')),
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
    );
  }
}
