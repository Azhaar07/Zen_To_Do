import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

enum Priority { low, medium, high }

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required bool isCompleted,
    required DateTime createdAt,
    DateTime? dueDate,
    @Default(Priority.medium) Priority priority,
    String? note,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
