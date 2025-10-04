#!/bin/bash

echo "=== Todo App Test Suite ==="
echo ""

echo "📁 Available test files:"
find test -name "*.dart" -type f

echo ""
echo "🧪 Running Entity Business Logic Tests..."
flutter test test/unit/features/todo/domain/entities/todo_entity_business_test.dart --reporter=compact

echo ""
echo "🔗 Running Use Case Integration Tests..."
flutter test test/unit/features/todo/domain/usecases/todo_usecases_integration_test.dart --reporter=compact

echo ""
echo "📊 Running All Unit & Integration Tests with Coverage..."
flutter test test/unit/ --coverage --reporter=compact

echo ""
echo "✅ Unit & Integration Test Suite Complete!"