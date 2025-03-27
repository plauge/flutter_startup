# Navigation Guidelines

## Navigation Rules

- When using GoRouter then use GoRouter.info and not '/onboarding/info'
- Implement auth-based guards
- Follow route naming conventions
- Handle deep linking properly

## Route Implementation

i @app_router.app skal routes laves som dette eksempel:

```dart
GoRoute(
  path: RoutePaths.splash,
  pageBuilder: (context, state) => _buildPageWithTransition(
    key: state.pageKey,
    child: const SplashScreen(),
  ),
),
```
