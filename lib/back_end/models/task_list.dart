import "dart:math" as math;

import "package:flutter/material.dart";
import "package:tasks/back_end/models/todo.dart";
import "package:tasks/shared/extension_types/immutable_list.dart";

typedef Indexed<T> = (int index, T value);

class TaskList extends ChangeNotifier {
  TaskList({required this.id, required String name, required List<Todo> todos})
      : _name = name,
        _todos = todos,
        assert(todos.map((Todo v) => v.id).toSet().length == todos.length, "Todo ids must be unique") {
    todoId = todos.isEmpty ? 0 : todos.map((Todo todo) => todo.id).reduce(math.max) + 1;
  }

  TaskList.empty({required int id, required String name}) : this(id: id, name: name, todos: <Todo>[]);
  TaskList.dummy({int? id, int taskCount = 10, String name = "Dummy"})
      : this(
          id: id ?? 0,
          name: name,
          todos: <Todo>[
            for (int i = 0; i < taskCount; ++i) Todo(listId: id ?? 0, id: i, title: "Task #$i", isCompleted: false),
          ],
        );

  /// The id of this list.
  final int id;

  /// The id to use for the next item
  late int todoId;

  String _name;
  String get name => _name;
  set name(String value) {
    if (_name != value) {
      _name = value;
      notifyListeners();
    }
  }

  List<Todo> _todos;
  ImmutableList<Todo> get todos => ImmutableList<Todo>(_todos);

  (int index, Todo todo)? search({required int id}) =>
      _todos.indexed.where((Indexed<Todo> todo) => todo.$2.id == id).singleOrNull;

  void addTodo({required String title, required bool isCompleted}) {
    _todos.add(Todo(title: title, listId: this.id, id: todoId, isCompleted: isCompleted));
    todoId += 1;

    notifyListeners();
  }

  void removeTodo({required int id}) {
    _todos.removeWhere((Todo todo) => todo.id == id);

    notifyListeners();
  }

  void reorganizeTodo({required int from, required int to}) {
    if (from == to) {
      return;
    }

    /// If we're moving an item down, we need to adjust the index
    /// to account for the fact that the item will be removed
    if (to > from) {
      --to;
    }

    Todo todo = todos[from];
    _todos.removeAt(from);
    _todos.insert(to, todo);
    notifyListeners();
  }

  void toggleTodoCompletion({required int id}) {
    if (this.search(id: id) case (_, Todo todo)) {
      todo.toggleIsCompleted();
      notifyListeners();
    }
  }

  void setTodoCompletion({required int id, required bool value}) {
    if (this.search(id: id) case (_, Todo todo)) {
      if (todo.isCompleted == value) {
        return;
      }

      todo.isCompleted = value;
      notifyListeners();
    }
  }
}
