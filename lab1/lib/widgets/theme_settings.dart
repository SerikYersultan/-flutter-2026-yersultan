import 'package:flutter/material.dart';

class ThemeSettings extends InheritedWidget {
  const ThemeSettings({
    super.key,
    required this.mode,
    required this.onChanged,
    required super.child,
  });

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  static ThemeSettings of(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<ThemeSettings>();
    if (settings == null) {
      throw StateError('ThemeSettings is missing above this widget.');
    }
    return settings;
  }

  @override
  bool updateShouldNotify(ThemeSettings oldWidget) {
    return mode != oldWidget.mode || onChanged != oldWidget.onChanged;
  }
}
