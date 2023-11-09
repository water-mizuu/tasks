import "package:flutter/material.dart";

class Task extends ChangeNotifier {
  Task({
    required String title,
    required this.id,
    required bool isCompleted,
    required DateTime? deadline,
  })  : _deadline = deadline,
        _title = title,
        _isCompleted = isCompleted;

  final int id;

  DateTime? _deadline;
  DateTime? get deadline => _deadline;
  set deadline(DateTime? value) {
    if (_deadline != value) {
      _deadline = value;
      notifyListeners();
    }
  }

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
