import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/shared/extension_types/immutable_list.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/side_drawer/notifications/change_task_list_index.dart";
import "package:tasks/widgets/shared/helper/change_notifier_builder.dart";

class ReorderableTaskListsSliver extends StatelessWidget {
  const ReorderableTaskListsSliver({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TaskRepository repository = TaskRepository.of(context);
    ImmutableList<TaskList> taskLists = repository.taskLists;
    return SliverPadding(
      padding: const EdgeInsets.only(left: 8),
      sliver: ChangeNotifierBuilder(
        changeNotifier: repository,
        selector: (TaskRepository repository) => taskLists.map((TaskList v) => v.id).join(";"),
        builder: (BuildContext context, TaskRepository repository, Widget? child) {
          return SliverReorderableList(
            onReorder: (int a, int b) {
              repository.reorganizeTask(from: a, to: b);
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