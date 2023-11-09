import "package:flutter/material.dart";

class Task extends ChangeNotifier {
  Task({
    required String title,
    required this.listId,
    required this.id,
    required bool isCompleted,
  })  : _title = title,
        _isCompleted = isCompleted;

  final int listId;
  final int id;

  String _title;
  String get title => _title;
  set title(String value) {
    if (title != value) {
      _title = value;
      notifyListeners();
    }
  }

  bool _isCompleted;
  bool get isCompleted => _isCompleted;
  set isCompleted(bool value) {
    if (_isCompleted != value) {
      _isCompleted = value;
      notifyListeners();
    }
  }

  void toggleIsCompleted() {
    _isCompleted = !_isCompleted;
    notifyListeners();
  }
}
