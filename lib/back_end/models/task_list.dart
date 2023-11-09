import "dart:math" as math;

import "package:flutter/material.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/shared/extension_types/immutable_list.dart";

typedef Indexed<T> = (int index, T value);

class TaskList extends ChangeNotifier {
  TaskList({required this.id, required String name, required List<Task> tasks})
      : _name = name,
        _tasks = tasks,
        assert(tasks.map((Task v) => v.id).toSet().length == tasks.length, "task ids must be unique") {
    taskId = tasks.isEmpty ? 0 : tasks.map((Task task) => task.id).reduce(math.max) + 1;
  }

  TaskList.empty({required int id, required String name}) : this(id: id, name: name, tasks: <Task>[]);
  TaskList.dummy({int? id, int taskCount = 10, String name = "Dummy"})
      : this(
          id: id ?? 0,
          name: name,
          tasks: <Task>[
            for (int i = 0; i < taskCount; ++i)
              Task(listId: id ?? 0, id: i, title: "Task #$i", isCompleted: false, deadline: null),
          ],
        );

  /// The id of this list.
  final int id;

  /// The id to use for the next item
  late int taskId;

  String _name;
  String get name => _name;
  set name(String value) {
    if (_name != value) {
      _name = value;
      notifyListeners();
    }
  }

  List<Task> _tasks;
  ImmutableList<Task> get tasks => ImmutableList<Task>(_tasks);

  (int index, Task task)? search({required int id}) =>
      _tasks.indexed.where((Indexed<Task> task) => task.$2.id == id).singleOrNull;

  void addTask({required String title, required bool isCompleted, required DateTime? deadline}) {
    _tasks.add(Task(title: title, listId: this.id, id: taskId, isCompleted: isCompleted, deadline: deadline));
    taskId += 1;

    notifyListeners();
  }

  void removeTask({required int id}) {
    _tasks.removeWhere((Task task) => task.id == id);

    notifyListeners();
  }

  void reorganizeTask({required int from, required int to}) {
    if (from == to) {
      return;
    }

    /// If we're moving an item down, we need to adjust the index
    /// to account for the fact that the item will be removed
    if (to > from) {
      --to;
    }

    Task task = tasks[from];
    _tasks.removeAt(from);
    _tasks.insert(to, task);
    notifyListeners();
  }

  void toggleTaskCompletion({required int id}) {
    if (this.search(id: id) case (_, Task task)) {
      task.toggleIsCompleted();
      notifyListeners();
    }
  }

  void setTaskCompletion({required int id, required bool value}) {
    if (this.search(id: id) case (_, Task task)) {
      if (task.isCompleted == value) {
        return;
      }

      task.isCompleted = value;
      notifyListeners();
    }
  }
}
