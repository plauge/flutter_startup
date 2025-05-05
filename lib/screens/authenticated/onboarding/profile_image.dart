import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:riverpod/riverpod.dart' as riverpod;
import 'dart:io';

class OnboardingProfileImageScreen extends AuthenticatedScreen {
  OnboardingProfileImageScreen({super.key});

  static Future<OnboardingProfileImageScreen> create() async {
    final screen = OnboardingProfileImageScreen();
    return AuthenticatedScreen.create(screen);
  }

  final userIdProvider = riverpod.Provider<String>(
      (ref) => Supabase.instance.client.auth.currentUser?.id ?? '');

  final profileImageProvider = riverpod.StateProvider<String?>((ref) => null);

  img.Image cropToSquare(img.Image image) {
    final size = image.width < image.height ? image.width : image.height;
    final x = (image.width - size) ~/ 2;
    final y = (image.height - size) ~/ 2;
    return img.copyCrop(image, x: x, y: y, width: size, height: size);
  }

  Future<String?> uploadImageToSupabase(String imagePath, String userId) async {
    try {
      if (userId.isEmpty) {
        print('Error: No user ID available');
        return null;
      }

      print('Starting image upload for user: $userId');
      print('Image path: $imagePath');

      final bytes = File(imagePath).readAsBytesSync();
      print('Image bytes loaded: ${bytes.length} bytes');

      final image = img.decodeImage(bytes);
      if (image == null) {
        print('Failed to decode image');
        return null;
      }
      print('Image decoded successfully: ${image.width}x${image.height}');

      final croppedImage = cropToSquare(image);
      final resizedImage =
          img.copyResize(croppedImage, width: 400, height: 400);
      final jpegImage = img.encodeJpg(resizedImage, quality: 40);
      print('Image cropped, resized and compressed: ${jpegImage.length} bytes');

      final fileName = '$userId/profile.jpg';
      print('Uploading to path: $fileName');

      try {
        print('Starting Supabase upload...');
        final response =
            await Supabase.instance.client.storage.from('images').uploadBinary(
                  fileName,
                  jpegImage,
                  fileOptions: FileOptions(
                    contentType: 'image/jpeg',
                    upsert: true,
                  ),
                );

        if (response.isNotEmpty) {
          print('Upload successful - got path: $response');
          final publicUrl = Supabase.instance.client.storage
              .from('images')
              .getPublicUrl(fileName);
          print('Image uploaded successfully. Public URL: $publicUrl');

          try {
            print('Attempting to save URL to database...');
            final updateResponse = await Supabase.instance.client
                .from('profiles')
                .update({'profile_image': publicUrl}).eq('user_id', userId);
            print('Database update response: $updateResponse');
            print('Profile image URL saved to database: $publicUrl');
            return publicUrl;
          } catch (dbError) {
            print('Error saving profile image URL to database: $dbError');
            if (dbError is PostgrestException) {
              print('Postgrest error details: ${dbError.details}');
            }
            return null;
          }
        } else {
          print('Upload failed. Response was empty');
          return null;
        }
      } catch (uploadError, uploadStack) {
        print('Supabase upload error: $uploadError');
        print('Supabase upload stack trace: $uploadStack');
        if (uploadError is StorageException) {
          print('Storage error details: ${uploadError.message}');
        }
        return null;
      }
    } catch (e, stackTrace) {
      print('Error uploading image: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> handleImageSelection(BuildContext context, WidgetRef ref) async {
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
                  final XFile? photo =
                      await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    final userId = ref.read(userIdProvider);
                    print('Camera photo selected. User ID: $userId');
                    final imageUrl =
                        await uploadImageToSupabase(photo.path, userId);
                    print('Received image URL from upload: $imageUrl');
                    if (imageUrl != null) {
                      print('Setting image URL in provider: $imageUrl');
                      ref.read(profileImageProvider.notifier).state = imageUrl;
                    }
                  }
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
                  final XFile? galleryImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (galleryImage != null) {
                    final userId = ref.read(userIdProvider);
                    print('Gallery image selected. User ID: $userId');
                    final imageUrl =
                        await uploadImageToSupabase(galleryImage.path, userId);
                    print('Received image URL from upload: $imageUrl');
                    if (imageUrl != null) {
                      print('Setting image URL in provider: $imageUrl');
                      ref.read(profileImageProvider.notifier).state = imageUrl;
                    }
                  }
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

  void handleSave(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.read(profileImageProvider);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      print('Saving profile with image URL: $imageUrl');
    }
    //context.go(RoutePaths.personalInfo);
    context.go(RoutePaths.contacts);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Profile',
        backRoutePath: RoutePaths.createPin,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap(AppDimensionsTheme.getLarge(context)),
            const CustomText(
              text: 'Step 5 of 5',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            const CustomText(
              text: 'Profile image',
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            const CustomText(
              text:
                  'To make your profile even easier to identify, you can select an image now — or skip this step and add one later.',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomProfileImage(
              profileImageProvider: ref.watch(profileImageProvider),
              handleImageSelection: (context, ref) =>
                  handleImageSelection(context, ref),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomButton(
              onPressed: () => handleSave(context, ref),
              text: 'Save profile',
              buttonType: CustomButtonType.primary,
            ),
            Gap(AppDimensionsTheme.getMedium(context)),
            CustomButton(
              onPressed: () => handleSkip(context),
              text: 'Back',
              buttonType: CustomButtonType.secondary,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
          ],
        ),
      ),
    );
  }
}
