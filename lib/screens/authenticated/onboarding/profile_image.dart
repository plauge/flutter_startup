import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

class OnboardingProfileImageScreen extends AuthenticatedScreen {
  OnboardingProfileImageScreen({super.key});

  static Future<OnboardingProfileImageScreen> create() async {
    final screen = OnboardingProfileImageScreen();
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

  void handleSkip(BuildContext context) {
    context.go(RoutePaths.personalInfo);
  }

  void handleSave(BuildContext context) {
    context.go(RoutePaths.personalInfo);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Profile Image',
        backRoutePath: RoutePaths.createPin,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap(AppDimensionsTheme.getLarge(context)),
            const CustomText(
              text: 'Step 3 of 4',
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
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
            const Spacer(),
            CustomButton(
              onPressed: () => handleSave(context),
              text: 'Save',
              buttonType: CustomButtonType.primary,
            ),
            Gap(AppDimensionsTheme.getMedium(context)),
            CustomButton(
              onPressed: () => handleSkip(context),
              text: 'Skip for later',
              buttonType: CustomButtonType.secondary,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
          ],
        ),
      ),
    );
  }
}
