import '../exports.dart';
//import '../widgets/face_id_button.dart';

class HomePage extends AuthenticatedScreen {
  const HomePage({super.key});

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    final count = ref.watch(counterProvider);

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
                      const FaceIdButton(),
                    ],
                  ),
                  padding:
                      EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              StorageTestWidget(),
              ContactsAllWidget(
                user: AppUser(
                  id: auth.user.id,
                  email: auth.user.email!,
                  createdAt: auth.user.createdAt,
                  lastLoginAt: DateTime.now(),
                ),
                authToken: auth.token!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
