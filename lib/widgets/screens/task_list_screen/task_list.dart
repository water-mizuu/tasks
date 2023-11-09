import "package:flutter/material.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/widgets/screens/task_list_screen/task_item.dart";

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    TaskRepository repository = TaskRepository.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable?>[repository, repository.activeTaskList]),
      builder: (BuildContext context, Widget? child) {
        TaskList taskList = repository.activeTaskList;

        return MouseScroll(
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
        );
      },
    );
  }
}
