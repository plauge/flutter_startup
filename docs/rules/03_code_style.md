# Code Style Guidelines

## Dart/Flutter Rules

- Use const constructors for immutable widgets
- Use Freezed for immutable state classes and unions
- Use arrow syntax for simple functions
- Use trailing commas for better formatting
- Prefer expression bodies for one-line getters/setters
- Implement proper widget cleanup in dispose()

## Error Handling

- Use AsyncValue for proper error handling
- Display errors in SelectableText.rich with red color
- Handle empty states within screens
- Implement proper Supabase error handling

## Riverpod Guidelines

- Use @riverpod annotation for provider generation
- Prefer AsyncNotifierProvider over StateProvider
- Use ref.watch() for reactive state
- Use ref.read() for one-time operations
- Implement proper async cancellation

## Performance

- Use const widgets where possible
- Optimize list views
- Use cached_network_image
- Follow Flutter best practices

## Documentation

- Document complex logic thoroughly
- Follow official Flutter guidelines
- Include comments for non-obvious code
