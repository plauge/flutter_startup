import '../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:riverpod/riverpod.dart' as riverpod;
import '../../services/i18n_service.dart';
import 'dart:io';
import '../../providers/home_version_provider.dart';

class ProfileEditScreen extends AuthenticatedScreen {
  ProfileEditScreen({super.key}) : super(pin_code_protected: true);

  static Future<ProfileEditScreen> create() async {
    final screen = ProfileEditScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _trackProfileEditEvent(WidgetRef ref, String eventType, String action, {Map<String, String>? additionalData}) {
    final analytics = ref.read(analyticsServiceProvider);
    final eventData = {
      'event_type': eventType,
      'action': action,
      'screen': 'profile_edit',
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (additionalData != null) {
      eventData.addAll(additionalData);
    }
    analytics.track('profile_edit_event', eventData);
  }

  final userIdProvider = riverpod.Provider<String>((ref) => Supabase.instance.client.auth.currentUser?.id ?? '');

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
      final resizedImage = img.copyResize(croppedImage, width: 400, height: 400);
      final jpegImage = img.encodeJpg(resizedImage, quality: 40);
      print('Image cropped, resized and compressed: ${jpegImage.length} bytes');

      final fileName = '$userId/profile.jpg';
      print('Uploading to path: $fileName');

      try {
        print('Starting Supabase upload...');
        final response = await Supabase.instance.client.storage.from('images').uploadBinary(
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

        if (response.isNotEmpty) {
          print('Upload successful - got path: $response');
          final publicUrl = Supabase.instance.client.storage.from('images').getPublicUrl(fileName);
          print('Image uploaded successfully. Public URL: $publicUrl');

          try {
            print('Attempting to save URL to database...');
            final updateResponse = await Supabase.instance.client.from('profiles').update({'profile_image': publicUrl}).eq('user_id', userId);
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
    _trackProfileEditEvent(ref, 'image_selection', 'modal_opened');
    final ImagePicker picker = ImagePicker();
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: CustomText(
                  text: I18nService().t('screen_profile_edit.edit_profile_take_photo_button', fallback: 'Take a photo'),
                  type: CustomTextType.bread,
                ),
                onTap: () async {
                  _trackProfileEditEvent(ref, 'image_selection', 'camera_selected');
                  Navigator.pop(context);
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    _trackProfileEditEvent(ref, 'image_upload', 'camera_upload_started');
                    final userId = ref.read(userIdProvider);
                    print('Camera photo selected. User ID: $userId');
                    final imageUrl = await uploadImageToSupabase(photo.path, userId);
                    print('Received image URL from upload: $imageUrl');
                    if (imageUrl != null) {
                      _trackProfileEditEvent(ref, 'image_upload', 'camera_upload_success');
                      print('Setting image URL in provider: $imageUrl');
                      ref.read(profileImageProvider.notifier).state = imageUrl;
                    } else {
                      _trackProfileEditEvent(ref, 'image_upload', 'camera_upload_failed');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: CustomText(
                  text: I18nService().t('screen_profile_edit.edit_profile_choose_from_gallery_button', fallback: 'Choose from gallery'),
                  type: CustomTextType.bread,
                ),
                onTap: () async {
                  _trackProfileEditEvent(ref, 'image_selection', 'gallery_selected');
                  Navigator.pop(context);
                  final XFile? galleryImage = await picker.pickImage(source: ImageSource.gallery);
                  if (galleryImage != null) {
                    _trackProfileEditEvent(ref, 'image_upload', 'gallery_upload_started');
                    final userId = ref.read(userIdProvider);
                    print('Gallery image selected. User ID: $userId');
                    final imageUrl = await uploadImageToSupabase(galleryImage.path, userId);
                    print('Received image URL from upload: $imageUrl');
                    if (imageUrl != null) {
                      _trackProfileEditEvent(ref, 'image_upload', 'gallery_upload_success');
                      print('Setting image URL in provider: $imageUrl');
                      ref.read(profileImageProvider.notifier).state = imageUrl;
                    } else {
                      _trackProfileEditEvent(ref, 'image_upload', 'gallery_upload_failed');
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
    _trackProfileEditEvent(ref, 'profile_save', 'save_initiated');
    try {
      final profileImageUrl = ref.read(profileImageProvider) ?? '';
      print('Current image URL from provider: $profileImageUrl');

      await ref.read(profileNotifierProvider.notifier).updateProfile(
            firstName: firstName,
            lastName: lastName,
            company: company,
            profileImage: profileImageUrl,
          );

      _trackProfileEditEvent(ref, 'profile_save', 'save_success');
      if (context.mounted) {
        CustomSnackBar.show(
            context: context,
            text: I18nService().t('screen_profile_edit.edit_profile_save_changes_button_description', fallback: 'Your profile has been updated'),
            type: CustomTextType.button,
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 5));
      }
    } catch (e) {
      _trackProfileEditEvent(ref, 'profile_save', 'save_failed', additionalData: {'error': e.toString()});
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          text: I18nService().t('screen_profile_edit.edit_profile_save_changes_button_error', fallback: 'Failed to save changes'),
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
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

            final newImageUrl = profile['profile_image']?.toString() ?? '';
            if (newImageUrl.isNotEmpty && newImageUrl != ref.read(profileImageProvider)) {
              print('Setting initial profile image: $newImageUrl');
              Future(() {
                ref.read(profileImageProvider.notifier).state = newImageUrl;
              });
            }
          });
          return null;
        }, [profileAsync]);

        return Scaffold(
          appBar: AuthenticatedAppBar(
            title: I18nService().t('screen_profile_edit.edit_profile_header', fallback: 'Edit Profile'),
            backRoutePath: RoutePaths.settings,
          ),
          body: profileAsync.when(
            data: (_) => AppTheme.getParentContainerStyle(context).applyToContainer(
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomProfileImage(
                      profileImageProvider: ref.watch(profileImageProvider),
                      handleImageSelection: (context, ref) => handleImageSelection(context, ref),
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomText(
                      text: I18nService().t('screen_profile_edit.edit_profile_first_name_label', fallback: 'First name'),
                      type: CustomTextType.label,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomTextFormField(
                      key: const Key('profile_edit_first_name_field'),
                      controller: firstNameController,
                      labelText: I18nService().t('screen_profile_edit.edit_profile_first_name_label', fallback: 'First name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return I18nService().t('screen_profile_edit.edit_profile_first_name_error', fallback: 'Please enter your first name');
                        }
                        return null;
                      },
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomText(
                      text: I18nService().t('screen_profile_edit.edit_profile_last_name_label', fallback: 'Last name'),
                      type: CustomTextType.label,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomTextFormField(
                      key: const Key('profile_edit_last_name_field'),
                      controller: lastNameController,
                      labelText: I18nService().t('screen_profile_edit.edit_profile_last_name_label', fallback: 'Last name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return I18nService().t('screen_profile_edit.edit_profile_last_name_error', fallback: 'Please enter your last name');
                        }
                        return null;
                      },
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    CustomText(
                      text: I18nService().t('screen_profile_edit.edit_profile_company_label', fallback: 'Company'),
                      type: CustomTextType.label,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomTextFormField(
                      key: const Key('profile_edit_company_field'),
                      controller: companyController,
                      labelText: I18nService().t('screen_profile_edit.edit_profile_company_optional_label', fallback: 'Company (Optional)'),
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    const Divider(),
                    CustomText(
                      text: I18nService().t('screen_profile_edit.edit_profile_email_label', fallback: 'Email') + ': ${state.user.email}',
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.center,
                    ),
                    const Divider(),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    Consumer(
                      builder: (context, ref, child) {
                        final homeVersionAsync = ref.watch(homeVersionProvider);
                        return homeVersionAsync.when(
                          data: (version) {
                            final isBetaActive = version == 2;
                            return Row(
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text: I18nService().t(
                                      'screen_profile_edit.activate_beta_label',
                                      fallback: 'Activate Beta',
                                    ),
                                    type: CustomTextType.bread,
                                  ),
                                ),
                                Switch(
                                  key: const Key('profile_edit_beta_switch'),
                                  value: isBetaActive,
                                  onChanged: (value) {
                                    final newVersion = value ? 2 : 1;
                                    ref.read(homeVersionProvider.notifier).setVersion(newVersion);
                                    _trackProfileEditEvent(
                                      ref,
                                      'beta_toggle',
                                      value ? 'beta_enabled' : 'beta_disabled',
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, stack) => const SizedBox.shrink(),
                        );
                      },
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomButton(
                      key: const Key('profile_edit_save_button'),
                      onPressed: () {
                        _trackProfileEditEvent(ref, 'form_interaction', 'save_button_pressed');
                        if (formKey.currentState!.validate()) {
                          handleSave(
                            context,
                            ref,
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            company: companyController.text,
                          );
                        } else {
                          _trackProfileEditEvent(ref, 'form_validation', 'validation_failed');
                        }
                      },
                      text: I18nService().t('screen_profile_edit.edit_profile_save_changes_button', fallback: 'Save Changes'),
                      buttonType: CustomButtonType.primary,
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: CustomText(
                text: I18nService().t(
                  'screen_profile_edit.edit_profile_error_loading_profile',
                  fallback: 'Error loading profile: $error',
                  variables: {'error': error.toString()},
                ),
                type: CustomTextType.info,
              ),
            ),
          ),
        );
      },
    );
  }
}
