import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'features/game_library/data/game_library_storage.dart';
import 'features/game_library/presentation/game_backlog_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.home,
    this.themeMode = ThemeMode.system,
    this.builder,
  });

  final Widget? home;
  final ThemeMode themeMode;
  final TransitionBuilder? builder;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
  }

  @override
  void didUpdateWidget(MyApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      _themeMode = widget.themeMode;
    }
  }

  void _changeThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final providedHome = widget.home;
    Widget firstScreen;
    if (providedHome == null) {
      firstScreen = GameBacklogNavigation(
        storage: GameLibraryStorage(),
        themeMode: _themeMode,
        onThemeModeChanged: _changeThemeMode,
      );
    } else {
      firstScreen = providedHome;
    }
    return MaterialApp(
      title: 'Game Backlog',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: _themeMode,
      builder: widget.builder,
      home: firstScreen,
    );
  }
}
