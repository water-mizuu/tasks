import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";

class TaskRepository extends InheritedWidget {
  const TaskRepository({
    required this.taskLists,
    required this.addTaskList,
    required int Function() getActiveTaskListIndex,
    required void Function(int) setActiveTaskListIndex,
    required this.removeTaskList,
    required super.child,
    super.key,
  })  : _getActiveTaskListIndex = getActiveTaskListIndex,
        _setActiveTaskListIndex = setActiveTaskListIndex;

  final List<TaskList> taskLists;
  final void Function(TaskList taskList) addTaskList;
  final int Function() _getActiveTaskListIndex;
  final void Function(int index) _setActiveTaskListIndex;
  final void Function(int id) removeTaskList;

  int get activeTaskListIndex => _getActiveTaskListIndex();
  void set activeTaskListIndex(int index) => _setActiveTaskListIndex(index);

  static TaskRepository of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TaskRepository>()!;

  @override
  bool updateShouldNotify(covariant TaskRepository oldWidget) => taskLists.length != oldWidget.taskLists.length;
}
