import '../exports.dart';
import 'dart:async';
import 'dart:io';
import '../core/config/env_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SupabaseConnectionGuard extends ConsumerStatefulWidget {
  const SupabaseConnectionGuard({super.key});

  @override
  ConsumerState<SupabaseConnectionGuard> createState() => _SupabaseConnectionGuardState();
}

class _SupabaseConnectionGuardState extends ConsumerState<SupabaseConnectionGuard> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _pollTimer;
  static final log = scopedLogger(LogCategory.service);

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _verifyConnection());
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasNone = results.contains(ConnectivityResult.none) || results.isEmpty;
    log('[supabase_connection_guard.dart][_onConnectivityChanged] results=$results hasNone=$hasNone');
    if (hasNone) {
      _markOfflineAndRedirect();
    } else if (ref.read(networkOfflineProvider)) {
      _verifyConnection();
    }
  }

  Future<void> _verifyConnection() async {
    try {
      final host = Uri.parse(EnvConfig.supabaseUrl).host;
      final socket = await Socket.connect(host, 443, timeout: const Duration(seconds: 5));
      socket.destroy();
      if (ref.read(networkOfflineProvider) && mounted) {
        log('[supabase_connection_guard.dart][_verifyConnection] Connection restored');
        ref.read(networkOfflineProvider.notifier).state = false;
      }
    } catch (e) {
      log('[supabase_connection_guard.dart][_verifyConnection] Still offline: $e');
      if (mounted) _markOfflineAndRedirect();
    }
  }

  void _markOfflineAndRedirect() {
    if (!mounted) return;
    ref.read(networkOfflineProvider.notifier).state = true;
    final current = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (current != RoutePaths.noConnection) {
      log('[supabase_connection_guard.dart][_markOfflineAndRedirect] Redirecting from $current');
      ref.read(lastLocationProvider.notifier).state = current;
      context.go(RoutePaths.noConnection);
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (current == RoutePaths.noConnection) return const SizedBox();
    return const SizedBox();
  }
}

// Created: 2025-10-31 11:10
