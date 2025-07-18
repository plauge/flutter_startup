# Flutter App Development Rules

This directory contains development rules and conventions for the Flutter app. All rules are automatically applied during development.

## Rule Files Overview

### Core Rules

- **`mandatory.mdc`**: General guidelines and architectural principles
- **`app-security.mdc`**: Authentication and security patterns
- **`code-generation.mdc`**: Build runner and generated code practices

### UI & Testing Rules

- **`ui-general.mdc`**: UI components, styling, and **MANDATORY test keys**
- **`testing.mdc`**: Comprehensive testing practices and test key conventions
- **`route-rules.mdc`**: Navigation and screen creation with test key requirements

### Code Quality

- **`code-of-conduct.mdc`**: Dart/Flutter best practices including test key requirements

## 🔑 TEST KEYS - MANDATORY REQUIREMENT

**ALL interactive UI elements MUST have test keys for reliable automated testing.**

### Quick Reference:

```dart
// Buttons
CustomButton(
  key: const Key('login_main_button'),
  onPressed: () => _performLogin(),
  text: 'Login',
)

// Form Fields
TextFormField(
  key: const Key('login_email_field'),
  decoration: AppTheme.getTextFieldDecoration(context),
)

// Interactive Cards
GestureDetector(
  key: const Key('contact_profile_card'),
  onTap: () => _navigateToProfile(),
  child: CustomCard(...),
)
```

### Naming Convention:

- **Buttons**: `action_context_button` (e.g., `login_main_button`)
- **Form Fields**: `screen_field_name_field` (e.g., `profile_email_field`)
- **Cards/Navigation**: `content_type_card` (e.g., `contact_profile_card`)
- **Use snake_case**: Always descriptive and specific

## Integration Tests

- Update test helpers to use test keys instead of text-based finding
- Create reusable helper methods for common actions
- See `testing.mdc` for comprehensive test patterns and examples

## Enforcement

These rules are automatically applied in Cursor IDE. When creating new widgets:

1. ✅ **Always add appropriate test keys**
2. ✅ **Follow naming conventions**
3. ✅ **Update integration tests when needed**
4. ✅ **Include test keys in code reviews**

For detailed examples and patterns, see individual rule files.

// Created on 2024-12-30 at 14:45
