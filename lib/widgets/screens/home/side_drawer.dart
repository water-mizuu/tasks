import "package:flutter/material.dart";
import "package:mouse_scroll/mouse_scroll.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/widgets/screens/home/list_input.dart";
import "package:tasks/widgets/shared/helper/change_notifier_builder.dart";

class SideDrawer extends StatelessWidget {
  const SideDrawer({required this.shouldPop, super.key});

  final bool shouldPop;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: MouseScroll(
              builder: (BuildContext context, ScrollController controller, ScrollPhysics physics) {
                TaskRepository repository = TaskRepository.of(context);

                return ChangeNotifierBuilder(
                  listenable: repository,
                  selector: (TaskRepository taskRepository) => taskRepository.taskLists.length,
                  builder: (BuildContext context, Widget? child) {
                    print("Redraw");
                    return ReorderableListView.builder(
                      scrollController: controller,
                      physics: physics,
                      onReorder: (int a, int b) {
                        repository.reorganizeTask(from: a, to: b);
                      },
                      itemCount: repository.taskLists.length,
                      itemBuilder: (BuildContext context, int index) {
                        TaskList taskList = repository.taskLists[index];

                        return ListenableBuilder(
                          key: ValueKey<int>(taskList.id),
                          listenable: taskList,
                          builder: (BuildContext context, Widget? widget) => ListTile(
                            onTap: () {
                              repository.activeTaskListIndex = index;
                              if (shouldPop) {
                                Navigator.pop(context);
                              }
                            },
                            title: Text(taskList.name),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          const ListInput(),
        ],
      ),
    );
  }
}
