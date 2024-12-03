import 'package:flutter/foundation.dart';
import 'task.dart';

class AppState extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTaskCompletion(Task task) {
    final index = _tasks.indexOf(task);
    _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
    notifyListeners();
  }
}

