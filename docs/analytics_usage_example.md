# AnalyticsService Usage Guide

## Overview

AnalyticsService provides a vendor-agnostic interface for analytics tracking. Currently uses MixPanel as the backend but can be easily switched to other providers without changing consuming code.

## Key Features

- ✅ **Vendor Independence**: Easy to switch analytics providers
- ✅ **Privacy Protection**: Automatic salting of sensitive data (emails, IPs)
- ✅ **Debug Control**: Analytics can be disabled in debug mode
- ✅ **Consistent User ID**: Same email always produces same hash
- ✅ **Error Handling**: Graceful fallbacks if service fails

## Environment Configuration

Add to your environment files (.env.development, .env.production):

```bash
# MixPanel Configuration
MIXPANEL_TOKEN=your_production_token_here
MIXPANEL_DEV_TOKEN=your_development_token_here  # Optional
```

## Basic Usage

### 1. Initialize Analytics (automatically handled by provider)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exports.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Analytics service is automatically initialized
    final analytics = ref.read(analyticsServiceProvider);

    return YourWidget();
  }
}
```

### 2. Track User Identity

```dart
void _identifyUser(String userEmail) {
  final analytics = ref.read(analyticsServiceProvider);

  // Email is automatically salted for privacy
  analytics.identify(userEmail, {
    'signup_date': DateTime.now().toIso8601String(),
    'user_type': 'premium',
  });
}
```

### 3. Track Events

```dart
void _trackButtonClick() {
  final analytics = ref.read(analyticsServiceProvider);

  analytics.track('button_clicked', {
    'screen': 'home',
    'button_type': 'primary',
    'timestamp': DateTime.now().toIso8601String(),
  });
}

void _trackUserAction() {
  final analytics = ref.read(analyticsServiceProvider);

  analytics.track('user_completed_onboarding', {
    'completion_time_seconds': 120,
    'steps_completed': 5,
  });
}
```

### 4. Set User Properties

```dart
void _updateUserProfile() {
  final analytics = ref.read(analyticsServiceProvider);

  analytics.setUserProperties({
    'subscription_type': 'premium',
    'last_seen': DateTime.now().toIso8601String(),
    'feature_flags_enabled': ['dark_mode', 'beta_features'],
  });
}

void _incrementUsageCounter() {
  final analytics = ref.read(analyticsServiceProvider);

  analytics.incrementUserProperty('sessions_count');
  analytics.incrementUserProperty('actions_performed', 5);
}
```

### 5. Time Events

```dart
void _startTimingEvent() {
  final analytics = ref.read(analyticsServiceProvider);

  // Start timing
  analytics.timeEvent('profile_setup_duration');

  // ... user performs profile setup ...

  // Event will automatically include duration when tracked
  analytics.track('profile_setup_completed', {
    'fields_filled': 8,
    'profile_image_added': true,
  });
}
```

### 6. Register Global Properties

```dart
void _setGlobalProperties() {
  final analytics = ref.read(analyticsServiceProvider);

  // These properties are sent with every event
  analytics.registerSuperProperties({
    'app_version': AppVersionConstants.appVersion,
    'platform': Platform.isIOS ? 'iOS' : 'Android',
    'user_segment': 'power_user',
  });
}
```

### 7. Handle User Logout

```dart
void _handleLogout() {
  final analytics = ref.read(analyticsServiceProvider);

  // Track logout event
  analytics.track('user_logged_out');

  // Clear user data
  analytics.reset();
}
```

## Privacy & Security

### Automatic Data Salting

The service automatically salts sensitive data:

```dart
// These property keys trigger automatic salting:
analytics.track('user_action', {
  'user_email': 'user@example.com',  // ← Automatically salted
  'user_ip': '192.168.1.1',         // ← Automatically salted
  'user_id': 'user123',             // ← Automatically salted
  'screen_name': 'profile',         // ← Not salted (safe data)
});
```

### Sensitive Property Detection

Properties containing these keywords are automatically salted:

- `email`
- `ip`
- `address`
- `phone`
- `user_id` / `userid`

## Debug Mode Configuration

```dart
// In analytics_constants.dart
abstract class AnalyticsConstants {
  static const bool sendToAnalyticsWhileInDebug = false; // ← Change to true for testing
}
```

When `sendToAnalyticsWhileInDebug = false`:

- No analytics data is sent in debug mode
- Service initializes but doesn't connect to MixPanel
- All tracking calls are safely ignored

## Error Handling

The service handles errors gracefully:

```dart
// If analytics fails, your app continues working normally
analytics.track('important_event'); // ← Never throws exceptions

// Check initialization status if needed
final initStatus = ref.watch(analyticsInitializationProvider);
initStatus.when(
  data: (isInitialized) => Text('Analytics: ${isInitialized ? 'Ready' : 'Failed'}'),
  loading: () => Text('Initializing analytics...'),
  error: (error, _) => Text('Analytics unavailable'),
);
```

## Common Usage Patterns

### Screen Tracking

```dart
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);

    // Track screen view
    useEffect(() {
      analytics.track('screen_viewed', {
        'screen_name': 'profile',
        'visit_timestamp': DateTime.now().toIso8601String(),
      });
      return null;
    }, []);

    return Scaffold(/* ... */);
  }
}
```

### Form Analytics

```dart
void _trackFormCompletion() {
  final analytics = ref.read(analyticsServiceProvider);

  analytics.track('form_submitted', {
    'form_type': 'contact_form',
    'fields_filled': 5,
    'validation_errors': 0,
    'completion_time_seconds': 45,
  });
}
```

### E-commerce Events

```dart
void _trackPurchase() {
  final analytics = ref.read(analyticsServiceProvider);

  analytics.track('purchase_completed', {
    'transaction_id': 'txn_123456',
    'total_amount': 29.99,
    'currency': 'DKK',
    'items_count': 3,
    'payment_method': 'card',
  });
}
```

## Switching Analytics Providers

To switch from MixPanel to another provider (e.g., Google Analytics):

1. Update `AnalyticsService` implementation
2. Replace MixPanel SDK with new provider
3. Keep the same public interface
4. Update environment configuration
5. **No changes needed in consuming code!**

## Best Practices

1. **Track User Intent**: Focus on what users are trying to accomplish
2. **Consistent Naming**: Use snake_case for event and property names
3. **Meaningful Properties**: Include context that helps understand user behavior
4. **Privacy First**: Never log actual sensitive data - rely on automatic salting
5. **Performance**: Analytics tracking should never block UI operations

// Created on 2024-12-30 at 16:45
