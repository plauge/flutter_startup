// External packages
export 'package:flutter/material.dart';
export 'package:gap/gap.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:go_router/go_router.dart';
export 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

// Theme
export 'theme/app_dimensions_theme.dart';
export 'theme/app_colors.dart';
export 'theme/app_theme.dart';

// Screens
export 'screens/home.dart';
export 'screens/second_page.dart';
export 'screens/auth/login.dart';
export 'screens/auth/check_email.dart';
export 'screens/splash_screen.dart';

// Providers
export 'providers/counter_provider.dart';
export 'providers/auth_provider.dart';

// Models
export 'models/app_user.dart';

// Services
export 'services/supabase_service.dart';

// Core
export 'core/widgets/screens/base_screen.dart';
export 'core/widgets/screens/authenticated_screen.dart';
export 'core/widgets/screens/unauthenticated_screen.dart';
export 'core/auth/authenticated_state.dart';
export 'core/router/app_router.dart';

// Widgets
export 'widgets/auth/login_form.dart';
export 'widgets/auth/create_form.dart';
export 'widgets/auth/check_email.dart';
export 'widgets/jwt/user_profile_widget.dart';
