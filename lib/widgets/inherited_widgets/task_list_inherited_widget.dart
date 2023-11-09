import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";

class TaskListInheritedWidget extends InheritedWidget {
  const TaskListInheritedWidget({
    required this.todoList,
    required super.child,
    super.key,
  });

  final TaskList todoList;

  @override
  bool updateShouldNotify(covariant TaskListInheritedWidget oldWidget) => todoList != oldWidget.todoList;
}
