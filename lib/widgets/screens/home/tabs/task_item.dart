import "package:flutter/material.dart";
import "package:tasks/back_end/models/task.dart";
import "package:tasks/back_end/models/task_list.dart";

class TaskItem extends StatelessWidget {
  const TaskItem({required this.taskList, required this.task, super.key});

  final TaskList taskList;
  final Task task;

  @override
  Widget build(BuildContext context) {
    Widget widget = ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[task, taskList]),
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
            taskList.removeTask(id: task.id);
          },
          background: const SizedBox(),
          secondaryBackground: const ColoredBox(
            color: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  task.title,
                  style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 32.0),
                  child: Text(taskList.name),
                ),
              ],
            ),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (bool? value) {
                if (value != null) {
                  taskList.toggleTaskCompletion(id: task.id);
                }
              },
            ),
          ),
        );
      },
    );

    if (Scrollable.maybeOf(context) case ScrollableState state when state.context.mounted) {
      if (state.context.findRenderObject() case RenderBox parentBox) {
        widget = ListenableBuilder(
          listenable: state.position,
          builder: (BuildContext context, Widget? child) {
            if (context.findRenderObject() case RenderBox box when parentBox.hasSize && box.hasSize) {
              double offset = box.localToGlobal(Offset.zero, ancestor: parentBox).dy;
              double parentHeight = parentBox.size.height;
              double height = box.size.height;

              double factor = switch (offset) {
                /// If object has parts above the screen
                // _ when offset < 0 => ((height + offset) / height).clamp(0.0, 1.0),

                /// If the object has parts below the screen
                _ when offset + height > parentHeight => ((parentHeight - offset) / height).clamp(0.0, 1.0),
                _ => 1.0,
              };

              return Transform.scale(
                scale: 0.8 + 0.2 * factor,
                child: Opacity(
                  opacity: 0.25 + 0.75 * factor,
                  child: child,
                ),
              );
            }
            return child!;
          },
          child: widget,
        );
      }
    }

    return widget;
  }
}
