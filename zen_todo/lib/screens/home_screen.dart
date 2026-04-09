import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zen_todo/controllers/theme_controller.dart';
import 'package:zen_todo/providers/task_provider.dart';
import 'package:zen_todo/services/haptic_service.dart';
import 'package:zen_todo/widgets/add_task_modal.dart';
import 'package:zen_todo/widgets/confetti_overlay.dart';
import 'package:zen_todo/widgets/empty_state.dart';
import 'package:zen_todo/widgets/task_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showCompleted = true;
  bool _playConfetti = false;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final notifier = ref.read(taskProvider.notifier);
    final activeTasks = notifier.activeTasks;
    final completedTasks = notifier.completedTasks;
    final allCompleted = tasks.isNotEmpty && activeTasks.isEmpty;
    if (allCompleted && !_playConfetti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _playConfetti = true);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_greeting()),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 500));
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    sliver: activeTasks.isEmpty
                        ? const SliverFillRemaining(child: EmptyState())
                        : SliverReorderableList(
                            itemCount: activeTasks.length,
                            onReorder: (oldIndex, newIndex) {
                              HapticService.onDrag();
                              notifier.reorderTasks(oldIndex, newIndex);
                            },
                            itemBuilder: (context, index) {
                              final task = activeTasks[index];
                              return Padding(
                                key: ValueKey(task.id),
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TaskTile(
                                  task: task,
                                  onTap: () {},
                                  onLongPress: HapticService.onLongPress,
                                  onToggleComplete: () {
                                    HapticService.onComplete();
                                    notifier.completeTask(task.id);
                                  },
                                  onDelete: () {
                                    HapticService.onDelete();
                                    notifier.deleteTask(task.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Task deleted'),
                                        duration: const Duration(seconds: 4),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: notifier.undoDelete,
                                        ),
                                      ),
                                    );
                                  },
                                  dragHandle: ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(Icons.drag_handle),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: () => setState(() => _showCompleted = !_showCompleted),
                        child: Row(
                          children: [
                            Text('Completed', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(width: 8),
                            Icon(_showCompleted ? Icons.expand_less : Icons.expand_more),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_showCompleted)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                      sliver: SliverList.builder(
                        itemCount: completedTasks.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskTile(
                            task: completedTasks[index],
                            onTap: () {},
                            onLongPress: HapticService.onLongPress,
                            onToggleComplete: () {
                              HapticService.onComplete();
                              notifier.completeTask(completedTasks[index].id);
                            },
                            onDelete: () {
                              HapticService.onDelete();
                              notifier.deleteTask(completedTasks[index].id);
                            },
                            dragHandle: const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ConfettiOverlay(
              play: _playConfetti,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                Colors.white,
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: FloatingActionButton(
          onPressed: () {
            showGeneralDialog<void>(
              context: context,
              barrierLabel: 'Add Task',
              barrierDismissible: true,
              pageBuilder: (_, __, ___) => AddTaskModal(
                onSubmit: (task) {
                  HapticService.onAdd();
                  notifier.addTask(task);
                },
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.add),
              Positioned(
                right: -14,
                top: -10,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${activeTasks.length}',
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class AcrylicLayer extends StatelessWidget {
  const AcrylicLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DefaultTextStyle(style: theme.textTheme.bodyMedium!, child: child),
        ),
      ),
    );
  }
}
