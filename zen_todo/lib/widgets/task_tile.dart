import 'package:flutter/material.dart';
import 'package:zen_todo/models/task.dart';

class TaskTile extends StatefulWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onTap,
    required this.onLongPress,
    required this.dragHandle,
  });

  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Widget dragHandle;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _pressed = false;

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.amber;
      case Priority.high:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overdue = widget.task.dueDate != null &&
        widget.task.dueDate!.isBefore(DateTime.now()) &&
        !widget.task.isCompleted;

    return Dismissible(
      key: ValueKey(widget.task.id),
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.85),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async => direction == DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border(left: BorderSide(color: _priorityColor(widget.task.priority), width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_pressed ? 0.2 : 0.1),
                blurRadius: _pressed ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              InkWell(
                onTap: widget.onToggleComplete,
                borderRadius: BorderRadius.circular(999),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: 0, end: widget.task.isCompleted ? 1 : 0),
                  builder: (_, value, __) {
                    return Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                        color: Color.lerp(Colors.transparent, Theme.of(context).colorScheme.primary, value),
                      ),
                      child: Opacity(
                        opacity: value,
                        child: const Icon(Icons.check, size: 16, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Text(widget.task.title, style: Theme.of(context).textTheme.titleMedium),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: widget.task.isCompleted ? 1 : 0),
                              duration: const Duration(milliseconds: 300),
                              builder: (_, widthFactor, __) {
                                return FractionallySizedBox(
                                  widthFactor: widthFactor,
                                  child: Container(height: 2, color: Theme.of(context).hintColor),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((widget.task.note ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(widget.task.note!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                    if (overdue) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Overdue', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ),
              widget.dragHandle,
            ],
          ),
        ),
      ),
    );
  }
}
