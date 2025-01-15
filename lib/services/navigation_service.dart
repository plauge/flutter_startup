import '../exports.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  bool _isInternalNavigation = false;

  Future<void> internalNavigate(BuildContext context, String route,
      {Object? extra}) async {
    _isInternalNavigation = true;
    try {
      await context.push(route, extra: extra);
    } finally {
      // Vi venter med at sætte flag til false indtil navigationen er færdig
      Future.delayed(const Duration(milliseconds: 100), () {
        _isInternalNavigation = false;
      });
    }
  }

  bool get isInternalNavigation => _isInternalNavigation;
}
