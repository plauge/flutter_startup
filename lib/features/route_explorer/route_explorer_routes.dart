import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import 'route_explorer_screen.dart';

class RouteExplorerRoutes {
  static const routeExplorer = '/route-explorer';

  static GoRoute getRoute() {
    return GoRoute(
      path: routeExplorer,
      pageBuilder: (context, state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const RouteExplorerScreen(),
      ),
    );
  }

  static CustomTransitionPage<void> _buildPageWithTransition({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
  }
}
