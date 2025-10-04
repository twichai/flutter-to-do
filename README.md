# demo_todo

A Flutter project created to experiment with Clean Architecture and MVVM patterns.  
This repository demonstrates best practices for scalable Flutter apps, including:

- **Layered architecture**: Separation of data, domain, and presentation layers
- **MVVM pattern**: Clear separation of UI and business logic
- **Comprehensive testing**: Includes unit tests, widget tests, and integration tests

## Getting Started

1. **Install dependencies**:
    ```bash
    flutter pub get
    flutter pub run build_runner build
    ```

2. **Run tests**:
    ```bash
    flutter test --coverage
    flutter test test/unit/
    flutter test test/widget/
    flutter test integration_test/
    ```

3. **Run the app**:
    ```bash
    flutter run
    ```

## Resources

- [Clean Architecture in Flutter](https://medium.com/flutter-community/flutter-clean-architecture-tutorial-8c5e8e1b8a7e)
- [MVVM in Flutter](https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)

For more details on project structure and contribution guidelines, see [AGENTS.md](./AGENTS.md).
