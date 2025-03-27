# Architecture Guidelines

## Key Principles

- Write concise, technical Dart code with accurate examples
- Use functional and declarative programming patterns where appropriate
- Prefer composition over inheritance
- Use descriptive variable names with helper verbs
- Structure files: exported widget, subwidgets, helpers, static content, types

## Architecture

- Layered pattern with models, services, providers, and screens
- Models: Data objects (e.g., User)
- Services: API communication (e.g., SupabaseService)
- Providers: State management with Riverpod
- Screens: UI components following authenticated/unauthenticated pattern
- Widgets: Reusable UI components

## Folder Structure

- lib/core/auth: Authentication state management and logic
- lib/core/widgets/screens: Core screens for auth flows
- lib/models: Data models (with generated files in lib/models/generated/)
- lib/providers: State providers
- lib/screens/authenticated: Screens requiring user login
- lib/screens/unauthenticated: Screens accessible without login
- lib/screens/unauthenticated/auth: Authentication related screens
- lib/screens/common: Screens accessible in any state
- lib/services: Service classes
- lib/theme: Theme files
- lib/widgets/jwt: JWT widgets
- lib: Main app entry points
