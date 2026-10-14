import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'features/media_cleaner/presentation/storage_overview_screen.dart';

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
    return MaterialApp(
      title: 'Media Cleaner',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode,
      builder: builder,
      home: home ?? const StorageOverviewScreen(),
    );
  }
}
