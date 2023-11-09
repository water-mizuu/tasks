import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/side_drawer.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/task_input.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/task_list.dart";
import "package:tasks/widgets/shared/helper/change_notifier_builder.dart";
import "package:tasks/widgets/shared/helper/responsive.dart";

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
    return NotificationListener<_ChangeTitleNotification>(
      onNotification: (_ChangeTitleNotification notification) {
        taskRepository.activeTaskList.name = notification.title;
        return true;
      },
      child: InheritedTaskRepository(
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
                AppBar(scrolledUnderElevation: 0.0, title: const EditableListTitle()),
                const Expanded(child: TaskListView()),
                const TaskInput(),
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
        title: const EditableListTitle(),
      ),
      drawer: const SideDrawer(shouldPop: true),
      body: const Column(
        children: <Widget>[
          Expanded(child: TaskListView()),
          TaskInput(),
        ],
      ),
    );
  }
}

class EditableListTitle extends StatefulWidget {
  const EditableListTitle({super.key});

  @override
  State<EditableListTitle> createState() => _EditableListTitleState();
}

class _EditableListTitleState extends State<EditableListTitle> {
  final FocusNode focusNode = FocusNode();
  TextEditingController? textEditingController;

  void focus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void Function() completeEdit(BuildContext context) {
    return () {
      _ChangeTitleNotification(title: textEditingController!.value.text).dispatch(context);
      setState(() {
        textEditingController = null;
      });
    };
  }

  @override
  void dispose() {
    textEditingController?.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TaskRepository taskRepository = TaskRepository.of(context);

    return ListenableBuilder(
      listenable: taskRepository,
      builder: (BuildContext context, _) {
        return ChangeNotifierBuilder(
          changeNotifier: taskRepository.activeTaskList,
          selector: (TaskList taskList) => taskList.name,
          builder: (BuildContext context, TaskList taskList, Widget? child) {
            return GestureDetector(
              onDoubleTap: () {
                setState(() {
                  textEditingController = TextEditingController(text: taskList.name);
                  focus();
                });
              },
              child: TextField(
                controller: textEditingController ?? TextEditingController(text: taskList.name),
                focusNode: focusNode,
                autofocus: true,
                showCursor: true,
                onEditingComplete: completeEdit(context),
                onTapOutside: (_) => completeEdit(context)(),
                enabled: textEditingController != null,
                style: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                  Color color = states.contains(MaterialState.disabled) //
                      ? Colors.black
                      : Colors.black87;

                  return TextStyle(color: color, fontSize: 24.0);
                }),
                decoration: const InputDecoration(
                  disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ChangeTitleNotification extends Notification {
  const _ChangeTitleNotification({required this.title});
  final String title;
}
