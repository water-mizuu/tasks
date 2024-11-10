import "package:flutter/material.dart";
import "package:scroll_animator/scroll_animator.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel"
    "/side_drawer/predefined_task_lists_sliver.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel"
    "/side_drawer/reorderable_task_lists_sliver.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel"
    "/side_drawer/side_title.dart";

class TaskListsView extends StatefulWidget {
  const TaskListsView({super.key});

  @override
  State<TaskListsView> createState() => _TaskListsViewState();
}

class _TaskListsViewState extends State<TaskListsView> {
  final AnimatedScrollController _scrollController = AnimatedScrollController(
    animationFactory: const ChromiumEaseInOut(),
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: const <Widget>[
          SliverOpacity(opacity: 0.0, sliver: SliverToBoxAdapter(child: Divider())),
          SideTitle(text: "Welcome!"),
          PredefinedTaskListsSliver(),
          SliverToBoxAdapter(child: Divider()),
          SideTitle(text: "Task Lists"),
          ReorderableTaskListsSliver(),
        ],
      ),
    );
  }
}
