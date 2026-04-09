import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:zen_todo/models/task.dart';
import 'package:zen_todo/services/storage_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return HiveTaskRepository(Hive.box<Map>('tasks'));
});

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.watch(taskRepositoryProvider));
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier(this._repository) : super(const []) {
    _load();
  }

  final TaskRepository _repository;
  Task? _lastDeleted;

  List<Task> get activeTasks => state.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => state.where((task) => task.isCompleted).toList();

  Future<void> _load() async {
    state = await _repository.loadTasks();
  }

  Future<void> _persist() async {
    await _repository.saveTasks(state);
  }

  Future<void> addTask(Task task) async {
    state = [task, ...state];
    await _persist();
  }

  Future<void> deleteTask(String id) async {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _lastDeleted = state[index];
    state = [...state]..removeAt(index);
    await _persist();
  }

  Future<void> undoDelete() async {
    if (_lastDeleted == null) return;
    state = [_lastDeleted!, ...state];
    _lastDeleted = null;
    await _persist();
  }

  Future<void> completeTask(String id) async {
    state = state
        .map((t) => t.id == id ? t.copyWith(isCompleted: !t.isCompleted) : t)
        .toList();
    await _persist();
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final tasks = [...state];
    final item = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, item);
    state = tasks;
    await _persist();
  }

  Future<void> editTask(Task updated) async {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
    await _persist();
  }
}
