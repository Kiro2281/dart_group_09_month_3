import 'package:flutter/material.dart';
import 'package:flutter_application_10/Utilis/app_SnackBar.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class AddTaskResult {
  const AddTaskResult({required this.title, this.reminderAt});

  final String title;
  final DateTime? reminderAt;
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSaving = false;
  DateTime? _reminderAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая задача'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Название задачи',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textEditingController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Введите название задачи',
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => _onSaveTap(),
              ),
              const SizedBox(height: 20),
              Text(
                'Напоминание',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _ReminderTile(
                reminderAt: _reminderAt,
                onTap: _isSaving ? null : _selectReminder,
                onClear: _isSaving || _reminderAt == null
                    ? null
                    : () => setState(() => _reminderAt = null),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton(
          onPressed: _isSaving ? null : _onSaveTap,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Сохранить задачу'),
        ),
      ),
    );
  }

  Future<void> _selectReminder() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 10),
    );
    if (pickedDate != null && mounted) {
      setState(() {
        _reminderAt = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _reminderAt?.hour ?? 9,
          _reminderAt?.minute ?? 0,
        );
      });
    }
  }

  Future<void> _onSaveTap() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final title = saveTask();
      await showAppSnackBar(
        text: "Задача сохранена",
        backgroundColor: Colors.green,
        icon: Icons.check_box,
      );
      if (!mounted) return;
      Navigator.of(context)
          .pop(AddTaskResult(title: title, reminderAt: _reminderAt));
    } catch (error) {
      await showAppSnackBar(
        text: error.toString(),
        backgroundColor: Colors.red,
        icon: Icons.close_rounded,
      );
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String saveTask() {
    final title = _textEditingController.text.trim();

    if (title.isEmpty) {
      throw TaskTextException(message: "Текст не может быть пустым");
    } else if (title.length < 3) {
      throw TaskTextException(
        message: "Текст должен содержать хотя бы 3 символа",
      );
    }

    return title;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminderAt,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? reminderAt;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(dateText, style: theme.textTheme.bodyMedium),
              ),
              if (onClear != null)
                IconButton(
                  onPressed: onClear,
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
}

class TaskTextException implements Exception {
  String message;

  TaskTextException({required this.message});

  @override
  String toString() {
    return message;
  }
}
