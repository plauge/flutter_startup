import '../exports.dart';
import 'dart:async';
import 'dart:io';
import '../core/config/env_config.dart';

// A passive widget that periodically checks Supabase reachability and
// redirects to the no-connection page when offline. It also stores the
// last valid location so we can return when online again.
class SupabaseConnectionGuard extends ConsumerStatefulWidget {
  const SupabaseConnectionGuard({super.key});

  @override
  ConsumerState<SupabaseConnectionGuard> createState() => _SupabaseConnectionGuardState();
}

class _SupabaseConnectionGuardState extends ConsumerState<SupabaseConnectionGuard> {
  Timer? _timer;
  Timer? _retryTimer;
  bool _checking = false;
  int _consecutiveFailures = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_checking) {
        _check();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (!mounted || _checking) return;
    _checking = true;
    try {
      final host = Uri.parse(EnvConfig.supabaseUrl).host;
      final result = await InternetAddress.lookup(host).timeout(const Duration(seconds: 3));
      final online = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      if (online) {
        _consecutiveFailures = 0;
        _retryTimer?.cancel();
        _retryTimer = null;
        if (ref.read(networkOfflineProvider)) {
          ref.read(networkOfflineProvider.notifier).state = false;
        }
        _checking = false;
        return;
      }
      await _handleConnectionFailure();
    } catch (_) {
      await _handleConnectionFailure();
    } finally {
      if (mounted && (_retryTimer?.isActive != true)) {
        _checking = false;
      }
    }
  }

  Future<void> _handleConnectionFailure() async {
    if (!mounted) return;
    _consecutiveFailures++;
    if (_consecutiveFailures < _maxRetries) {
      _retryTimer?.cancel();
      _retryTimer = Timer(_retryDelay, () {
        if (mounted && !_checking) {
          _check();
        }
      });
    } else {
      _consecutiveFailures = 0;
      _retryTimer?.cancel();
      _retryTimer = null;
      _checking = false;
      _markOfflineAndRedirect();
    }
  }

  void _markOfflineAndRedirect() {
    if (!mounted) return;
    ref.read(networkOfflineProvider.notifier).state = true;
    final current = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (current != RoutePaths.noConnection) {
      ref.read(lastLocationProvider.notifier).state = current;
      context.go(RoutePaths.noConnection);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _retryTimer?.cancel();
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

