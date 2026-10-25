import 'package:flutter/material.dart';

import 'add_page.dart';
import '../models/todo.dart';
import 'settings_page.dart';
import 'todo_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Todo> _tasks = [];

  void _openSettingsPage() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (context) => const SettingsPage()),
    );
  }

  void _openAddPage() async {
    final task = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (context) => const AddPage()),
    );

    if (!mounted || task == null) return;

    setState(() {
      _tasks.insert(0, Todo(title: task));
    });
  }

  void _openDetailsPage(Todo todo) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => TodoDetailsPage(todo: todo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мои задачи',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _openSettingsPage,
            tooltip: 'Настройки',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'План на сегодня',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _tasks.isEmpty
                    ? 'Добавьте первую задачу и начните свой план.'
                    : 'У вас ${_tasks.length} ${_taskCountLabel(_tasks.length)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _tasks.isEmpty
                    ? _EmptyTasksState(onAddTask: _openAddPage)
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _tasks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => _TaskCard(
                          todo: _tasks[index],
                          number: index + 1,
                          onTap: () => _openDetailsPage(_tasks[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPage,
        icon: const Icon(Icons.add),
        label: const Text('Новая задача'),
      ),
    );
  }

  String _taskCountLabel(int count) {
    final lastDigit = count % 10;
    final lastTwoDigits = count % 100;

    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) return 'задач';
    if (lastDigit == 1) return 'задача';
    if (lastDigit >= 2 && lastDigit <= 4) return 'задачи';
    return 'задач';
  }
}

class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState({required this.onAddTask});

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checklist_rounded,
                size: 42,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Пока здесь пусто',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте задачу, чтобы ничего не забыть.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Добавить задачу'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.todo,
    required this.number,
    required this.onTap,
  });

  final Todo todo;
  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            todo.title,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
