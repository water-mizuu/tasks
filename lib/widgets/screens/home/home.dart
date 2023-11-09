import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/widgets/screens/task_list/side_drawer.dart";
import "package:tasks/widgets/screens/task_list/task_input.dart";
import "package:tasks/widgets/screens/task_list/task_list.dart";
import "package:tasks/widgets/shared/helper/responsive.dart";
import "package:tasks/widgets/shared/miscellaneous.dart/editable_list_title.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TaskRepository taskRepository = TaskRepository();

  @override
  void initState() {
    super.initState();

    <TaskList>[
      TaskList.dummy(id: 0, taskCount: 6, name: "List #0"),
      TaskList.dummy(id: 1, taskCount: 5, name: "List #1"),
      TaskList.dummy(id: 2, taskCount: 3, name: "List #2"),
    ].forEach(taskRepository.addTaskList);
  }

  @override
  Widget build(BuildContext context) {
    return InheritedTaskRepository(
      taskRepository: taskRepository,
      child: ListenableBuilder(
        listenable: taskRepository,
        builder: (BuildContext context, Widget? child) {
          return Responsive(
            mobileBuilder: (BuildContext context) => MobileTaskList(taskList: taskRepository.activeTaskList),
            desktopBuilder: (BuildContext context) => DesktopTaskList(taskList: taskRepository.activeTaskList),
          );
        },
      ),
    );
  }
}

class DesktopTaskList extends StatelessWidget {
  const DesktopTaskList({
    required this.taskList,
    super.key,
  });

  final TaskList taskList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SideDrawer(shouldPop: false),
          Expanded(
            child: Column(
              children: <Widget>[
                AppBar(
                  scrolledUnderElevation: 0.0,
                  title: NotificationListener<ChangeTitleNotification>(
                    onNotification: (ChangeTitleNotification notification) {
                      taskList.name = notification.title;
                      return true;
                    },
                    child: EditableListTitle(taskList: taskList),
                  ),
                ),
                Expanded(
                  child: TaskListView(taskList: taskList),
                ),
                TaskInput(taskList: taskList),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MobileTaskList extends StatelessWidget {
  const MobileTaskList({required this.taskList, super.key});

  final TaskList taskList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: NotificationListener<ChangeTitleNotification>(
          onNotification: (ChangeTitleNotification notification) {
            taskList.name = notification.title;
            return true;
          },
          child: EditableListTitle(taskList: taskList),
        ),
      ),
      drawer: const SideDrawer(shouldPop: true),
      body: Column(
        children: <Widget>[
          Expanded(
            child: TaskListView(taskList: taskList),
          ),
          TaskInput(taskList: taskList),
        ],
      ),
    );
  }
}
