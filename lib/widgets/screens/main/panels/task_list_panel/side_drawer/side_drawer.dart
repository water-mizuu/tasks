import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/side_drawer/notifications/change_task_list_index.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/side_drawer/task_lists_input.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/side_drawer/task_lists_view.dart";

class SideDrawer extends StatelessWidget {
  const SideDrawer({required this.shouldPop, super.key});

  final bool shouldPop;

  bool Function(ChangeActiveTaskListIndexNotification) _onChangeActiveTaskList(BuildContext context) =>
      (ChangeActiveTaskListIndexNotification notification) {
        TaskRepository.of(context).activeTaskListIndex = notification.index;
        if (shouldPop) {
          Navigator.pop(context);
        }

        return true;
      };

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ChangeActiveTaskListIndexNotification>(
      onNotification: _onChangeActiveTaskList(context),
      child: const Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TaskListsView(),
            Divider(),
            TaskListsInput(),
          ],
        ),
      ),
    );
  }
}
