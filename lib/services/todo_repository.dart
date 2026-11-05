import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoRepository {
  static const _storageKey = 'todos';

  Future<List<Todo>> getTodos() async {
    final preferences = await SharedPreferences.getInstance();
    final storedTodos = preferences.getString(_storageKey);
    if (storedTodos == null) return [];

    final decodedTodos = jsonDecode(storedTodos) as List<dynamic>;
    final todos = <Todo>[];
    for (final item in decodedTodos) {
      final todoData = Map<String, dynamic>.from(item as Map);
      todos.add(
        Todo(id: todoData['id'] as int, title: todoData['title'] as String),
      );
    }
    return todos;
  }

  Future<void> addTodo(String title) async {
    final todos = await getTodos();
    var largestId = 0;
    for (final todo in todos) {
      if (todo.id > largestId) {
        largestId = todo.id;
      }
    }
    final nextId = largestId + 1;

    todos.insert(0, Todo(id: nextId, title: title));
    await _saveTodos(todos);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final todos = await getTodos();
    final todoIndex = todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (todoIndex == -1) {
      throw StateError('Задача с ID ${updatedTodo.id} не найдена.');
    }

    todos[todoIndex] = updatedTodo;
    await _saveTodos(todos);
  }

  Future<void> deleteTodo(int id) async {
    final todos = await getTodos();
    final todoIndex = todos.indexWhere((todo) => todo.id == id);
    if (todoIndex == -1) {
      throw StateError('Задача с ID $id не найдена.');
    }

    todos.removeAt(todoIndex);
    await _saveTodos(todos);
  }

  Future<void> _saveTodos(List<Todo> todos) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(
        todos.map((todo) => {'id': todo.id, 'title': todo.title}).toList(),
      ),
    );
    if (!saved) {
      throw StateError('Не удалось сохранить список задач.');
    }
  }
}
