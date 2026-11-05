import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_page.dart';
import '../cubit/todo_details_cubit.dart';
import '../models/todo.dart';
import '../services/todo_repository.dart';
import 'settings_page.dart';
import 'todo_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TodoRepository _todoRepository = TodoRepository();
  List<Todo> _tasks = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final todos = await _todoRepository.getTodos();
      if (!mounted) return;
      setState(() {
        _tasks = todos;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  void _openSettingsPage() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (context) => const SettingsPage()),
    );
  }

  Future<void> _openAddPage() async {
    final task = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (context) => const AddPage()),
    );

    if (!mounted || task == null) return;

    try {
      await _todoRepository.addTodo(task);
      await _loadTodos();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось добавить задачу: $error')),
      );
    }
  }

  Future<void> _openDetailsPage(Todo todo) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => BlocProvider(
          create: (context) => TodoDetailsCubit(_todoRepository, todo),
          child: TodoDetailsPage(todo: todo),
        ),
      ),
    );
    if (changed == true && mounted) await _loadTodos();
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Не удалось загрузить задачи: $_loadError'),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _loadTodos,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      )
                    : _tasks.isEmpty
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
