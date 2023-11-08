import "package:flutter/material.dart";
import "package:tasks/back_end/models/todo_list.dart";

class TodoRepository extends InheritedWidget {
  const TodoRepository({
    required this.todoLists,
    required this.addTodoList,
    required this.setActiveTodoList,
    required this.removeTodoList,
    required super.child,
    super.key,
  });

  final List<TodoList> todoLists;
  final void Function(TodoList todoList) addTodoList;
  final void Function(int index) setActiveTodoList;
  final void Function(int id) removeTodoList;

  static TodoRepository of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TodoRepository>()!;

  @override
  bool updateShouldNotify(covariant TodoRepository oldWidget) => todoLists.length != oldWidget.todoLists.length;
}
