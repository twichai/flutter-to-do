import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/todo_viewmodel.dart';

class AddTodoWidget extends ConsumerStatefulWidget {
  const AddTodoWidget({super.key});

  @override
  ConsumerState<AddTodoWidget> createState() => _AddTodoWidgetState();
}

class _AddTodoWidgetState extends ConsumerState<AddTodoWidget> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add a new todo...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a todo';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _addTodo(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addTodo,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _addTodo() {
    if (_formKey.currentState!.validate()) {
      final title = _controller.text.trim();
      ref.read(todoNotifierProvider.notifier).addTodo(title);
      _controller.clear();
    }
  }
}
