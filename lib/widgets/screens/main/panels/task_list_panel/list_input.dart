import "package:flutter/material.dart";
import "package:tasks/back_end/models/task_repository.dart";

class ListInput extends StatefulWidget {
  const ListInput({super.key});

  @override
  State<ListInput> createState() => _ListInputState();
}

class _ListInputState extends State<ListInput> {
  late final TextEditingController textEditingController;

  _ListBuilder? _listBuilder;
  _ListBuilder get taskBuilder {
    if (_listBuilder == null) {
      setState(() {
        _listBuilder = _ListBuilder();
      });
    }

    return _listBuilder!;
  }

  void _submitListBuilder() {
    String? name = taskBuilder.name;
    if (name == null || name.isEmpty) {
      return;
    }

    TaskRepository.of(context).createTaskList(name: name);
    textEditingController.clear();
    setState(() {
      _listBuilder = null;
    });
  }

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              onPressed: _submitListBuilder,
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
                hintText: "Create a list",
              ),
              onChanged: (String value) {
                if (value.isEmpty) {
                  setState(() {
                    _listBuilder = null;
                  });
                } else {
                  taskBuilder.name = value;
                }
              },
              onSubmitted: (String title) {
                taskBuilder.name = title;
                _submitListBuilder();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListBuilder extends ChangeNotifier {
  String? _name;
  String? get name => _name;
  set name(String? name) {
    if (_name != name) {
      _name = name;
      notifyListeners();
    }
  }
}
