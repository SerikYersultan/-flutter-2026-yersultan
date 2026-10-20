import 'package:flutter/material.dart';

import 'models/exchange_session.dart';
import 'routes.dart';
import 'screens/app_shell.dart';
import 'screens/session_detail_screen.dart';
import 'screens/session_form_screen.dart';
import 'widgets/theme_settings.dart';

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

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    if (settings.name == Routes.detail && arguments is DetailArguments) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => SessionDetailScreen(arguments: arguments),
      );
    }
    if (settings.name == Routes.form && arguments is FormArguments) {
      return MaterialPageRoute<ExchangeSession>(
        settings: settings,
        builder: (context) => SessionFormScreen(session: arguments.session),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final seed = const ColorScheme.light().primary;

    return ThemeSettings(
      mode: _themeMode,
      onChanged: _changeTheme,
      child: MaterialApp(
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
          Routes.shell: (context) => const AppShell(),
        },
        onGenerateRoute: _generateRoute,
        onUnknownRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => const Scaffold(
            body: Center(child: Text('Not found')),
          ),
        ),
      ),
    );
  }
}
