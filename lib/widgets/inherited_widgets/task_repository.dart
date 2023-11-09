import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";

class TaskRepository extends InheritedWidget {
  const TaskRepository({
    required this.todoLists,
    required this.addTodoList,
    required int Function() getActiveTodoListIndex,
    required void Function(int) setActiveTodoListIndex,
    required this.removeTodoList,
    required super.child,
    super.key,
  })  : _getActiveTodoListIndex = getActiveTodoListIndex,
        _setActiveTodoListIndex = setActiveTodoListIndex;

  final List<TaskList> todoLists;
  final void Function(TaskList todoList) addTodoList;
  final int Function() _getActiveTodoListIndex;
  final void Function(int index) _setActiveTodoListIndex;
  final void Function(int id) removeTodoList;

  int get activeTodoListIndex => _getActiveTodoListIndex();
  void set activeTodoListIndex(int index) => _setActiveTodoListIndex(index);

  static TaskRepository of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TaskRepository>()!;

  @override
  bool updateShouldNotify(covariant TaskRepository oldWidget) => todoLists.length != oldWidget.todoLists.length;
}
