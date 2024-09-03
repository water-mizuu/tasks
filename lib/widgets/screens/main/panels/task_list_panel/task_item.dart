import "package:flutter/material.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/back_end/models/task_repository.dart";
import "package:tasks/shared/extensions/maybe_local_to_global.dart";
import "package:tasks/widgets/shared/helper/change_notifier_builder.dart";

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
    var (_) = MediaQuery.maybeSizeOf(context);

    Widget widget = ListenableBuilder(
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
                          task.title,
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

    if (Scrollable.maybeOf(context) case ScrollableState state when state.context.mounted) {
      if (state.context.findRenderObject() case RenderBox parentBox) {
        widget = ChangeNotifierBuilder(
          changeNotifier: state.position,
          builder: (BuildContext context, ScrollPosition position, Widget? child) {
            Widget innerWidget = child!;

            if (context.findRenderObject() case RenderBox box when parentBox.hasSize && box.hasSize) {
              if (box.maybeLocalToGlobal(Offset.zero)?.dy case double offset) {
                double parentHeight = parentBox.size.height;
                double height = box.size.height;

                double factor = switch (offset) {
                  /// If object has parts above the screen
                  // _ when offset < 0 => ((height + offset) / height).clamp(0.0, 1.0),

                  /// If the object has parts below the screen
                  _ when offset + height > parentHeight => ((parentHeight - offset) / height).clamp(0.0, 1.0),
                  _ => 1.0,
                };

                innerWidget = Transform.scale(
                  scale: 0.8 + 0.2 * factor,
                  child: Opacity(
                    opacity: 0.25 + 0.75 * factor,
                    child: innerWidget,
                  ),
                );
              }
            }

            return innerWidget;
          },
          child: widget,
        );
      }
    }

    return widget;
  }
}

// taskList.removeTask(id: task.id);
class RemoveTaskNotification extends Notification {
  const RemoveTaskNotification(this.id);
  final int id;
}
