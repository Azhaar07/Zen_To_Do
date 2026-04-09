import 'package:hive/hive.dart';
import 'package:zen_todo/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> loadTasks();
  Future<void> saveTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> saveTasks(List<Task> tasks);
}

class HiveTaskRepository implements TaskRepository {
  HiveTaskRepository(this._box);

  final Box<Map> _box;

  @override
  Future<List<Task>> loadTasks() async {
    return _box.values
        .map((dynamic value) => Task.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveTask(Task task) async {
    await _box.put(task.id, task.toJson());
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final Map<String, Map<String, dynamic>> mapped = {
      for (final task in tasks) task.id: task.toJson(),
    };
    await _box.clear();
    await _box.putAll(mapped);
  }
}
