import "package:flutter/material.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/side_drawer/predefined_task_lists_sliver.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/side_drawer/reorderable_task_lists_sliver.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/side_drawer/side_title.dart";

class TaskListsView extends StatelessWidget {
  const TaskListsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}
