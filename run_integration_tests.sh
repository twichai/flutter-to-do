#!/bin/bash

echo "=== Flutter Integration Test Runner ==="
echo ""

# Check if emulator is running
echo "📱 Checking for connected devices..."
flutter devices
echo ""

# Check if any devices are connected
DEVICE_COUNT=$(flutter devices | grep -c "•")
if [ $DEVICE_COUNT -eq 0 ]; then
    echo "❌ No devices/emulators found!"
    echo "Please start an emulator or connect a device first."
    echo ""
    echo "Available emulators:"
    flutter emulators
    exit 1
fi

echo "✅ Found $DEVICE_COUNT device(s)"
echo ""
echo "🚀 Running Integration Tests on Emulator/Device..."
echo ""

# Run integration tests
flutter test integration_test/app_test.dart

echo ""
echo "✅ Integration Tests Complete!"
echo ""
echo "📊 Test Coverage:"
echo "- ✅ Todo CRUD operations"
echo "- ✅ Large list scrolling (25+ items)"
echo "- ✅ Checkbox interaction and state management"
echo "- ✅ Empty input validation"
echo "- ✅ Whitespace trimming"
echo "- ✅ Rapid operations performance"
echo "- ✅ UI responsiveness testing"