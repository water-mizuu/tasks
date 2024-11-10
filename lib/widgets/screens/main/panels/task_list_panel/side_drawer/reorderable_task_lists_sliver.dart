import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/side_drawer/notifications/change_task_list_index.dart";
import "package:tasks/widgets/shared/helper/change_notifier_builder.dart";

class ReorderableTaskListsSliver extends StatelessWidget {
  const ReorderableTaskListsSliver({
    super.key,
  });

  String _selector(TaskRepository repository) {
    List<TaskList> taskLists = repository.taskLists.toList()
      ..sort((TaskList a, TaskList b) => a.listIndex - b.listIndex);

    return taskLists.map((TaskList v) => v.id).join(";");
  }

  @override
  Widget build(BuildContext context) {
    TaskRepository repository = TaskRepository.of(context);
    return SliverPadding(
      padding: const EdgeInsets.only(left: 8),
      sliver: ChangeNotifierBuilder(
        changeNotifier: repository,
        selector: _selector,
        builder: (BuildContext context, TaskRepository repository, Widget? child) {
          List<TaskList> taskLists = repository.taskLists.toList()
            ..sort((TaskList a, TaskList b) => a.listIndex - b.listIndex);

          return SliverReorderableList(
            onReorder: (int a, int b) {
              repository.reorganizeTaskList(from: a, to: b);
            },
            itemCount: taskLists.length,
            itemBuilder: (BuildContext context, int index) {
              return ReorderableDelayedDragStartListener(
                key: ValueKey<int>(taskLists[index].id),
                index: index,
                child: ChangeNotifierBuilder(
                  changeNotifier: taskLists[index],
                  selector: (TaskList taskList) => taskList.name,
                  builder: (BuildContext context, TaskList taskList, Widget? widget) {
                    return Material(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: ListTile(
                        onTap: () => ChangeActiveTaskListIndexNotification(index).dispatch(context),
                        title: Text(taskList.name),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
