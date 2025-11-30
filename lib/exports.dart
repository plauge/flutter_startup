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
export 'screens/authenticated/qr/qr_code_result.dart';
export 'screens/authenticated/qr/qr_code_scanning.dart';
export 'screens/authenticated/home.dart';
export 'screens/authenticated/pin_protected/second_page.dart';
export 'screens/authenticated/pin_protected/profile.dart';
export 'screens/authenticated/pin_protected/profile_edit.dart';
export 'screens/authenticated/pin_protected/contacts.dart';
export 'screens/authenticated/pin_protected/demo.dart';
export 'screens/authenticated/terms_of_service.dart';
export 'screens/authenticated/test/banan.dart';
export 'screens/authenticated/test/citron.dart';
export 'screens/authenticated/test/fredag.dart';
export 'screens/authenticated/pin_protected/connect/level1/level_1_create_or_scan_qr_selector.dart';
export 'screens/authenticated/pin_protected/connect/level1/level_1_qr_code_creator.dart';
export 'screens/authenticated/pin_protected/connect/level1/level_1_qr_code_scanner.dart';
export 'screens/authenticated/pin_protected/connect/level1/level_1_confirm_connection.dart';
export 'screens/authenticated/pin_protected/connect/level3/level_3_link_generator.dart';
export 'screens/authenticated/pin_protected/connect/level3/level_3_confirm_connection.dart';
export 'screens/authenticated/pin_protected/security_key.dart';
export 'screens/authenticated/pin_protected/change_pin_code.dart';
export 'screens/authenticated/pin_protected/update_security_key.dart';
export 'screens/authenticated/web/web_code.dart';
export 'screens/authenticated/phone_code/phone_code_screen.dart';
export 'screens/authenticated/phone_code/phone_code_history_screen.dart';
export 'screens/authenticated/text_code/text_code_screen.dart';
export 'screens/authenticated/pin_protected/phone_numbers.dart';
export 'providers/invitation_level3_provider.dart';
export 'providers/analytics_provider.dart';
export 'providers/security_demo_text_code_provider.dart';
export 'services/invitation_level3_service.dart';
export 'screens/authenticated/onboarding/profile.dart' show OnboardingProfileScreen;
export 'screens/authenticated/onboarding/pin.dart' show OnboardingPINScreen;
export 'screens/authenticated/onboarding/pin_confirm.dart' show OnboardingPINConfirmScreen;
export 'screens/authenticated/onboarding/phone_number.dart' show OnboardingPhoneNumberScreen;
export 'screens/authenticated/onboarding/profile_image.dart' show OnboardingProfileImageScreen;
export 'screens/authenticated/onboarding/complete.dart';
//export 'screens/authenticated/test/form.dart';
//export 'screens/authenticated/test/result.dart';
//export 'screens/authenticated/test/swipe_test.dart';
export 'screens/unauthenticated/auth/login.dart';
export 'screens/unauthenticated/auth/login_magic_link.dart';
export 'screens/unauthenticated/auth/login_email_password.dart';
export 'screens/unauthenticated/auth/forgot_password.dart';
export 'screens/unauthenticated/auth/reset_password.dart';
export 'screens/unauthenticated/auth/password_reset_success.dart';
export 'screens/unauthenticated/auth/password_reset_error.dart';
export 'screens/unauthenticated/auth/check_email.dart';
export 'screens/unauthenticated/auth/auth_callback_screen.dart';
export 'screens/unauthenticated/no_connection_screen.dart';
export 'screens/common/splash_screen.dart';
export 'screens/authenticated/pin_protected/connect/connect_screen.dart';
export 'providers/invitation_level1_provider.dart';
export 'services/invitation_level1_service.dart';
export 'widgets/custom/custom_snackbar.dart';
export 'services/i18n_service.dart';

// Providers
export 'providers/counter_provider.dart';
export 'providers/auth_provider.dart';
export 'providers/storage/storage_provider.dart';
export 'providers/storage/app_settings_provider.dart';
export 'providers/contacts_provider.dart';
export 'providers/contacts_realtime_provider.dart';
export 'providers/confirms_realtime_provider.dart';
export 'providers/profile_provider.dart';
export 'providers/home_version_provider.dart';
export 'providers/text_code_search_result_provider.dart';
export 'providers/supabase_provider.dart';
export 'providers/supabase_network_provider.dart';
export 'providers/confirms_provider.dart';
export 'providers/phone_codes_provider.dart';
export 'providers/phone_code_create_provider.dart';
export 'providers/phone_codes_cancel_provider.dart';
export 'providers/phone_codes_timeout_provider.dart';
export 'providers/phone_numbers_provider.dart';
export 'providers/phone_numbers_create_provider.dart';
export 'providers/phone_numbers_delete_provider.dart';
export 'providers/phone_code_realtime_provider.dart';
export 'providers/contacts_count_provider.dart';
export 'providers/security_app_status_provider.dart';
export 'providers/security_pin_code_provider.dart';
export 'providers/security_pin_code_update_provider.dart';
export 'providers/phone_number_validation_send_pin_provider.dart';
export 'providers/text_codes_provider.dart';
export 'providers/text_code_create_provider.dart';
export 'providers/fcm_token_provider.dart';
export 'providers/user_notification_realtime_provider.dart';
export 'providers/get_encrypted_phone_number_provider.dart';
export 'providers/do_contacts_have_phone_number_provider.dart';
export 'providers/contact_get_my_encrypted_key_provider.dart';
export 'providers/help_active_provider.dart';
export 'providers/security_update_user_extra_latest_load_if_recent_provider.dart';

// Models
export 'models/app_user.dart';
export 'models/user_extra.dart';
export 'models/contact.dart';
export 'models/contact_realtime.dart';
export 'models/confirms_realtime.dart';
export 'models/confirm_payload.dart';
export 'models/confirm_state.dart';
export 'models/confirm_v2_step.dart';
export 'models/phone_code.dart';
export 'models/phone_codes_get_log_response.dart';
export 'models/phone_code_create_response.dart';
export 'models/phone_numbers_response.dart';
export 'models/text_codes_read_response.dart';
export 'models/text_code_create_response.dart';
export 'models/security_app_status_response.dart';
export 'models/user_notification_realtime.dart';
export 'models/get_encrypted_phone_number_response.dart';
export 'models/do_contacts_have_phone_number_response.dart';

// Services
export 'services/api_logging_service.dart';
export 'services/supabase_service.dart';
export 'services/storage/standard_storage_service.dart';
export 'services/storage/secure_storage_service.dart';
export 'services/profile_service.dart';
export 'services/confirms_service.dart';
export 'services/confirms_realtime_service.dart';
export 'services/phone_codes_service.dart';
export 'services/phone_code_create_service.dart';
export 'services/phone_numbers_service.dart';
export 'services/phone_numbers_create_service.dart';
export 'services/phone_numbers_delete_service.dart';
export 'services/text_codes_service.dart';
export 'services/text_code_create_service.dart';
export 'services/phone_code_realtime_service.dart';
export 'services/contacts_realtime_service.dart';
export 'services/contacts_count_service.dart';
export 'services/security_app_status_service.dart';
export 'services/security_pin_code_service.dart';
export 'services/security_pin_code_update_service.dart';
export 'services/phone_number_validation_send_pin_service.dart';
export 'services/analytics_service.dart';
export 'services/security_demo_text_code_service.dart';
export 'services/fcm_token_lifecycle_service.dart';
export 'services/realtime_connection_service.dart';
export 'services/realtime_lifecycle_service.dart';
export 'services/user_notification_realtime_service.dart';
export 'services/get_encrypted_phone_number_service.dart';
export 'services/do_contacts_have_phone_number_service.dart';
export 'services/contact_get_my_encrypted_key_service.dart';
export 'services/security_update_user_extra_latest_load_if_recent_service.dart';

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
export 'core/constants/contacts_tab_state_constants.dart';
export 'core/constants/analytics_constants.dart';
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
export 'widgets/auth/reset_password_form_pin.dart';
export 'widgets/auth/login_pin_form.dart';
export 'widgets/auth/create_user_form.dart';
export 'widgets/auth/check_email.dart';
export 'widgets/auth/login_create_account_tabs.dart';
export 'widgets/auth/os/ios.dart';
export 'widgets/auth/os/android.dart';
export 'widgets/confirm/slide/persistent_swipe_button.dart';
export 'screens/unauthenticated/auth/login_landing_page.dart';
export 'widgets/jwt/user_profile_widget.dart';
export 'widgets/app_bars/authenticated_app_bar.dart';
export 'widgets/drawers/main_drawer.dart';
export 'widgets/cards/menu_item_card.dart';
export 'screens/authenticated/pin_protected/contact_verification.dart';
export 'screens/authenticated/settings.dart';
export 'screens/authenticated/pin_protected/delete_account.dart';
export 'widgets/contacts/contact_list_tile.dart';
export 'widgets/contacts/mother.dart';
export 'widgets/custom/custom_button.dart';
export 'widgets/custom/custom_info_button.dart';
export 'widgets/custom/custom_level_label.dart';
export 'widgets/custom/custom_card.dart';
export 'widgets/custom/custom_card_batch.dart';
export 'widgets/custom/custom_text.dart';
export 'widgets/custom/custom_text_form_field.dart';
export 'widgets/custom/custom_help_text.dart';
export 'widgets/custom/custom_code_validation.dart';
export 'widgets/supabase_connection_guard.dart';
export 'screens/authenticated/onboarding/begin.dart' show OnboardingBeginScreen;
export 'widgets/contacts/tabs/pending_invitations_widget.dart';
export 'screens/authenticated/security/enter_pincode.dart';
export 'screens/authenticated/system_status/maintenance_screen.dart';
export 'screens/authenticated/system_status/update_app_screen.dart';
export 'screens/authenticated/system_status/invalid_secure_key_screen.dart';
export 'widgets/custom/custom_profile_image.dart';

// Phone Codes Widgets
export 'widgets/phone_codes/phone_code_item_widget.dart';

// Phone Numbers Widgets
export 'widgets/phone_numbers/add_phone_number_modal.dart';

// Contacts Realtime Widgets
export 'widgets/contacts_realtime/contacts_realtime.dart';

// Modals
export 'widgets/modals/text_code_confirmation_modal.dart';
export 'widgets/modals/phone_code_confirmation_modal.dart';
export 'widgets/modals/phone_call_confirmation_modal.dart';
export 'widgets/modals/password_reset_error_modal.dart';
export 'widgets/modals/password_reset_success_modal.dart';

// Confirm V2 Widgets
export 'widgets/confirm_v2/actions_holder.dart';
export 'widgets/confirm_v2/confirm_v2.dart';
export 'widgets/confirm_v2/confirm_payload_test_data_widget.dart';
export 'widgets/confirm_v2/steps/confirm_v2_step1.dart';
export 'widgets/confirm_v2/steps/confirm_v2_step2.dart';
export 'widgets/confirm_v2/steps/confirm_v2_step3.dart';
export 'widgets/confirm_v2/steps/confirm_v2_step4.dart';
export 'widgets/confirm_v2/steps/confirm_v2_step5.dart';
export 'widgets/confirm_v2/steps/confirm_v2_step6.dart';
export 'widgets/confirm_v2/steps/confirm_v2_step7.dart';
export 'widgets/confirm_v2/steps/confirm_v2_step8.dart';

// Route Explorer
export 'features/route_explorer/route_explorer.dart';
