import "dart:math" as math;

import "package:flutter/material.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/shared/extension_types/immutable_list.dart";

typedef Indexed<T> = (int index, T value);

class TaskRepository extends ChangeNotifier {
  int taskListId = 0;

  final List<TaskList> _taskLists = <TaskList>[];
  ImmutableList<TaskList> get taskLists => ImmutableList<TaskList>(_taskLists);

  ImmutableList<Task> get taskListsDueToday {
    DateTime now = DateTime.now();
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

    return ImmutableList<Task>(<Task>[
      for (TaskList list in _taskLists) ...<Task>[
        for (Task task in list.tasks)
          if (task case Task(:DateTime deadline)
              when deadline.isBefore(tomorrow) && (deadline == now || deadline.isAfter(now)))
            task,
      ],
    ]);
  }

  TaskList get activeTaskList => _taskLists[_activeTaskListIndex];

  int _activeTaskListIndex = 0;
  int get activeTaskListIndex => _activeTaskListIndex;
  set activeTaskListIndex(int value) {
    if (_activeTaskListIndex != value) {
      _taskLists
        ..[_activeTaskListIndex].removeListener(_listen)
        ..[value].addListener(_listen);

      _activeTaskListIndex = value;
      notifyListeners();
    }
  }

  void _listen() {
    notifyListeners();
  }

  void addTaskList(TaskList taskList) {
    _taskLists.add(taskList);
    taskListId = _taskLists.map((TaskList list) => list.id).reduce(math.max) + 1;

    notifyListeners();
  }

  void createTaskList({required String name}) {
    _taskLists.add(TaskList(id: taskListId, name: name, tasks: <Task>[]));
    taskListId += 1;

    notifyListeners();
  }

  void removeTaskList({required int id}) {
    _taskLists.removeWhere((TaskList taskList) => taskList.id == id);

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

    TaskList activeTask = _taskLists[activeTaskListIndex];
    TaskList task = _taskLists[from];
    _taskLists.removeAt(from);
    _taskLists.insert(to, task);

    /// We have to shift the index as well.
    activeTaskListIndex = _taskLists.indexOf(activeTask);

    notifyListeners();
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
    return taskRepository != oldWidget.taskRepository;
  }
}
