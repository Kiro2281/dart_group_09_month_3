class Todo {
  const Todo({
    required this.id,
    required this.title,
    this.reminderAt,
    this.isCompleted = false,
  });

  final int id;
  final String title;
  final DateTime? reminderAt;
  final bool isCompleted;

  Todo copyWith({
    String? title,
    DateTime? reminderAt,
    bool? isCompleted,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      reminderAt: reminderAt ?? this.reminderAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
