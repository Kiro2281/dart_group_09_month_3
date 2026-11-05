import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/todo_details_cubit.dart';
import '../models/todo.dart';

class TodoDetailsPage extends StatefulWidget {
  const TodoDetailsPage({super.key, required this.todo});

  final Todo todo;

  @override
  State<TodoDetailsPage> createState() => _TodoDetailsPageState();
}

class _TodoDetailsPageState extends State<TodoDetailsPage> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoDetailsCubit, TodoDetailsState>(
      listener: (context, state) {
        if (state.status == TodoDetailsStatus.saved ||
            state.status == TodoDetailsStatus.deleted) {
          Navigator.of(context).pop(true);
        } else if (state.status == TodoDetailsStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Неизвестная ошибка'),
              ),
            );
        }
      },
      builder: (context, state) {
        final isBusy =
            state.status == TodoDetailsStatus.saving ||
            state.status == TodoDetailsStatus.deleting;

        return Scaffold(
          appBar: AppBar(title: const Text('Детали задачи')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.todo.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  enabled: !isBusy,
                  decoration: const InputDecoration(
                    labelText: 'Название задачи',
                  ),
                  onFieldSubmitted: (_) => _save(context),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isBusy ? null : () => _save(context),
                    child: const Text('Сохранить'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : context.read<TodoDetailsCubit>().deleteTodo,
                    child: const Text('Удалить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save(BuildContext context) {
    context.read<TodoDetailsCubit>().updateTodo(_titleController.text);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
