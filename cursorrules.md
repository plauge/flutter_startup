Her er hele `.cursorrules`-filen omskrevet i **Markdown (.md) format** for bedre læsbarhed og vedligeholdelse:

---

- Du må ikke ændre på Supabase.initialize funktionen
- Du må ikke skrive kode der ikke virker
- Du skal være sikker på at den kode du skriver, virker og er bedre end den kode du evt erstater
- Du må ikke fjerne kommentarer i koden, men mindre koden bliver fjernet.
- Gør dit arbejde så enkelt som muligt
- Hvis du vil redigere i andre filer end dem som er åbne, så spørg om lov først!
- Når du har udført din opgave så tjek altid alt dit arbejde igennem for linter-fejl.

# Cursor Rules

## General Guidelines

- **Use English**: All code and documentation should be written in English.
- **Declare Variable Types**: Always declare the type for each variable and function (parameters and return value).
- **Avoid `any` Type**: Do not use the `any` type.
- **Single Export Per File**: Only one export per file.
- **No Blank Lines in Functions**: Do not leave blank lines within a function.

## Key Principles

- **Concise Technical Code**: Write concise and technically accurate Dart code with precise examples.
- **Functional and Declarative Patterns**: Use functional and declarative programming patterns where appropriate.
- **Prefer Composition Over Inheritance**: Prefer composition instead of inheritance.
- **Descriptive Variable Names**: Use descriptive variable names with auxiliary verbs (e.g., `isLoading`, `hasError`).
- **File Structure Order**: Follow the order: exported widget, subwidgets, helpers, static content, types.

## Architecture

- **Layered Pattern**: Follow a layered architecture with models, services, providers, screens, and widgets.
  - **Models**: Data objects (e.g., User).
  - **Services**: API communication (e.g., SupabaseService).
  - **Providers**: State management with Riverpod.
  - **Screens**: UI components following authenticated/unauthenticated pattern.
  - **Widgets**: Reusable UI components.
- **Folder Structure**:
  - `lib/core/auth`: Authentication state management and logic.
  - `lib/core/widgets/screens`: Core screens for authenticated/unauthenticated flows.
  - `lib/models`: Data models like `app_user.dart`.
  - `lib/providers`: State providers for authentication, routing, and counter.
  - `lib/screens/auth`: Authentication screens like `login.dart`.
  - `lib/screens`: Main screens like `home.dart` and `second_page.dart`.
  - `lib/services`: Service classes for API and authentication.
  - `lib/theme`: Theme files like `app_colors.dart` and `app_theme.dart`.
  - `lib/widgets/jwt`: Widgets for JWT and user profile components.
  - `lib`: Main app entry points and exports.

## Dart/Flutter Rules

- **Use `const` Constructors**: For immutable widgets.
- **Use Freezed**: For immutable state classes and unions.
- **Arrow Syntax**: Use arrow syntax for simple functions.
- **Trailing Commas**: Use trailing commas for better formatting.
- **Expression Bodies**: Prefer expression bodies for one-line getters/setters.
- **Proper Dispose Method**: Implement proper widget disposal in `dispose()` method.

## Error Handling and Validation

- **Use AsyncValue**: For proper error handling.
- **Display Errors**: Use `SelectableText.rich` with red color for displaying errors.
- **Handle Empty States**: Manage empty states within screens.
- **Supabase Error Handling**: Implement proper error handling for Supabase operations.
  - **Note**: More detailed specifications for Supabase API handling will be added later.

## Riverpod Guidelines

- **Use @riverpod Annotation**: For generating providers.
- **Prefer AsyncNotifierProvider**: Over StateProvider.
- **Use `ref.watch()`**: For reactive state.
- **Use `ref.read()`**: For one-time actions.
- **Async Operation Cancellation**: Properly handle cancellation of async operations.

## UI and Styling

- **AppTheme**: Use AppTheme for consistent text styles.
- **AppDimensionsTheme**: For responsive spacing.
- **AppColors**: Use a consistent color scheme with AppColors.
- **Material 3**: Follow Material 3 design principles.
- **Responsive Design**: Use `MediaQuery` for proper responsiveness.

## Authentication

- **Supabase PKCE Flow**: Use Supabase PKCE flow for authentication.
- **Auth State Management**: Implement proper authentication state management.
- **Base Classes**: Use `AuthenticatedScreen` and `UnauthenticatedScreen` base classes.
- **Email Verification**: Implement email verification flow.

## Navigation

- **GoRouter**: Use GoRouter for navigation.
- **Auth-Based Navigation Guards**: Implement navigation guards based on authentication.
- **Route Naming Conventions**: Follow proper route naming conventions.
- **Deep Linking**: Handle deep linking appropriately.

## Performance

- **Use `const` Widgets**: Where possible to optimize performance.
- **List View Optimizations**: Implement proper list view optimizations.
- **Cached Network Images**: Use `cached_network_image` for remote images.
- **Performance Best Practices**: Follow Flutter performance best practices.

## Code Generation

- **Build Runner**: Use `build_runner` for code generation.
- **Freezed Models**: Generate models with Freezed.
- **Riverpod Providers**: Generate Riverpod providers.
- **JSON Serialization**: Generate JSON serialization.

## Documentation

- **Complex Logic**: Document complex logic thoroughly.
- **Official Guidelines**: Follow official Flutter documentation guidelines.
- **Include Comments**: Add comments for non-obvious code.
