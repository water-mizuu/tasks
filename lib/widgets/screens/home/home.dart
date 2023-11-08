import "package:flutter/material.dart";
import "package:tasks/back_end/models/todo_list.dart";
import "package:tasks/widgets/inherited_widgets/todo_repo.dart";
import "package:tasks/widgets/screens/home/tabs/todo_list.dart";
import "package:tasks/widgets/shared/helper/responsive.dart";
import "package:tasks/widgets/shared/miscellaneous.dart/editable_todo_list_title.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ValueNotifier<int> activeTodoListIndex = ValueNotifier<int>(0);
  List<TodoList>? todoLists;

  @override
  void initState() {
    super.initState();

    todoLists = <TodoList>[
      TodoList.dummy(id: 0, taskCount: 20, name: "List #0"),
      TodoList.dummy(id: 1, taskCount: 5, name: "List #1"),
      TodoList.dummy(id: 2, taskCount: 3, name: "List #2"),
    ];
  }

  @override
  void dispose() {
    activeTodoListIndex.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (todoLists case List<TodoList> todoLists) {
      TodoList todoList = todoLists[activeTodoListIndex.value];

      return TodoRepository(
        todoLists: todoLists,
        addTodoList: (TodoList todoList) {
          setState(() {
            todoLists.add(todoList);
          });
        },
        setActiveTodoList: (int index) {
          setState(() {
            activeTodoListIndex.value = index;
          });
        },
        removeTodoList: (int id) {
          setState(() {
            todoLists.removeWhere((TodoList todoList) => todoList.id == id);
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

  final TodoList todoList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: TodoListView(todoList: todoList),
    );
  }
}

class MobileTodoList extends StatelessWidget {
  const MobileTodoList({required this.todoList, super.key});

  final TodoList todoList;

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
          child: EditableTodoListTitle(todoList: todoList),
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
              itemCount: TodoRepository.of(context).todoLists.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () {
                    TodoRepository.of(context).setActiveTodoList(index);
                    Navigator.of(context).pop();
                  },
                  title: Text(TodoRepository.of(context).todoLists[index].name),
                );
              },
            ),
          ],
        ),
      ),
      body: TodoListView(todoList: todoList),
    );
  }
}
