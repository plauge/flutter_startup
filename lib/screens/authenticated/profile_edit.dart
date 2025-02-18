import '../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:riverpod/riverpod.dart' as riverpod;
import 'dart:io';

class ProfileEditScreen extends AuthenticatedScreen {
  ProfileEditScreen({super.key});

  static Future<ProfileEditScreen> create() async {
    final screen = ProfileEditScreen();
    return AuthenticatedScreen.create(screen);
  }

  final userIdProvider = riverpod.Provider<String>(
      (ref) => Supabase.instance.client.auth.currentUser?.id ?? '');

  final profileImageProvider = riverpod.StateProvider<String?>((ref) => null);

  Future<String?> uploadImageToSupabase(String imagePath, String userId) async {
    try {
      if (userId.isEmpty) {
        print('Error: No user ID available');
        return null;
      }

      print('Starting image upload for user: $userId');
      print('Image path: $imagePath');

      // Load the image
      final bytes = File(imagePath).readAsBytesSync();
      print('Image bytes loaded: ${bytes.length} bytes');

      final image = img.decodeImage(bytes);
      if (image == null) {
        print('Failed to decode image');
        return null;
      }
      print('Image decoded successfully: ${image.width}x${image.height}');

      // Resize and compress the image
      final resizedImage = img.copyResize(image, width: 400, height: 400);
      final jpegImage = img.encodeJpg(resizedImage, quality: 40);
      print('Image resized and compressed: ${jpegImage.length} bytes');

      // Upload to Supabase with user-specific folder structure
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

        print('Upload response raw: $response');
        print('Response type: ${response.runtimeType}');
        print('Response length: ${response.length}');

        // Hvis vi får en response med en sti, betyder det at upload lykkedes
        if (response.isNotEmpty) {
          print('Upload successful - got path: $response');
          // Get the public URL
          final publicUrl = Supabase.instance.client.storage
              .from('images')
              .getPublicUrl(fileName);
          print('Image uploaded successfully. Public URL: $publicUrl');

          // Gem URL'en i databasen med det samme
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
    final XFile? image = await showModalBottomSheet<XFile?>(
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

  Future<void> handleSave(
    BuildContext context,
    WidgetRef ref, {
    required String firstName,
    required String lastName,
    required String company,
  }) async {
    try {
      final profileImageUrl = ref.read(profileImageProvider) ?? '';
      print('Current image URL from provider: $profileImageUrl');

      await ref.read(profileNotifierProvider.notifier).updateProfile(
            firstName: firstName,
            lastName: lastName,
            company: company,
            profileImage: profileImageUrl,
          );

      if (context.mounted) {
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
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const CustomText(
                text: 'Error',
                type: CustomTextType.head,
              ),
              content: CustomText(
                text: 'Failed to update profile: $e',
                type: CustomTextType.bread,
              ),
              actions: [
                CustomButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Close',
                  buttonType: CustomButtonType.primary,
                ),
              ],
            );
          },
        );
      }
    }
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
        final currentImageUrl = ref.watch(profileImageProvider);
        print('Current profile image URL in build: $currentImageUrl');

        useEffect(() {
          profileAsync.whenData((profile) {
            print('Profile data loaded: $profile');
            firstNameController.text = profile['first_name'] ?? '';
            lastNameController.text = profile['last_name'] ?? '';
            companyController.text = profile['company'] ?? '';

            // Opdater kun provider hvis værdien er forskellig
            final newImageUrl = profile['profile_image']?.toString() ?? '';
            if (newImageUrl.isNotEmpty &&
                newImageUrl != ref.read(profileImageProvider)) {
              print('Setting initial profile image: $newImageUrl');
              // Wrap provider update i Future for at undgå build-time modification
              Future(() {
                ref.read(profileImageProvider.notifier).state = newImageUrl;
              });
            }
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
                            backgroundImage:
                                ref.watch(profileImageProvider) != null
                                    ? NetworkImage(
                                        '${ref.watch(profileImageProvider)!}?v=${DateTime.now().millisecondsSinceEpoch}',
                                        headers: const {
                                          'Cache-Control': 'no-cache',
                                        },
                                      )
                                    : null,
                            child: ref.watch(profileImageProvider) == null
                                ? const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => handleImageSelection(context, ref),
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
                          handleSave(
                            context,
                            ref,
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            company: companyController.text,
                          );
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
