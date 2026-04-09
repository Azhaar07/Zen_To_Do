import 'package:flutter/services.dart';

class HapticService {
  static void onAdd() => HapticFeedback.lightImpact();
  static void onComplete() => HapticFeedback.mediumImpact();
  static void onDelete() => HapticFeedback.heavyImpact();
  static void onThemeChange() => HapticFeedback.mediumImpact();
  static void onDrag() => HapticFeedback.selectionClick();
  static void onLongPress() => HapticFeedback.mediumImpact();
}
