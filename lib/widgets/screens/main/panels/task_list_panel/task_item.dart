import "package:flutter/material.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/widgets/screens/main/panels/task_list_panel/notifications/remove_task_notification.dart";

class TaskItem extends StatelessWidget {
  const TaskItem({
    required this.taskRepository,
    required this.task,
    super.key,
  });

  final TaskRepository taskRepository;
  final Task task;

  @override
  Widget build(BuildContext context) {
    (_) = MediaQuery.maybeSizeOf(context);

    return ListenableBuilder(
      listenable: task,
      builder: (BuildContext context, _) {
        return Dismissible(
          key: ValueKey<int>(task.id),
          dismissThresholds: const <DismissDirection, double>{
            DismissDirection.endToStart: 0.5,
          },
          confirmDismiss: (DismissDirection direction) async {
            return direction == DismissDirection.endToStart;
          },
          onDismissed: (DismissDirection direction) {
            RemoveTaskNotification(task.id).dispatch(context);
          },
          background: const SizedBox(),
          secondaryBackground: const ColoredBox(
            color: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) {
                        if (value != null) {
                          task.isCompleted = value;
                        }
                      },
                    ),
                  ),
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      fontSize: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          task.name,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        if (task.deadline case DateTime deadline)
                          Text("@ ${deadline.month}/${deadline.day}/${deadline.year}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// taskList.removeTask(id: task.id);
