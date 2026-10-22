import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'features/game_library/data/game_library_storage.dart';
import './features/game_library/presentation/screens/game_backlog_navigation.dart';

const _appearancePreferenceKey = 'game_backlog.appearance_mode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var themeMode = ThemeMode.system;
  try {
    final savedMode = await SharedPreferencesAsync().getString(
      _appearancePreferenceKey,
    );
    themeMode = _themeModeFromPreference(savedMode);
  } catch (_) {
    // Use the system theme if preferences cannot be read.
  }
  runApp(MyApp(themeMode: themeMode));
}

ThemeMode _themeModeFromPreference(String? value) {
  if (value == 'light') {
    return ThemeMode.light;
  } else if (value == 'dark') {
    return ThemeMode.dark;
  } else {
    return ThemeMode.system;
  }
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
  late final GameLibraryStorage _storage = GameLibraryStorage();

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
    if (widget.home == null) {
      unawaited(_saveThemeMode(mode));
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      await SharedPreferencesAsync().setString(
        _appearancePreferenceKey,
        mode.name,
      );
    } catch (_) {
      // The selected theme still applies until the app closes.
    }
  }

  @override
  Widget build(BuildContext context) {
    final providedHome = widget.home;
    Widget firstScreen;
    if (providedHome == null) {
      firstScreen = GameBacklogNavigation(
        storage: _storage,
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
