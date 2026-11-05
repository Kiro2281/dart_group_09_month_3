import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/todo.dart';
import '../services/todo_repository.dart';

enum TodoDetailsStatus { initial, saving, saved, deleting, deleted, failure }

class TodoDetailsState {
  const TodoDetailsState({
    this.status = TodoDetailsStatus.initial,
    this.errorMessage,
  });

  final TodoDetailsStatus status;
  final String? errorMessage;
}

class TodoDetailsCubit extends Cubit<TodoDetailsState> {
  TodoDetailsCubit(this._repository, this._todo)
    : super(const TodoDetailsState());

  final TodoRepository _repository;
  final Todo _todo;

  Future<void> updateTodo(String title) async {
    final updatedTitle = title.trim();
    if (updatedTitle.isEmpty) {
      emit(
        const TodoDetailsState(
          status: TodoDetailsStatus.failure,
          errorMessage: 'Название задачи не может быть пустым.',
        ),
      );
      return;
    }

    emit(const TodoDetailsState(status: TodoDetailsStatus.saving));
    try {
      await _repository.updateTodo(Todo(id: _todo.id, title: updatedTitle));
      emit(const TodoDetailsState(status: TodoDetailsStatus.saved));
    } catch (error) {
      emit(
        TodoDetailsState(
          status: TodoDetailsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> deleteTodo() async {
    emit(const TodoDetailsState(status: TodoDetailsStatus.deleting));
    try {
      await _repository.deleteTodo(_todo.id);
      emit(const TodoDetailsState(status: TodoDetailsStatus.deleted));
    } catch (error) {
      emit(
        TodoDetailsState(
          status: TodoDetailsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
