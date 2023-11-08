import "package:flutter/material.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:tasks/back_end/models/todo.dart";
import "package:tasks/back_end/models/todo_list.dart";
import "package:tasks/widgets/screens/home/tabs/todo_item.dart";

class TodoListView extends StatelessWidget {
  const TodoListView({required this.todoList, super.key});

  final TodoList todoList;

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
                child: TodoItem(todoList: todoList, todo: todo),
              ),
          ],
        ),
      ),
    );
  }
}
