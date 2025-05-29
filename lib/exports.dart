// External packages
export 'package:flutter/material.dart';
export 'package:gap/gap.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:go_router/go_router.dart';
export 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
export 'package:shared_preferences/shared_preferences.dart';

// Utils
export 'utils/aes_gcm_encryption_utils.dart';
export 'utils/app_logger.dart';

// Theme
export 'theme/app_dimensions_theme.dart';
export 'theme/app_colors.dart';
export 'theme/app_theme.dart';

// Screens
export 'screens/authenticated/qr/qr_screen.dart';
export 'screens/authenticated/qr/scan_qr_code.dart';
export 'screens/authenticated/home.dart';
export 'screens/authenticated/second_page.dart';
export 'screens/authenticated/profile.dart';
export 'screens/authenticated/profile_edit.dart';
export 'screens/authenticated/contacts.dart';
export 'screens/authenticated/demo.dart';
export 'screens/authenticated/terms_of_service.dart';
export 'screens/authenticated/test/banan.dart';
export 'screens/authenticated/test/citron.dart';
export 'screens/authenticated/test/fredag.dart';
export 'screens/authenticated/connect/level1/connect_level1_screen.dart';
export 'screens/authenticated/connect/level1/qr_code_screen.dart';
export 'screens/authenticated/connect/level1/scan_qr_code_screen.dart';
export 'screens/authenticated/connect/level1/confirm_connection_level1_screen.dart';
export 'screens/authenticated/connect/level3/connect_level3_screen.dart';
export 'screens/authenticated/connect/level3/confirm_connection_screen.dart';
export 'screens/authenticated/security_key.dart';
export 'providers/invitation_level3_provider.dart';
export 'services/invitation_level3_service.dart';
export 'screens/authenticated/onboarding/profile.dart' show OnboardingProfileScreen;
export 'screens/authenticated/onboarding/pin.dart' show OnboardingPINScreen;
export 'screens/authenticated/onboarding/pin_confirm.dart' show OnboardingPINConfirmScreen;
export 'screens/authenticated/onboarding/profile_image.dart' show OnboardingProfileImageScreen;
export 'screens/authenticated/onboarding/complete.dart';
//export 'screens/authenticated/test/form.dart';
//export 'screens/authenticated/test/result.dart';
//export 'screens/authenticated/test/swipe_test.dart';
export 'screens/unauthenticated/auth/login.dart';
export 'screens/unauthenticated/auth/login_magic_link.dart';
export 'screens/unauthenticated/auth/login_email_password.dart';
export 'screens/unauthenticated/auth/forgot_password.dart';
export 'screens/unauthenticated/auth/check_email.dart';
export 'screens/unauthenticated/auth/auth_callback_screen.dart';
export 'screens/common/splash_screen.dart';
export 'screens/authenticated/connect/connect_screen.dart';
export 'screens/authenticated/connect/level1/connect_level1_screen.dart';
export 'screens/authenticated/connect/level1/qr_code_screen.dart';
export 'screens/authenticated/connect/level1/scan_qr_code_screen.dart';
export 'screens/authenticated/connect/level3/connect_level3_screen.dart';
export 'screens/authenticated/connect/level3/confirm_connection_screen.dart';
export 'screens/authenticated/security_key.dart';
export 'screens/authenticated/connect/level1/qr_code_screen.dart';
export 'providers/invitation_level1_provider.dart';
export 'services/invitation_level1_service.dart';
export 'widgets/custom/custom_snackbar.dart';

// Providers
export 'providers/counter_provider.dart';
export 'providers/auth_provider.dart';
export 'providers/storage/storage_provider.dart';
export 'providers/storage/app_settings_provider.dart';
export 'providers/contacts_provider.dart';
export 'providers/profile_provider.dart';
export 'providers/supabase_provider.dart';
export 'providers/invitation_level3_provider.dart';
export 'providers/confirms_provider.dart';

// Models
export 'models/app_user.dart';
export 'models/user_extra.dart';
export 'models/contact.dart';

// Services
export 'services/supabase_service.dart';
export 'services/storage/standard_storage_service.dart';
export 'services/storage/secure_storage_service.dart';
export 'services/profile_service.dart';
export 'services/invitation_level3_service.dart';
export 'services/confirms_service.dart';

// Core
export 'core/widgets/screens/base_screen.dart';
export 'core/widgets/screens/authenticated_screen.dart';
export 'core/widgets/screens/unauthenticated_screen.dart';
export 'core/widgets/screens/authenticated_screen_helpers/supabase_validation.dart';
export 'core/widgets/screens/authenticated_screen_helpers/app_store_tester_setup.dart';
export 'core/auth/authenticated_state.dart';
export 'core/router/app_router.dart';
export 'core/interfaces/storage_interface.dart';
export 'core/constants/storage_constants.dart';
export 'core/constants/app_constants.dart';
export 'core/constants/app_version_constants.dart';
export 'widgets/face_id_button.dart';
export 'providers/user_extra_provider.dart';

// Widgets
export 'widgets/storage/storage_test_widget.dart';
export 'widgets/storage/storage_test_token.dart';
export 'widgets/custom_elevated_button.dart';
export 'widgets/auth/magic_link_form.dart';
export 'widgets/auth/email_password_form.dart';
export 'widgets/auth/forgot_password_form.dart';
export 'widgets/auth/reset_password_form.dart';
export 'widgets/auth/create_user_form.dart';
export 'widgets/auth/check_email.dart';
export 'widgets/confirm/slide/persistent_swipe_button.dart';
export 'screens/unauthenticated/auth/login_landing_page.dart';
export 'widgets/jwt/user_profile_widget.dart';
// export 'widgets/jwt/list/contacts_all.dart';
export 'widgets/app_bars/authenticated_app_bar.dart';
export 'widgets/drawers/main_drawer.dart';
export 'widgets/cards/menu_item_card.dart';
export 'screens/authenticated/onboarding/profile.dart' show OnboardingProfileScreen;
export 'screens/authenticated/contact_verification.dart';
export 'screens/authenticated/settings.dart';
export 'widgets/contacts/contact_list_tile.dart';
export 'widgets/custom/custom_button.dart';
export 'widgets/custom/custom_info_button.dart';
export 'widgets/custom/custom_level_label.dart';
export 'widgets/custom/custom_card.dart';
export 'widgets/custom/custom_card_batch.dart';
export 'widgets/custom/custom_text.dart';
export 'widgets/custom/custom_text_form_field.dart';
export 'screens/authenticated/onboarding/begin.dart' show OnboardingBeginScreen;
export 'widgets/contacts/tabs/pending_invitations_widget.dart';
export 'screens/authenticated/security/enter_pincode.dart';
export 'screens/authenticated/system_status/maintenance_screen.dart';
export 'screens/authenticated/system_status/update_app_screen.dart';
export 'screens/authenticated/system_status/invalid_secure_key_screen.dart';
export 'widgets/custom/custom_profile_image.dart';

// Route Explorer
export 'features/route_explorer/route_explorer.dart';

// New exports
export 'screens/authenticated/auth/reset_password.dart';
