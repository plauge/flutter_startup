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
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
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
        if (ref.read(networkOfflineProvider)) {
          ref.read(networkOfflineProvider.notifier).state = false;
        }
        _checking = false;
        return;
      }
      _markOfflineAndRedirect();
    } catch (_) {
      _markOfflineAndRedirect();
    } finally {
      _checking = false;
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

