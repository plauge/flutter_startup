export 'package:flutter/material.dart';
export 'package:gap/gap.dart';
export 'theme/app_dimensions_theme.dart';
export 'theme/app_colors.dart';
export 'theme/app_theme.dart';

export 'screens/home.dart';
export 'screens/second_page.dart';
export 'screens/login.dart';

export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'providers/counter_provider.dart';
export 'providers/router_provider.dart';
export 'providers/auth_provider.dart';

export 'package:go_router/go_router.dart';

export 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

// Models
export 'models/user.dart' hide User;
export 'package:supabase_flutter/supabase_flutter.dart' show User;
