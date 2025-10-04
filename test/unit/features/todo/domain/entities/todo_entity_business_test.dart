import 'package:flutter_test/flutter_test.dart';
import 'package:demo_todo/features/todo/domain/entities/todo_entity.dart';

void main() {
  group('TodoEntity', () {
    group('constructor', () {
      test('should create TodoEntity with required fields', () {
        // Arrange & Act
        const todo = TodoEntity(id: 1, title: 'Test Todo');

        // Assert
        expect(todo.id, 1);
        expect(todo.title, 'Test Todo');
        expect(todo.completed, false); // Default value
      });

      test('should create TodoEntity with all fields', () {
        // Arrange & Act
        const todo = TodoEntity(id: 1, title: 'Test Todo', completed: true);

        // Assert
        expect(todo.id, 1);
        expect(todo.title, 'Test Todo');
        expect(todo.completed, true);
      });
    });

    group('toggleCompleted', () {
      test('should toggle completed from false to true', () {
        // Arrange
        const todo = TodoEntity(id: 1, title: 'Test Todo', completed: false);

        // Act
        final toggledTodo = todo.toggleCompleted();

        // Assert
        expect(toggledTodo.id, 1);
        expect(toggledTodo.title, 'Test Todo');
        expect(toggledTodo.completed, true);
      });

      test('should toggle completed from true to false', () {
        // Arrange
        const todo = TodoEntity(id: 1, title: 'Test Todo', completed: true);

        // Act
        final toggledTodo = todo.toggleCompleted();

        // Assert
        expect(toggledTodo.id, 1);
        expect(toggledTodo.title, 'Test Todo');
        expect(toggledTodo.completed, false);
      });

      test('should not modify original todo when toggling', () {
        // Arrange
        const originalTodo = TodoEntity(
          id: 1,
          title: 'Test Todo',
          completed: false,
        );

        // Act
        final toggledTodo = originalTodo.toggleCompleted();

        // Assert
        expect(originalTodo.completed, false);
        expect(toggledTodo.completed, true);
        expect(originalTodo != toggledTodo, true);
      });
    });

    group('copyWith', () {
      test('should create new todo with updated id', () {
        // Arrange
        const original = TodoEntity(
          id: 1,
          title: 'Test Todo',
          completed: false,
        );

        // Act
        final updated = original.copyWith(id: 2);

        // Assert
        expect(updated.id, 2);
        expect(updated.title, 'Test Todo');
        expect(updated.completed, false);
      });

      test('should create new todo with updated title', () {
        // Arrange
        const original = TodoEntity(
          id: 1,
          title: 'Test Todo',
          completed: false,
        );

        // Act
        final updated = original.copyWith(title: 'Updated Todo');

        // Assert
        expect(updated.id, 1);
        expect(updated.title, 'Updated Todo');
        expect(updated.completed, false);
      });

      test('should create new todo with updated completed status', () {
        // Arrange
        const original = TodoEntity(
          id: 1,
          title: 'Test Todo',
          completed: false,
        );

        // Act
        final updated = original.copyWith(completed: true);

        // Assert
        expect(updated.id, 1);
        expect(updated.title, 'Test Todo');
        expect(updated.completed, true);
      });

      test('should create identical todo when no parameters provided', () {
        // Arrange
        const original = TodoEntity(
          id: 1,
          title: 'Test Todo',
          completed: false,
        );

        // Act
        final updated = original.copyWith();

        // Assert
        expect(updated.id, original.id);
        expect(updated.title, original.title);
        expect(updated.completed, original.completed);
        expect(updated == original, true);
      });
    });

    group('validation', () {
      test('isEmpty should return true for empty title', () {
        // Arrange
        const todo = TodoEntity(id: 1, title: '');

        // Act & Assert
        expect(todo.isEmpty, true);
      });

      test('isEmpty should return true for whitespace-only title', () {
        // Arrange
        const todo = TodoEntity(id: 1, title: '   ');

        // Act & Assert
        expect(todo.isEmpty, true);
      });

      test('isEmpty should return false for valid title', () {
        // Arrange
        const todo = TodoEntity(id: 1, title: 'Valid Todo');

        // Act & Assert
        expect(todo.isEmpty, false);
      });

      test('isValid should return false for empty title', () {
        // Arrange
        const todo = TodoEntity(id: 1, title: '');

        // Act & Assert
        expect(todo.isValid, false);
      });

      test('isValid should return false for whitespace-only title', () {
        // Arrange
        const todo = TodoEntity(id: 1, title: '   ');

        // Act & Assert
        expect(todo.isValid, false);
      });

      test('isValid should return true for valid title', () {
        // Arrange
        const todo = TodoEntity(id: 1, title: 'Valid Todo');

        // Act & Assert
        expect(todo.isValid, true);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const todo1 = TodoEntity(id: 1, title: 'Test Todo', completed: false);
        const todo2 = TodoEntity(id: 1, title: 'Test Todo', completed: false);

        // Act & Assert
        expect(todo1 == todo2, true);
        expect(todo1.hashCode == todo2.hashCode, true);
      });

      test('should not be equal when id differs', () {
        // Arrange
        const todo1 = TodoEntity(id: 1, title: 'Test Todo', completed: false);
        const todo2 = TodoEntity(id: 2, title: 'Test Todo', completed: false);

        // Act & Assert
        expect(todo1 == todo2, false);
      });

      test('should not be equal when title differs', () {
        // Arrange
        const todo1 = TodoEntity(id: 1, title: 'Test Todo', completed: false);
        const todo2 = TodoEntity(
          id: 1,
          title: 'Different Todo',
          completed: false,
        );

        // Act & Assert
        expect(todo1 == todo2, false);
      });

      test('should not be equal when completed status differs', () {
        // Arrange
        const todo1 = TodoEntity(id: 1, title: 'Test Todo', completed: false);
        const todo2 = TodoEntity(id: 1, title: 'Test Todo', completed: true);

        // Act & Assert
        expect(todo1 == todo2, false);
      });
    });

    group('toString', () {
      test('should return string representation', () {
        // Arrange
        const todo = TodoEntity(id: 1, title: 'Test Todo', completed: false);

        // Act
        final result = todo.toString();

        // Assert
        expect(result, 'TodoEntity(id: 1, title: Test Todo, completed: false)');
      });
    });

    group('business logic', () {
      test('should handle edge cases for empty strings', () {
        // Arrange
        const emptyTodo = TodoEntity(id: 1, title: '');
        const whitespaceTodo = TodoEntity(id: 2, title: '   ');
        const validTodo = TodoEntity(id: 3, title: 'Valid');

        // Act & Assert
        expect(emptyTodo.isValid, false);
        expect(whitespaceTodo.isValid, false);
        expect(validTodo.isValid, true);

        expect(emptyTodo.isEmpty, true);
        expect(whitespaceTodo.isEmpty, true);
        expect(validTodo.isEmpty, false);
      });

      test('should handle multiple toggle operations correctly', () {
        // Arrange
        const originalTodo = TodoEntity(id: 1, title: 'Test', completed: false);

        // Act
        final firstToggle = originalTodo.toggleCompleted();
        final secondToggle = firstToggle.toggleCompleted();

        // Assert
        expect(originalTodo.completed, false);
        expect(firstToggle.completed, true);
        expect(secondToggle.completed, false);

        // Should be back to original state
        expect(secondToggle.completed, originalTodo.completed);
      });

      test('should preserve immutability across operations', () {
        // Arrange
        const originalTodo = TodoEntity(
          id: 1,
          title: 'Original',
          completed: false,
        );

        // Act
        final copiedTodo = originalTodo.copyWith(title: 'Modified');
        final toggledTodo = originalTodo.toggleCompleted();

        // Assert
        expect(originalTodo.title, 'Original');
        expect(originalTodo.completed, false);

        expect(copiedTodo.title, 'Modified');
        expect(copiedTodo.completed, false);

        expect(toggledTodo.title, 'Original');
        expect(toggledTodo.completed, true);
      });
    });
  });
}
