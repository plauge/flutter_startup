import '../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends AuthenticatedScreen {
  ProfileEditScreen({super.key});

  static Future<ProfileEditScreen> create() async {
    final screen = ProfileEditScreen();
    return AuthenticatedScreen.create(screen);
  }

  Future<void> handleImageSelection(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const CustomText(
                  text: 'Take a photo',
                  type: CustomTextType.bread,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await picker.pickImage(source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const CustomText(
                  text: 'Choose from gallery',
                  type: CustomTextType.bread,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await picker.pickImage(source: ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void handleSave(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const CustomText(
            text: 'Success',
            type: CustomTextType.head,
          ),
          content: const CustomText(
            text: 'Your profile has been updated successfully.',
            type: CustomTextType.bread,
          ),
          actions: [
            CustomButton(
              onPressed: () => Navigator.pop(context),
              text: 'Close',
              buttonType: CustomButtonType.secondary,
            ),
            CustomButton(
              onPressed: () => context.go(RoutePaths.home),
              text: 'Go to Home',
              buttonType: CustomButtonType.primary,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return HookBuilder(
      builder: (context) {
        final firstNameController = useTextEditingController();
        final lastNameController = useTextEditingController();
        final companyController = useTextEditingController();
        final formKey = GlobalKey<FormState>();

        final profileAsync = ref.watch(profileNotifierProvider);

        useEffect(() {
          profileAsync.whenData((profile) {
            firstNameController.text = profile['first_name'] ?? '';
            lastNameController.text = profile['last_name'] ?? '';
            companyController.text = profile['company'] ?? '';
          });
          return null;
        }, [profileAsync]);

        return Scaffold(
          appBar: const AuthenticatedAppBar(
            title: 'Edit Profile',
            backRoutePath: RoutePaths.settings,
          ),
          body: profileAsync.when(
            data: (_) =>
                AppTheme.getParentContainerStyle(context).applyToContainer(
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    Gap(AppDimensionsTheme.getLarge(context)),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => handleImageSelection(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    TextFormField(
                      controller: firstNameController,
                      decoration:
                          AppTheme.getTextFieldDecoration(context).copyWith(
                        labelText: 'First Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    TextFormField(
                      controller: lastNameController,
                      decoration:
                          AppTheme.getTextFieldDecoration(context).copyWith(
                        labelText: 'Last Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    TextFormField(
                      controller: companyController,
                      decoration:
                          AppTheme.getTextFieldDecoration(context).copyWith(
                        labelText: 'Company (Optional)',
                      ),
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          handleSave(context);
                        }
                      },
                      text: 'Save',
                      buttonType: CustomButtonType.primary,
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: CustomText(
                text: 'Error loading profile: $error',
                type: CustomTextType.info,
              ),
            ),
          ),
        );
      },
    );
  }
}
