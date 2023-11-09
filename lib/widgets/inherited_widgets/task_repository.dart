import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";

class TaskRepository extends InheritedWidget {
  const TaskRepository({
    required this.taskLists,
    required this.addTaskList,
    required int activeTaskListIndex,
    required void Function(int) setActiveTaskListIndex,
    required this.removeTaskList,
    required super.child,
    super.key,
  })  : _activeTaskListIndex = activeTaskListIndex,
        _setActiveTaskListIndex = setActiveTaskListIndex;

  static TaskRepository of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TaskRepository>()!;

  final int _activeTaskListIndex;
  int get activeTaskListIndex => _activeTaskListIndex;
  void set activeTaskListIndex(int index) => _setActiveTaskListIndex(index);

  final List<TaskList> taskLists;

  final void Function(TaskList taskList) addTaskList;
  final void Function(int index) _setActiveTaskListIndex;
  final void Function(int id) removeTaskList;

  @override
  bool updateShouldNotify(covariant TaskRepository oldWidget) =>
      taskLists.length != oldWidget.taskLists.length || //
      activeTaskListIndex != oldWidget.activeTaskListIndex ||
      <bool>{
        for (int i = 0; i < taskLists.length; ++i)
          taskLists[i].tasks.length != oldWidget.taskLists[i].tasks.length ||
              taskLists[i].name != oldWidget.taskLists[i].name,
      }.any((bool b) => b) ||
      false;
}
