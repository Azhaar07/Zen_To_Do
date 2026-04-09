import 'dart:math' as math;

import 'package:flutter/material.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({super.key});

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 1.04).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(painter: _EnsoPainter(Theme.of(context).colorScheme.primary)),
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing here. Add something.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnsoPainter extends CustomPainter {
  _EnsoPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    canvas.drawArc(rect, -math.pi * .15, math.pi * 1.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant _EnsoPainter oldDelegate) => oldDelegate.color != color;
}
