# Authentication Guidelines

## Authentication

- Use Supabase PKCE flow
- Implement proper auth state handling
- Use AuthenticatedScreen and UnauthenticatedScreen base classes
- Handle email verification flow

## Screen Authentication Structure

### Authenticated Screens:

- Must import from '../exports.dart'
- Must extend AuthenticatedScreen
- Must implement buildAuthenticatedWidget with (BuildContext, WidgetRef, AuthenticatedState)
- Constructor must NOT be const (due to runtime validation)
- Must implement static create() method for safe instantiation:
  ```dart
  static Future<ScreenName> create() async {
    final screen = ScreenName();
    return AuthenticatedScreen.create(screen);
  }
  ```
- Used for pages requiring user login

### Unauthenticated Screens:

- Must import from '../../exports.dart'
- Must extend UnauthenticatedScreen
- Must implement buildUnauthenticatedWidget with (BuildContext, WidgetRef)
- Used for pages accessible without login
