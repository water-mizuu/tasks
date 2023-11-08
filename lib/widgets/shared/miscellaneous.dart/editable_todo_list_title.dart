import "package:flutter/material.dart";
import "package:tasks/back_end/models/todo_list.dart";

class EditableTodoListTitle extends StatefulWidget {
  const EditableTodoListTitle({required this.todoList, super.key});

  final TodoList todoList;

  @override
  State<EditableTodoListTitle> createState() => _EditableTodoListTitleState();
}

class _EditableTodoListTitleState extends State<EditableTodoListTitle> {
  final FocusNode focusNode = FocusNode();
  TextEditingController? textEditingController;

  void focus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void Function() completeEdit(BuildContext context) {
    return () {
      ChangeTitleNotification(title: textEditingController!.value.text).dispatch(context);
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
    return ListenableBuilder(
      listenable: widget.todoList,
      builder: (BuildContext context, _) => GestureDetector(
        onDoubleTap: () {
          setState(() {
            textEditingController = TextEditingController(text: widget.todoList.name);
            focus();
          });
        },
        child: TextField(
          controller: textEditingController ?? TextEditingController(text: widget.todoList.name),
          focusNode: focusNode,
          autofocus: true,
          showCursor: true,
          onEditingComplete: completeEdit(context),
          onTapOutside: (_) => completeEdit(context)(),
          enabled: textEditingController != null,
          style: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
            Color color = states.contains(MaterialState.disabled) ? Colors.black : Colors.black87;

            return TextStyle(color: color, fontSize: 24.0);
          }),
          decoration: const InputDecoration(
            disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class ChangeTitleNotification extends Notification {
  const ChangeTitleNotification({required this.title});
  final String title;
}
