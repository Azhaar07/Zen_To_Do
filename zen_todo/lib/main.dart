import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zen_todo/controllers/theme_controller.dart';
import 'package:zen_todo/screens/home_screen.dart';
import 'package:zen_todo/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>('tasks');
  await Hive.openBox<String>('settings');
  runApp(const ProviderScope(child: ZenTodoApp()));
}

class ZenTodoApp extends ConsumerWidget {
  const ZenTodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeControllerProvider);
    final data = themeDataFor(appTheme);
    return AnimatedTheme(
      data: data,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: MaterialApp(
        title: 'Zen To-Do',
        debugShowCheckedModeBanner: false,
        theme: data,
        routes: {
          '/': (_) => const HomeScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
