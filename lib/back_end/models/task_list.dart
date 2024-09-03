import "package:flutter/material.dart";
import "package:tasks/back_end/database/database_helper.dart";

typedef Indexed<T> = (int index, T value);

class TaskList extends ChangeNotifier {
  TaskList({required this.id, required String name, required int listIndex})
      : _name = name,
        _listIndex = listIndex;

  /// The id of this list.
  final int id;

  String _name;

  /// The name of this list.
  String get name => _name;
  set name(String value) {
    if (_name != value) {
      _name = value;

      DatabaseHelper.renameTaskList(id: id, name: value);

      notifyListeners();
    }
  }

  int _listIndex;
  int get listIndex => _listIndex;
  set listIndex(int value) {
    if (_listIndex != value) {
      _listIndex = value;

      DatabaseHelper.setTaskListListIndex(id: id, listIndex: value);

      notifyListeners();
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{"id": id, "name": name, "list_index": listIndex};
  }
}
