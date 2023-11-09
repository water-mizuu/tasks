import "package:flutter/material.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/widgets/screens/home/tabs/task_item.dart";

class TaskListView extends StatelessWidget {
  const TaskListView({required this.taskList, super.key});

  final TaskList taskList;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: taskList,
      builder: (BuildContext context, Widget? child) => MouseScroll(
        duration: const Duration(milliseconds: 760),
        builder: (BuildContext context, ScrollController controller, ScrollPhysics physics) => ReorderableListView(
          scrollController: controller,
          physics: physics,
          onReorder: (int start, int end) {
            taskList.reorganizeTask(from: start, to: end);
          },
          children: <Widget>[
            for (var (int index, Task task) in taskList.tasks.indexed)
              ReorderableDelayedDragStartListener(
                key: ValueKey<(int, int)>((taskList.id, index)),
                index: index,
                child: TaskItem(taskList: taskList, task: task),
              ),
          ],
        ),
      ),
    );
  }
}
