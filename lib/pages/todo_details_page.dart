import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoDetailsPage extends StatelessWidget {
  const TodoDetailsPage({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали задачи')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todo.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: todo.title,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Название задачи'),
            ),
          ],
        ),
      ),
    );
  }
}
