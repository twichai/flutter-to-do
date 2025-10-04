# Test Structure Documentation

## Current Test Organization

```
test/
├── unit/                                    # Unit Tests
│   └── features/
│       └── todo/
│           ├── domain/
│           │   ├── entities/
│           │   │   ├── todo_entity_test.dart
│           │   │   └── todo_entity_business_test.dart
│           │   └── usecases/
│           │       └── todo_usecases_integration_test.dart
│           └── data/
│               └── repositories/
│                   └── (repository tests if needed)
├── integration/                             # Integration Tests
│   └── features/
│       └── todo/
│           ├── add_todo_usecase_integration_test.dart
│           └── todo_app_integration_test.dart
└── widget_test.dart                         # Default Flutter widget test
```

## Test Types and Purposes

### 1. Unit Tests (`test/unit/`)
- **Purpose**: Test individual components in isolation
- **Scope**: Domain entities, business logic, validation
- **Examples**:
  - `todo_entity_test.dart`: TodoEntity methods, validation, immutability
  - `todo_entity_business_test.dart`: Business logic, edge cases

### 2. Integration Tests (`test/integration/`)
- **Purpose**: Test interactions between components
- **Scope**: Use cases with repositories, data flow, UI integration
- **Examples**:
  - `add_todo_usecase_integration_test.dart`: Use case + repository interaction
  - `todo_app_integration_test.dart`: Full UI integration with large datasets

### 3. Widget Tests (Removed)
- Previously in `test/widget/`, now removed per user request
- Focus on unit and integration testing only

## Running Tests

### Run All Tests
```bash
./run_tests.sh
```

### Run Specific Test Types
```bash
# Unit tests only
flutter test test/unit/

# Integration tests only
flutter test test/integration/

# Integration tests with emulator
./run_integration_tests.sh

# Specific test file
flutter test test/unit/features/todo/domain/entities/todo_entity_test.dart
```

### Run with Coverage
```bash
flutter test test/unit/ test/integration/ --coverage
```

## Test Dependencies

### Unit Tests
- `flutter_test`
- Core app dependencies
- Mock implementations (simple, no external frameworks)

### Integration Tests
- `flutter_test`
- `integration_test` (for UI integration)
- `flutter_riverpod` (for dependency injection)
- Real/mock repository implementations

## Best Practices

### Test Naming
- **Unit Tests**: `{component}_test.dart`
- **Integration Tests**: `{feature}_integration_test.dart`
- **Business Logic Tests**: `{component}_business_test.dart`

### Test Organization
- Group related tests by feature
- Separate unit tests from integration tests
- Use descriptive test names and groups

### Dependency Injection
```dart
// Good: Use DI for integration tests
ProviderScope(
  overrides: [
    todoRepositoryProvider.overrideWithValue(mockRepo),
  ],
  child: TodoListScreen(),
)

// Avoid: Manual UI interactions for data setup
for (int i = 0; i < 100; i++) {
  await tester.enterText(...);
  await tester.tap(...);
}
```

### Performance Considerations
- Use mock repositories with pre-populated data
- Test large datasets (100+, 500+ items) for performance
- Separate UI interaction tests from data volume tests

## Test Coverage Goals

- **Unit Tests**: 100% coverage of business logic
- **Integration Tests**: Key user workflows and edge cases
- **Performance Tests**: Large dataset handling
- **Error Handling**: Validation, failure scenarios

## Continuous Integration

Tests are structured to run efficiently in CI/CD:
- Fast unit tests (< 30 seconds)
- Integration tests with dependency injection (< 2 minutes)
- No slow manual UI interactions for data setup
- Comprehensive coverage without redundancy