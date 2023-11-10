import "package:flutter/material.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/shared/extension_types/immutable_list.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/list_input.dart";
import "package:tasks/widgets/shared/helper/change_notifier_builder.dart";

class SideDrawer extends StatelessWidget {
  const SideDrawer({required this.shouldPop, super.key});

  final bool shouldPop;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<_ChangeActiveTaskListIndexNotification>(
      onNotification: (_ChangeActiveTaskListIndexNotification notification) {
        TaskRepository.of(context).activeTaskListIndex = notification.index;
        if (shouldPop) {
          Navigator.pop(context);
        }

        return true;
      },
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: MouseScroll(
                builder: (BuildContext context, ScrollController controller, ScrollPhysics physics) => CustomScrollView(
                  controller: controller,
                  physics: physics,
                  slivers: const <Widget>[
                    SliverOpacity(opacity: 0.0, sliver: SliverToBoxAdapter(child: Divider())),
                    SideTitle(text: "Welcome!"),
                    PredefinedTaskListsSliver(),
                    SliverToBoxAdapter(child: Divider()),
                    SideTitle(text: "Task Lists"),
                    ReorderableTaskListsSliver(),
                  ],
                ),
              ),
            ),
            const Divider(),
            const ListInput(),
          ],
        ),
      ),
    );
  }
}

class SideTitle extends StatelessWidget {
  const SideTitle({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16) + const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class PredefinedTaskListsSliver extends StatelessWidget {
  const PredefinedTaskListsSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 8),
      sliver: Builder(
        builder: (BuildContext context) {
          TaskRepository repository = TaskRepository.of(context);
          ImmutableList<TaskList> taskLists = repository.taskLists;

          return ChangeNotifierBuilder(
            changeNotifier: repository,
            selector: (TaskRepository repository) => taskLists.map((TaskList v) => v.id).join(";"),
            builder: (BuildContext context, TaskRepository repository, Widget? child) {
              return SliverList.builder(
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
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () => _ChangeActiveTaskListIndexNotification(index).dispatch(context),
                            title: Text(taskList.name),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

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
                      color: Colors.transparent,
                      child: ListTile(
                        onTap: () => _ChangeActiveTaskListIndexNotification(index).dispatch(context),
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

class _ChangeActiveTaskListIndexNotification extends Notification {
  const _ChangeActiveTaskListIndexNotification(this.index);

  final int index;
}
