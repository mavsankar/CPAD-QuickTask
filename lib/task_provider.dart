import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'task_model.dart';

class TaskProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }


  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> fetchTasks() async {
    isLoading = true;
    var query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..orderByDescending('dueDate')
      ..whereEqualTo('userName', (await ParseUser.currentUser())!.username);
    final response = await query.query();

    if (response.success && response.results != null) {
      _tasks = response.results!.map((e) => Task.fromParse(e)).toList();
      notifyListeners();
    }
    isLoading = false;
  }
  void clearTasks() {
    _tasks.clear();
    notifyListeners();
  }
  Future<bool> addTask(String title, DateTime dueDate, String userName) async {
    isLoading = true;
    var task = ParseObject('Task')
      ..set('title', title)
      ..set('dueDate', dueDate)
      ..set('isCompleted', false)
      ..set('userName', userName);

    final response = await task.save();

    if (response.success) {
      fetchTasks();
      isLoading = false;
      return true;
    } else {
      isLoading = false;
      return false;
    }
  }

  void updateTask(Task task) {
    var parseObject = ParseObject('Task')
      ..objectId = task.objectId;
    parseObject.set('title', task.title);
    parseObject.set('dueDate', task.dueDate);

    parseObject.save().then((response) {
      if (response.success) {
        _tasks[_tasks.indexWhere((element) => element.objectId == task.objectId)] = task;
        notifyListeners();
      }
    });    
  }

  Future<bool> updateTaskStatus(Task task, bool isCompleted) async {
    var parseObject = ParseObject('Task')
      ..objectId = task.objectId
      ..set('isCompleted', isCompleted);
    final response = await parseObject.save();

    if (response.success) {
      task.isCompleted = isCompleted;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteTask(Task task) async {
    var parseObject = ParseObject('Task')..objectId = task.objectId;
    final response = await parseObject.delete();

    if (response.success) {
      _tasks.remove(task);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
