import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/widgets/inherited_widgets/task_repository.dart";
import "package:tasks/widgets/screens/home/task_input.dart";
import "package:tasks/widgets/screens/home/task_list.dart";
import "package:tasks/widgets/shared/helper/responsive.dart";
import "package:tasks/widgets/shared/miscellaneous.dart/editable_list_title.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<TaskList>? taskLists;
  int activeTaskListIndex = 0;

  @override
  void initState() {
    super.initState();

    taskLists = <TaskList>[
      TaskList.dummy(id: 0, taskCount: 6, name: "List #0"),
      TaskList.dummy(id: 1, taskCount: 5, name: "List #1"),
      TaskList.dummy(id: 2, taskCount: 3, name: "List #2"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (taskLists case List<TaskList> taskLists) {
      TaskList taskList = taskLists[activeTaskListIndex];

      return TaskRepository(
        taskLists: taskLists,
        activeTaskListIndex: activeTaskListIndex,
        addTaskList: (TaskList taskList) {
          setState(() {
            taskLists.add(taskList);
          });
        },
        setActiveTaskListIndex: (int index) {
          setState(() {
            activeTaskListIndex = index;
          });
        },
        removeTaskList: (int id) {
          setState(() {
            taskLists.removeWhere((TaskList taskList) => taskList.id == id);
          });
        },
        child: Responsive(
          mobileBuilder: (BuildContext context) => MobileTaskList(taskList: taskList),
          desktopBuilder: (BuildContext context) => DesktopTaskList(taskList: taskList),
        ),
      );
    } else {
      return const SizedBox();
    }
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

class SideDrawer extends StatelessWidget {
  const SideDrawer({required this.shouldPop, super.key});

  final bool shouldPop;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            automaticallyImplyLeading: false,
            title: Text("Task Lists"),
            pinned: true,
          ),
          SliverList.builder(
            itemCount: TaskRepository.of(context).taskLists.length,
            itemBuilder: (BuildContext context, int index) {
              TaskRepository repository = TaskRepository.of(context);

              return ListenableBuilder(
                listenable: repository.taskLists[index],
                builder: (BuildContext context, Widget? widget) => ListTile(
                  onTap: () {
                    repository.activeTaskListIndex = index;
                    if (shouldPop) {
                      Navigator.pop(context);
                    }
                  },
                  title: Text(repository.taskLists[index].name),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
