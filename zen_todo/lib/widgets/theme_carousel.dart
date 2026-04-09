import 'package:flutter/material.dart';
import 'package:zen_todo/controllers/theme_controller.dart';

class ThemeCarousel extends StatefulWidget {
  const ThemeCarousel({
    super.key,
    required this.activeTheme,
    required this.onChanged,
  });

  final AppTheme activeTheme;
  final ValueChanged<AppTheme> onChanged;

  @override
  State<ThemeCarousel> createState() => _ThemeCarouselState();
}

class _ThemeCarouselState extends State<ThemeCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController =
      PageController(initialPage: widget.activeTheme.index, viewportFraction: 0.8);
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  @override
  void dispose() {
    _pageController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) async {
          _popController.forward(from: 0);
          widget.onChanged(AppTheme.values[index]);
        },
        itemCount: AppTheme.values.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double page = widget.activeTheme.index.toDouble();
              if (_pageController.hasClients && _pageController.page != null) {
                page = _pageController.page!;
              }
              final dist = (page - index).abs();
              final scale = (1 - (dist * 0.15)).clamp(0.85, 1.0);
              final opacity = (1 - (dist * 0.4)).clamp(0.6, 1.0);
              final pop = index == page.round() ? 1 + (0.03 * (1 - _popController.value)) : 1.0;
              return Opacity(
                opacity: opacity,
                child: Transform.scale(scale: scale * pop, child: child),
              );
            },
            child: _ThemePreview(theme: AppTheme.values[index]),
          );
        },
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final td = themeDataFor(theme);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: td.scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.1), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(theme.name.toUpperCase(), style: TextStyle(color: td.colorScheme.onSurface)),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (index) => Container(
              height: 28,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: td.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
