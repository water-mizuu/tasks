import "dart:math" as math;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:overlay_support/overlay_support.dart";
import "package:tasks/back_end/database/database_helper.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/shared/extension_types/immutable_list.dart";
import "package:tasks/shared/extensions/map_pairs.dart";

/// This is the middle between the database and the UI.
class TaskRepository extends ChangeNotifier {
  final List<TaskList> _taskLists = <TaskList>[];
  ImmutableList<TaskList> get taskLists => ImmutableList<TaskList>(_taskLists);

  final List<Task> _tasks = <Task>[];
  ImmutableList<Task> get tasks => ImmutableList<Task>(_tasks);

  ImmutableList<Task> get taskListsDueToday {
    DateTime now = DateTime.now();
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

    return <Task>[
      for (Task task in tasks)
        if (task //
            case Task(:DateTime deadline)
            when deadline.isBefore(tomorrow) && (deadline == now || deadline.isAfter(now)))
          task,
    ].immutable;
  }

  TaskList? get activeTaskList => (_activeTaskListIndex >= 0 && _activeTaskListIndex < _taskLists.length) //
      ? _taskLists[_activeTaskListIndex]
      : null;

  int _activeTaskListIndex = -1;
  int get activeTaskListIndex => _activeTaskListIndex;
  set activeTaskListIndex(int value) {
    if (_activeTaskListIndex != value) {
      if (activeTaskListIndex >= 0 && activeTaskListIndex < _taskLists.length) {
        _taskLists[activeTaskListIndex].removeListener(_listen);
      }
      if (value >= 0 && value < _taskLists.length) {
        _taskLists[value].addListener(_listen);
      }

      _activeTaskListIndex = value;
      notifyListeners();
    }
  }

  void _listen() {
    notifyListeners();
  }

  void registerTasks(List<Task> tasks) {
    _tasks.addAll(tasks);
  }

  void registerTaskLists(List<TaskList> taskLists) {
    _taskLists.addAll(taskLists);
  }

  /// TaskList related methods.

  void createTaskList({required String name}) {
    int taskListId = _taskLists.map((TaskList taskList) => taskList.id).fold(-1, math.max);
    TaskList taskList = TaskList(id: taskListId, name: name, listIndex: _taskLists.length);
    _taskLists.add(taskList);
    taskListId += 1;

    DatabaseHelper.addTaskList(taskList);

    notifyListeners();
  }

  void removeTaskList({required int id}) {
    if (_taskLists.where((TaskList taskList) => taskList.id == id).firstOrNull case TaskList taskList) {
      DatabaseHelper.removeTaskList(taskList);

      notifyListeners();
    }
  }

  void reorganizeTaskList({required int from, required int to}) {
    if (from == to) {
      return;
    }

    /// If we're moving an item down, we need to adjust the index
    /// to account for the fact that the item will be removed
    if (to > from) {
      --to;
    }

    List<TaskList> taskLists = this._taskLists.toList()
      ..sort((TaskList left, TaskList right) => left.listIndex - right.listIndex);

    Map<TaskList, int> newIndices = <TaskList, int>{
      taskLists[from]: to,
    };

    /// Case 0: There are duplicate indices. (Improper.)
    if (taskLists.map((TaskList v) => v.listIndex).toSet().length != taskLists.length) {
      newIndices.clear();
      for (var (int index, TaskList task) in taskLists.indexed) {
        newIndices[task] = index;
      }

      if (kDebugMode) {
        toast("There are duplicate indices. Please try to organize again.", duration: const Duration(seconds: 5));
      }
    }

    /// Case 1: We move to the right.
    else if (from < to) {
      for (int i = from + 1; i <= to; ++i) {
        newIndices[taskLists[i]] = i - 1;
      }
    }

    /// Case 2: We move to the left.
    else {
      for (int i = from - 1; i >= to; --i) {
        newIndices[taskLists[i]] = i + 1;
      }
    }

    for (var (TaskList task, int index) in newIndices.pairs) {
      task.listIndex = index;
    }
    notifyListeners();
  }

  void reorganizeTask(TaskList taskList, {required int from, required int to}) {
    if (from == to) {
      return;
    }

    /// If we're moving an item down, we need to adjust the index
    /// to account for the fact that the item will be removed
    if (to > from) {
      --to;
    }

    List<Task> tasks = tasksOf(listId: taskList.id).toList()
      ..sort((Task left, Task right) => left.listIndex - right.listIndex);

    Map<Task, int> newIndices = <Task, int>{
      tasks[from]: to,
    };

    /// Case 0: There are duplicate indices. (Improper.)
    if (tasks.map((Task v) => v.listIndex).toSet().length != tasks.length) {
      newIndices.clear();
      for (var (int index, Task task) in tasks.indexed) {
        newIndices[task] = index;
      }

      if (kDebugMode) {
        toast("There are duplicate indices. Please try to organize again.", duration: const Duration(seconds: 5));
      }
    }

    /// Case 1: We move to the right.
    else if (from < to) {
      for (int i = from + 1; i <= to; ++i) {
        newIndices[tasks[i]] = i - 1;
      }
    }

    /// Case 2: We move to the left.
    else {
      for (int i = from - 1; i >= to; --i) {
        newIndices[tasks[i]] = i + 1;
      }
    }

    for (var (Task task, int index) in newIndices.pairs) {
      task.listIndex = index;
    }

    notifyListeners();
  }

  /// Task related methods.
  void addTask({required String title, required DateTime? deadline, required bool isCompleted}) {
    assert(activeTaskList != null, "This method should not be called if there is no active task list.");

    int id = _tasks.map((Task task) => task.id).fold(-1, math.max) + 1;
    Task task = Task(
      id: id,
      title: title,
      deadline: deadline,
      isCompleted: isCompleted,
      listId: activeTaskList!.id,
      listIndex: tasksOf(listId: activeTaskList!.id).length,
    );
    _tasks.add(task);

    DatabaseHelper.addTask(task);

    notifyListeners();
  }

  void removeTask({required int id}) {
    Task? taskToRemove = _tasks.where((Task task) => task.id == id).firstOrNull;

    if (taskToRemove case Task task) {
      DatabaseHelper.removeTask(task);

      notifyListeners();
    }
  }

  Iterable<Task> tasksOf({required int listId}) sync* {
    yield* _tasks.where((Task task) => task.listId == listId);
  }

  @override
  void dispose() {
    for (TaskList taskList in _taskLists) {
      taskList.removeListener(_listen);
    }

    super.dispose();
  }

  static TaskRepository? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedTaskRepository>()?.taskRepository;
  }

  static TaskRepository of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedTaskRepository>()!.taskRepository;
  }
}

class InheritedTaskRepository extends InheritedWidget {
  const InheritedTaskRepository({required this.taskRepository, required super.child, super.key});

  final TaskRepository taskRepository;

  @override
  bool updateShouldNotify(covariant InheritedTaskRepository oldWidget) {
    return true;
  }
}
