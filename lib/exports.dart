// External packages
export 'package:flutter/material.dart';
export 'package:gap/gap.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:go_router/go_router.dart';
export 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
export 'package:shared_preferences/shared_preferences.dart';

// Theme
export 'theme/app_dimensions_theme.dart';
export 'theme/app_colors.dart';
export 'theme/app_theme.dart';

// Screens
export 'screens/authenticated/home.dart';
export 'screens/authenticated/second_page.dart';
export 'screens/authenticated/profile.dart';
export 'screens/authenticated/contacts.dart';
export 'screens/authenticated/demo.dart';
export 'screens/authenticated/terms_of_service.dart';
export 'screens/unauthenticated/auth/login.dart';
export 'screens/unauthenticated/auth/check_email.dart';
export 'screens/unauthenticated/auth/auth_callback_screen.dart';
export 'screens/common/splash_screen.dart';
export 'screens/authenticated/connect/connect_screen.dart';

// Providers
export 'providers/counter_provider.dart';
export 'providers/auth_provider.dart';
export 'providers/storage/storage_provider.dart';
export 'providers/storage/app_settings_provider.dart';
export 'providers/contacts_provider.dart';

// Models
export 'models/app_user.dart';
export 'models/user_extra.dart';
export 'models/contact.dart';

// Services
export 'services/supabase_service.dart';
export 'services/storage/standard_storage_service.dart';
export 'services/storage/secure_storage_service.dart';

// Core
export 'core/widgets/screens/base_screen.dart';
export 'core/widgets/screens/authenticated_screen.dart';
export 'core/widgets/screens/unauthenticated_screen.dart';
export 'core/auth/authenticated_state.dart';
export 'core/router/app_router.dart';
export 'core/interfaces/storage_interface.dart';
export 'core/constants/storage_constants.dart';
export 'widgets/face_id_button.dart';
export 'providers/user_extra_provider.dart';

// Widgets
export 'widgets/storage/storage_test_widget.dart';
export 'widgets/custom_elevated_button.dart';
export 'widgets/auth/login_form.dart';
export 'widgets/auth/magic_link_form.dart';
export 'widgets/auth/create_form.dart';
export 'widgets/auth/check_email.dart';
export 'screens/unauthenticated/auth/login_landing_page.dart';
export 'widgets/jwt/user_profile_widget.dart';
// export 'widgets/jwt/list/contacts_all.dart';
export 'widgets/app_bars/authenticated_app_bar.dart';
export 'widgets/drawers/main_drawer.dart';
export 'widgets/cards/menu_item_card.dart';
export 'screens/authenticated/onboarding/personal_info.dart';
export 'screens/authenticated/contact_verification.dart';
export 'screens/authenticated/settings.dart';
export 'widgets/contacts/contact_list_tile.dart';
export 'widgets/custom/custom_button.dart';
export 'widgets/custom/custom_card.dart';
export 'widgets/custom/custom_text.dart';
