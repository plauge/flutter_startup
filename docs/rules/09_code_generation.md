# Code Generation Guidelines

## Code Generation Rules

- All generated files must be placed in a 'generated' subfolder within their respective directories
- Generated file structure:
  - lib/models/generated/ - For model-related generated files
  - lib/providers/generated/ - For provider-related generated files
  - lib/services/generated/ - For service-related generated files
- Use build_runner
- Generate Freezed models
- Generate Riverpod providers
- Generate JSON serialization

## Code Generation Commands

### To generate files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### For continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```
