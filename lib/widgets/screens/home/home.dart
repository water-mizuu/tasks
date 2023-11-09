import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/widgets/inherited_widgets/task_repository.dart";
import "package:tasks/widgets/screens/home/tabs/task_list.dart";
import "package:tasks/widgets/shared/helper/responsive.dart";
import "package:tasks/widgets/shared/miscellaneous.dart/editable_list_title.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ValueNotifier<int> activeTodoListIndex = ValueNotifier<int>(0);
  List<TaskList>? todoLists;

  @override
  void initState() {
    super.initState();

    todoLists = <TaskList>[
      TaskList.dummy(id: 0, taskCount: 20, name: "List #0"),
      TaskList.dummy(id: 1, taskCount: 5, name: "List #1"),
      TaskList.dummy(id: 2, taskCount: 3, name: "List #2"),
    ];
  }

  @override
  void dispose() {
    activeTodoListIndex.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (todoLists case List<TaskList> todoLists) {
      TaskList todoList = todoLists[activeTodoListIndex.value];

      return TaskRepository(
        todoLists: todoLists,
        addTodoList: (TaskList todoList) {
          setState(() {
            todoLists.add(todoList);
          });
        },
        getActiveTodoListIndex: () {
          return activeTodoListIndex.value;
        },
        setActiveTodoListIndex: (int index) {
          setState(() {
            activeTodoListIndex.value = index;
          });
        },
        removeTodoList: (int id) {
          setState(() {
            todoLists.removeWhere((TaskList todoList) => todoList.id == id);
          });
        },
        child: Responsive(
          mobileBuilder: (BuildContext context) => MobileTodoList(todoList: todoList),
          desktopBuilder: (BuildContext context) => DesktopTodoList(todoList: todoList),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class DesktopTodoList extends StatelessWidget {
  const DesktopTodoList({
    required this.todoList,
    super.key,
  });

  final TaskList todoList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Drawer(
            child: CustomScrollView(
              slivers: <Widget>[
                const SliverAppBar(
                  automaticallyImplyLeading: false,
                  title: Text("Todo Lists"),
                  pinned: true,
                ),
                SliverList.builder(
                  itemCount: TaskRepository.of(context).todoLists.length,
                  itemBuilder: (BuildContext context, int index) {
                    TaskRepository repository = TaskRepository.of(context);

                    return ListenableBuilder(
                      listenable: repository.todoLists[index],
                      builder: (BuildContext context, Widget? widget) => ListTile(
                        onTap: () {
                          repository.activeTodoListIndex = index;
                        },
                        title: Text(repository.todoLists[index].name),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                AppBar(
                  scrolledUnderElevation: 0.0,
                  title: NotificationListener<ChangeTitleNotification>(
                    onNotification: (ChangeTitleNotification notification) {
                      todoList.name = notification.title;
                      return true;
                    },
                    child: EditableListTitle(todoList: todoList),
                  ),
                ),
                Expanded(
                  child: TaskListView(todoList: todoList),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MobileTodoList extends StatelessWidget {
  const MobileTodoList({required this.todoList, super.key});

  final TaskList todoList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: NotificationListener<ChangeTitleNotification>(
          onNotification: (ChangeTitleNotification notification) {
            todoList.name = notification.title;
            return true;
          },
          child: EditableListTitle(todoList: todoList),
        ),
      ),
      drawer: Drawer(
        child: CustomScrollView(
          slivers: <Widget>[
            const SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text("Todo Lists"),
              pinned: true,
            ),
            SliverList.builder(
              itemCount: TaskRepository.of(context).todoLists.length,
              itemBuilder: (BuildContext context, int index) {
                TaskRepository repository = TaskRepository.of(context);

                return ListTile(
                  onTap: () {
                    repository.activeTodoListIndex = index;
                    Navigator.of(context).pop();
                  },
                  title: Text(repository.todoLists[index].name),
                );
              },
            ),
          ],
        ),
      ),
      body: TaskListView(todoList: todoList),
    );
  }
}
