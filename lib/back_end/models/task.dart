import "package:flutter/material.dart";
import "package:tasks/back_end/database/database_helper.dart";

class Task extends ChangeNotifier {
  // "CREATE TABLE IF NOT EXISTS tasks ( "
  // "id INTEGER PRIMARY KEY, "
  // "list_id INTEGER NOT NULL, "
  // "name TEXT NOT NULL, "
  // "deadline INTEGER, "
  // "is_completed INTEGER NOT NULL, "
  // "FOREIGN KEY(list_id) REFERENCES task_lists(id) "
  // ")";

  Task({
    required String title,
    required this.id,
    required int listId,
    required bool isCompleted,
    required DateTime? deadline,
    required int listIndex,
  })  : _deadline = deadline,
        _listId = listId,
        _name = title,
        _isCompleted = isCompleted,
        _listIndex = listIndex;

  /// This is the id of the task. It is NOT meant to be changed.
  final int id;

  /// The id of the list this task belongs to.
  int _listId;
  int get listId => _listId;
  set listId(int value) {
    if (_listId != value) {
      _listId = value;

      DatabaseHelper.setTaskListId(this, listId: value);

      notifyListeners();
    }
  }

  /// The deadline of the task.
  DateTime? _deadline;
  DateTime? get deadline => _deadline;
  set deadline(DateTime? value) {
    if (_deadline != value) {
      _deadline = value;

      DatabaseHelper.setTaskDeadline(this, deadline: value);

      notifyListeners();
    }
  }

  /// The name of the task.
  String _name;
  String get name => _name;
  set name(String value) {
    if (name != value) {
      _name = value;

      DatabaseHelper.setTaskName(this, name: value);

      notifyListeners();
    }
  }

  /// Whether the task is completed or not.
  bool _isCompleted;
  bool get isCompleted => _isCompleted;
  set isCompleted(bool value) {
    if (_isCompleted != value) {
      _isCompleted = value;

      DatabaseHelper.setTaskCompleted(this, isCompleted: value);

      notifyListeners();
    }
  }

  /// This represents the index of the task in the certain list.
  ///  This is required as all tasks are stored in a single table.
  int _listIndex;
  int get listIndex => _listIndex;
  set listIndex(int value) {
    if (_listIndex != value) {
      _listIndex = value;

      DatabaseHelper.setTaskListIndex(this, listIndex: value);

      notifyListeners();
    }
  }

  void toggleIsCompleted() {
    _isCompleted = !_isCompleted;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "list_id": listId,
      "name": name,
      "deadline": deadline?.millisecondsSinceEpoch,
      "is_completed": isCompleted ? 1 : 0,
      "list_index": listIndex,
    };
  }

  @override
  String toString() =>
      "Task(id: $id, name: '$name')";
}
