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
    return NotificationListener<RemoveTaskNotification>(
      onNotification: (RemoveTaskNotification notification) {
        TaskRepository.of(context).removeTask(id: notification.id);
        return true;
      },
      child: ChangeNotifierBuilder(
        changeNotifier: TaskRepository.of(context),
        selector: (TaskRepository repository) => repository.activeTaskList,
        builder: (BuildContext context, TaskRepository repository, Widget? child) {
          return switch (repository.activeTaskList) {
            TaskList activeTaskList => ChangeNotifierBuilder(
                changeNotifier: repository,
                selector: (TaskRepository repository) => repository //
                    .tasksOf(listId: activeTaskList.id)
                    .map((Task task) => task.id)
                    .join(";"),
                builder: (BuildContext context, Object? list, Widget? child) {
                  return MouseScroll(
                    builder: (BuildContext context, ScrollController controller, ScrollPhysics physics) {
                      List<Task> tasks = repository.tasksOf(listId: activeTaskList.id).toList()
                        ..sort((Task a, Task b) => a.listIndex - b.listIndex);

                      return ReorderableListView(
                        scrollController: controller,
                        physics: physics,
                        onReorder: (int start, int end) {
                          repository.reorganizeTask(activeTaskList, from: start, to: end);
                        },
                        children: <Widget>[
                          for (var (int index, Task task) in tasks.indexed)
                            ReorderableDelayedDragStartListener(
                              key: ValueKey<int>(task.id),
                              index: index,
                              child: TaskItem(taskRepository: repository, task: task),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            null => Container(),
          };
        },
      ),
    );
  }
}
