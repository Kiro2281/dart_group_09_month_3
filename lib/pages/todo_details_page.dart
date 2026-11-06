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
  DateTime? _reminderAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _reminderAt = widget.todo.reminderAt;
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
                Text(
                  'Напоминание',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _ReminderEditor(
                  reminderAt: _reminderAt,
                  enabled: !isBusy,
                  onChanged: (value) => setState(() => _reminderAt = value),
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
    context.read<TodoDetailsCubit>().updateTodo(
      _titleController.text,
      reminderAt: _reminderAt,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class _ReminderEditor extends StatelessWidget {
  const _ReminderEditor({
    required this.reminderAt,
    required this.enabled,
    required this.onChanged,
  });

  final DateTime? reminderAt;
  final bool enabled;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminder = reminderAt;
    final dateText = reminder == null
        ? 'Выберите дату'
        : '${reminder.day.toString().padLeft(2, '0')}.'
              '${reminder.month.toString().padLeft(2, '0')}.'
              '${reminder.year}';

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? () => _selectDate(context) : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(dateText)),
              if (reminder != null)
                IconButton(
                  onPressed: enabled ? () => onChanged(null) : null,
                  tooltip: 'Убрать напоминание',
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate = reminderAt?.isBefore(today) == true
        ? today
        : reminderAt ?? today;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(today.year + 10),
    );
    if (pickedDate != null) {
      onChanged(
        DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          reminderAt?.hour ?? 9,
          reminderAt?.minute ?? 0,
        ),
      );
    }
  }
}
