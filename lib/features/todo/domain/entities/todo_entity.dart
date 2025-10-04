class TodoEntity {
  final int id;
  final String title;
  final bool completed;

  const TodoEntity({
    required this.id,
    required this.title,
    this.completed = false,
  });

  // Business logic methods can go here
  TodoEntity toggleCompleted() {
    return TodoEntity(id: id, title: title, completed: !completed);
  }

  TodoEntity copyWith({int? id, String? title, bool? completed}) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  bool get isEmpty => title.trim().isEmpty;
  bool get isValid => title.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoEntity &&
        other.id == id &&
        other.title == title &&
        other.completed == completed;
  }

  @override
  int get hashCode => Object.hash(id, title, completed);

  @override
  String toString() =>
      'TodoEntity(id: $id, title: $title, completed: $completed)';
}
