import "package:flutter/material.dart";
import "package:tasks/back_end/models/todo_list.dart";

class TodoListInheritedWidget extends InheritedWidget {
  const TodoListInheritedWidget({
    required this.todoList,
    required super.child,
    super.key,
  });

  final TodoList todoList;

  @override
  bool updateShouldNotify(covariant TodoListInheritedWidget oldWidget) => todoList != oldWidget.todoList;
}
