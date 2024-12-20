# Flutter Startup Project

A Flutter project template with environment configuration and Supabase integration.

## Environment Setup

The app supports three different environments:

- Development
- Test
- Production

### Environment Files

Create the following .env files in the root directory:

```
.env.development
.env.test
.env.production
```

Each file should contain:

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Running the App

**Development Environment (Default)**

```bash
flutter run
```

Or explicitly:

```bash
flutter run --dart-define=ENVIRONMENT=development
```

**Test Environment**

```bash
flutter run --dart-define=ENVIRONMENT=test
```

**Production Environment**

```bash
flutter run --dart-define=ENVIRONMENT=production
```

### Building for Release

**Production Build (Android)**

```bash
flutter build apk --dart-define=ENVIRONMENT=production
```

**Production Build (iOS)**

```bash
flutter build ios --dart-define=ENVIRONMENT=production
```

## Important Notes

- The app defaults to development environment if no environment is specified
- Environment files (.env.\*) are not committed to version control
- Use .env.example as a template for creating environment files
- Make sure to add your environment files to .gitignore

## Getting Started

1. Clone the repository
2. Copy .env.example to create your environment files:
   ```bash
   cp .env.example .env.development
   cp .env.example .env.test
   cp .env.example .env.production
   ```
3. Update each .env file with your Supabase credentials
4. Run `flutter pub get`
5. Run the app using one of the commands above
