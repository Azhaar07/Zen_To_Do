import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:zen_todo/models/task.dart';

class AddTaskModal extends StatefulWidget {
  const AddTaskModal({super.key, required this.onSubmit});

  final ValueChanged<Task> onSubmit;

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal>
    with SingleTickerProviderStateMixin {
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _dueDate;
  Priority _priority = Priority.medium;

  late final AnimationController _controller = AnimationController.unbounded(vsync: this)
    ..animateWith(SpringSimulation(const SpringDescription(mass: 1, stiffness: 180, damping: 20), 0, 1, 0));

  @override
  void dispose() {
    _controller.dispose();
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        color: Colors.black.withOpacity(.35),
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                final t = _controller.value.clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset((1 - t) * 120, (1 - t) * 240),
                  child: Opacity(opacity: t, child: child),
                );
              },
              child: Dismissible(
                key: const ValueKey('addTaskModal'),
                direction: DismissDirection.down,
                onDismissed: (_) => Navigator.of(context).pop(),
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: max(MediaQuery.of(context).viewInsets.bottom + 20, 20),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New Task', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _title,
                          autofocus: true,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _note,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Note (optional)'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: _pickDueDate,
                              icon: const Icon(Icons.event),
                              label: Text(_dueDate == null ? 'Set due date' : _dueDate!.toIso8601String().split('T').first),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<Priority>(
                          segments: const [
                            ButtonSegment(value: Priority.low, label: Text('Low')),
                            ButtonSegment(value: Priority.medium, label: Text('Med')),
                            ButtonSegment(value: Priority.high, label: Text('High')),
                          ],
                          selected: {_priority},
                          onSelectionChanged: (selected) => setState(() => _priority = selected.first),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              if (!(_formKey.currentState?.validate() ?? false)) return;
                              widget.onSubmit(
                                Task(
                                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                                  title: _title.text.trim(),
                                  isCompleted: false,
                                  createdAt: DateTime.now(),
                                  dueDate: _dueDate,
                                  priority: _priority,
                                  note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                            child: const Text('Add Task'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
