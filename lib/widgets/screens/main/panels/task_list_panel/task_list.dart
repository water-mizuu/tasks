import "package:flutter/material.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/notifications/remove_task_notification.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/task_item.dart";
import "package:tasks/widgets/shared/helper/change_notifier_builder.dart";

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBuilder(
      changeNotifier: TaskRepository.of(context),
      selector: (TaskRepository repository) => repository.activeTaskList,
      builder: (BuildContext context, TaskRepository repository, Widget? child) {
        return ChangeNotifierBuilder(
          changeNotifier: repository.activeTaskList,
          builder: (BuildContext context, TaskList taskList, Widget? child) {
            return NotificationListener<RemoveTaskNotification>(
              onNotification: (RemoveTaskNotification notification) {
                taskList.removeTask(id: notification.id);
                return true;
              },
              child: MouseScroll(
                builder: (BuildContext context, ScrollController controller, ScrollPhysics physics) {
                  return ReorderableListView(
                    scrollController: controller,
                    physics: physics,
                    onReorder: (int start, int end) {
                      taskList.reorganizeTask(from: start, to: end);
                    },
                    children: <Widget>[
                      for (var (int index, Task task) in taskList.tasks.indexed)
                        ReorderableDelayedDragStartListener(
                          key: ValueKey<int>(task.id),
                          index: index,
                          child: TaskItem(taskRepository: repository, task: task),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
