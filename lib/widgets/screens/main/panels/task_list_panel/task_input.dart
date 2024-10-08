import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_list.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/widgets/shared/helper/change_notifier_builder.dart";

class TaskInput extends StatefulWidget {
  const TaskInput({super.key});

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  late final TextEditingController textEditingController;
  bool hasListened = false;

  _TaskBuilder? _taskBuilder;
  _TaskBuilder get taskBuilder {
    if (_taskBuilder == null) {
      setState(() {
        _taskBuilder = _TaskBuilder();
      });
    }

    return _taskBuilder!;
  }

  void submitTaskBuilder(TaskList taskList) {
    try {
      var _TaskBuilder(:String? title, :DateTime? deadline) = taskBuilder;
      if (title == null || title.isEmpty) {
        return;
      }

      TaskRepository.of(context).addTask(title: title, deadline: deadline, isCompleted: false);
      textEditingController.clear();
    } finally {
      setState(() {
        _taskBuilder = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBuilder(
      changeNotifier: TaskRepository.of(context),
      selector: (TaskRepository repository) => repository.activeTaskListIndex,
      builder: (BuildContext context, TaskRepository repository, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    if (TaskRepository.of(context).activeTaskList case TaskList taskList) {
                      submitTaskBuilder(taskList);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.add),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Add a task",
                  ),
                  onChanged: (String value) {
                    if (value.isEmpty) {
                      setState(() {
                        _taskBuilder = null;
                      });
                    } else {
                      taskBuilder.title = value;
                    }
                  },
                  onSubmitted: (String title) {
                    taskBuilder.title = title;

                    if (repository.activeTaskList case TaskList taskList) {
                      submitTaskBuilder(taskList);
                    }
                  },
                ),
              ),
              if (_taskBuilder != null)
                TextButton(
                  onPressed: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                      initialDate: taskBuilder.deadline ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );

                    if (date == null) {
                      return;
                    }
                    taskBuilder.deadline = date;
                  },
                  child: ChangeNotifierBuilder(
                    changeNotifier: taskBuilder,
                    selector: (_TaskBuilder taskBuilder) => taskBuilder.deadline,
                    builder: (BuildContext context, _TaskBuilder taskBuilder, Widget? child) {
                      return Column(
                        children: <Widget>[
                          const Icon(Icons.calendar_month_outlined),
                          if (_taskBuilder?.deadline case DateTime deadline)
                            Text(
                              "${deadline.month}/${deadline.day}/${deadline.year}",
                              style: const TextStyle(fontSize: 10),
                            ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

final class _TaskBuilder extends ChangeNotifier {
  _TaskBuilder();

  DateTime? _deadline;
  DateTime? get deadline => _deadline;
  set deadline(DateTime? deadline) {
    if (_deadline != deadline) {
      _deadline = deadline;
      notifyListeners();
    }
  }

  String? _title;
  String? get title => _title;
  set title(String? title) {
    if (_title != title) {
      _title = title;
      notifyListeners();
    }
  }
}
