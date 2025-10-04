# Integration Tests on Emulator Guide

## Prerequisites
1. **Android Studio/Xcode installed** with emulator setup
2. **Flutter SDK** properly configured
3. **integration_test dependency** added to pubspec.yaml ✅

## Running Integration Tests

### 1. Start an Emulator
```bash
# List available emulators
flutter emulators

# Start a specific emulator (replace with your emulator name)
flutter emulators --launch <emulator_name>

# Or start Android Studio and launch emulator from AVD Manager
```

### 2. Verify Device Connection
```bash
# Check connected devices
flutter devices

# Should show your emulator in the list
```

### 3. Run Integration Tests
```bash
# Option 1: Run integration test on connected device/emulator
flutter test integration_test/app_test.dart

# Option 2: Run with specific device (if multiple devices)
flutter test integration_test/app_test.dart -d <device_id>

# Option 3: Use the convenience script
./run_integration_tests.sh
```

## Test Coverage

### Our integration tests cover:

1. **Basic CRUD Operations**
   - Add todos
   - Complete/uncomplete todos (checkbox functionality)
   - Delete todos
   - Empty state validation

2. **Scrolling with Large Lists**
   - Adds 25 todos to test scrolling performance
   - Tests ListView scrolling behavior
   - Validates checkbox interaction in scrolled views

3. **Input Validation**
   - Empty input handling
   - Whitespace-only input
   - Title trimming validation

4. **UI Interaction**
   - Checkbox toggle functionality
   - Multiple rapid operations
   - State persistence during operations

5. **Performance Testing**
   - Rapid todo additions (10 items quickly)
   - Multiple checkbox operations
   - Delete operations under load

## Test Scenarios

### Scenario 1: Large List Scrolling (100+ todos)
```dart
// The test adds 25 todos and tests scrolling
// For 100+ todos, you can modify the loop:
for (int i = 1; i <= 100; i++) {
  await tester.enterText(find.byType(TextField), 'Todo item $i');
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle(const Duration(milliseconds: 50));
}
```

### Scenario 2: Checkbox Interaction at Scale
```dart
// Tests rapid checkbox toggling
final checkboxes = find.byType(Checkbox);
for (int i = 0; i < checkboxes.evaluate().length; i++) {
  await tester.tap(checkboxes.at(i));
  await tester.pump();
}
```

## Expected Results

✅ **Successful Test Run should show:**
- All todos added successfully
- Scrolling works smoothly
- Checkboxes respond to taps
- State changes are reflected in UI
- No performance degradation with large lists
- Input validation works correctly

❌ **Common Issues:**
- Emulator not connected: Check `flutter devices`
- Tests timeout: Reduce operations or increase timeout
- UI not found: Check widget tree structure
- Performance lag: Use `pump()` instead of `pumpAndSettle()` for rapid operations

## Debugging Tips

1. **Add debug prints:**
```dart
debugPrint('Current todo count: ${find.byType(Checkbox).evaluate().length}');
```

2. **Use screenshots:**
```dart
await binding.takeScreenshot('test_state');
```

3. **Increase timeouts for slow operations:**
```dart
await tester.pumpAndSettle(const Duration(seconds: 5));
```

## Performance Considerations

- **Large Lists**: ListView.builder handles large lists efficiently
- **Rapid Operations**: Use `pump()` for faster test execution
- **Memory**: Emulator should have adequate RAM for smooth testing
- **Real Device**: Test on real device for accurate performance metrics

## Running on Real Device

1. Enable Developer Options and USB Debugging
2. Connect device via USB
3. Run `flutter devices` to verify connection
4. Execute same test commands

The integration tests will provide comprehensive validation of your Todo app's functionality, performance, and user experience on actual devices/emulators!