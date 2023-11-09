import "package:flutter/material.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/todo.dart";
import "package:tasks/widgets/screens/home/tabs/task_item.dart";

class TaskListView extends StatelessWidget {
  const TaskListView({required this.todoList, super.key});

  final TaskList todoList;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: todoList,
      builder: (BuildContext context, Widget? child) => MouseScroll(
        duration: const Duration(milliseconds: 760),
        builder: (BuildContext context, ScrollController controller, ScrollPhysics physics) => ReorderableListView(
          scrollController: controller,
          physics: physics,
          onReorder: (int start, int end) {
            todoList.reorganizeTodo(from: start, to: end);
          },
          children: <Widget>[
            for (var (int index, Todo todo) in todoList.todos.indexed)
              ReorderableDelayedDragStartListener(
                key: ValueKey<(int, int)>((todoList.id, index)),
                index: index,
                child: TaskItem(todoList: todoList, todo: todo),
              ),
          ],
        ),
      ),
    );
  }
}
