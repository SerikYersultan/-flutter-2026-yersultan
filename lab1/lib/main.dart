import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seed = const ColorScheme.light().primary;

    return MaterialApp(
      title: 'Language Exchange',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.shell,
      routes: {
        Routes.shell: (context) => AppShell(
              themeMode: _themeMode,
              onThemeChanged: _changeTheme,
            ),
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => const Scaffold(
          body: Center(child: Text('Not found')),
        ),
      ),
    );
  }
}
