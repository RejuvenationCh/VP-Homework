import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'features/game_library/data/game_library_storage.dart';
import 'features/game_library/presentation/game_backlog_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final providedHome = home;
    Widget firstScreen;
    if (providedHome == null) {
      firstScreen = GameBacklogNavigation(storage: GameLibraryStorage());
    } else {
      firstScreen = providedHome;
    }
    return MaterialApp(
      title: 'Game Backlog',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode,
      builder: builder,
      home: firstScreen,
    );
  }
}
