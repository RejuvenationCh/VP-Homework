import 'package:flutter/material.dart';

import 'media_demos/media_cleaner_screen.dart';
import 'media_demos/storage_overview_screen.dart';
import '../main.dart';
import '../features/game_library/data/game_library_storage.dart';
import 'responsive_fixtures.dart';
import 'constraint_scenario.dart';
import 'demo_device.dart';
import 'device_stage.dart';
import 'library_retry_demo.dart';
import 'harness_control_panel.dart';
import 'game_screen_harness.dart';
import 'game_fixtures.dart';
import 'achievement_fixtures.dart';

class DeviceHarness extends StatefulWidget {
  const DeviceHarness({super.key, this.persistLibrary = false});

  final bool persistLibrary;

  @override
  State<DeviceHarness> createState() => _DeviceHarnessState();
}

class _DeviceHarnessState extends State<DeviceHarness> {
  late final GameLibraryStorage _libraryStorage = GameLibraryStorage();
  DemoDevice _device = DemoDevice.small;
  DemoData _data = DemoData.normal;
  final _gameData = GameFixtureSelection();
  AchievementDemoData _achievementData = AchievementDemoData.current;
  DemoScreen _page = DemoScreen.library;
  GameConstraintCase? _gameConstraint;
  bool _landscape = false;
  bool _keyboard = false;
  bool _dark = false;
  bool _insets = false;
  int _revision = 0;
  ConstraintCase? _constraint;
  bool _showFix = true;
  Size get _screen => _landscape ? _device.size.flipped : _device.size;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Game Backlog · Week 4 emulator',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF3555B8),
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final panel = _panel();
              final stage = DeviceStage(
                size: _screen,
                landscape: _landscape,
                showKeyboard: _keyboard,
                showInsets: _insets,
                appBuilder: (media) => MyApp(
                  key: ValueKey((
                    _data,
                    _gameData.selected,
                    _achievementData,
                    _page,
                    _constraint,
                    _gameConstraint,
                    _revision,
                  )),
                  themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
                  // Override after MaterialApp creates its MediaQuery so routes
                  // and Scaffold both receive the simulated constraints.
                  builder: (context, child) =>
                      MediaQuery(data: media, child: child!),
                  home: switch (_page) {
                    DemoScreen.overview => _gameScreen(),
                    DemoScreen.library => _gameScreen(),
                    DemoScreen.details => _gameScreen(),
                    DemoScreen.addEdit => _gameScreen(),
                    DemoScreen.achievements => _gameScreen(),
                    DemoScreen.settings => _gameScreen(),
                    DemoScreen.retry => const LibraryRetryDemo(),
                    DemoScreen.storageOverview => StorageOverviewScreen(
                      items: _data.items,
                    ),
                    DemoScreen.files => MediaCleanerScreen(
                      items: _data.items,
                      constraint: _constraint,
                      showConstraintError: !_showFix,
                    ),
                  },
                ),
              );
              return constraints.maxWidth >= 760
                  ? Row(
                      children: [
                        SizedBox(width: 280, child: panel),
                        const VerticalDivider(width: 1),
                        Expanded(child: stage),
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(height: 200, child: panel),
                        const Divider(height: 1),
                        Expanded(child: stage),
                      ],
                    );
            },
          ),
        ),
      ),
    ),
  );

  Widget _gameScreen() => GameScreenHarness(
    screen: _page,
    storage: _selectedGameStorage,
    memoryGames: _gameData.games,
    achievementData: _achievementData,
    gamePreview: _gamePreview,
    themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
    onMemoryGamesChanged: (games) => setState(() => _gameData.update(games)),
    onThemeModeChanged: (mode) =>
        setState(() => _dark = mode == ThemeMode.dark),
  );
  GameLibraryStorage? get _selectedGameStorage =>
      _gameConstraint == null &&
          _gameData.selected == GameDemoData.current &&
          widget.persistLibrary
      ? _libraryStorage
      : null;

  GameConstraintPreview? get _gamePreview {
    final constraint = _gameConstraint;
    if (constraint == null) {
      return null;
    }
    return GameConstraintPreview(type: constraint, showError: !_showFix);
  }

  Widget _panel() => HarnessControlPanel(
    page: _page,
    constraint: _constraint,
    gameConstraint: _gameConstraint,
    showFix: _showFix,
    device: _device,
    data: _data,
    gameData: _gameData.selected,
    achievementData: _achievementData,
    landscape: _landscape,
    keyboard: _keyboard,
    dark: _dark,
    insets: _insets,
    screenSize: _screen,
    onScreen: (screen) => setState(() {
      _page = screen;
      _constraint = null;
      _gameConstraint = null;
      _showFix = true;
    }),
    onConstraint: (fault) => setState(() {
      _constraint = fault;
      _gameConstraint = null;
      _showFix = true;
      if (fault != null) {
        _page = DemoScreen.files;
        _data = fault == ConstraintCase.longName
            ? DemoData.longName
            : DemoData.normal;
      }
    }),
    onGameConstraint: (fault) => setState(() {
      _constraint = null;
      _gameConstraint = fault;
      _showFix = true;
      if (fault == GameConstraintCase.actionRow) {
        _page = DemoScreen.details;
      } else if (fault != null) {
        _page = DemoScreen.library;
      }
    }),
    onFix: (value) => setState(() {
      _showFix = value;
      if (_gameConstraint != null) _revision++;
    }),
    onDevice: (value) => setState(() => _device = value),
    onData: (value) => setState(() => _data = value),
    onGameData: (value) => setState(() => _gameData.select(value)),
    onAchievementData: (value) => setState(() => _achievementData = value),
    onLandscape: (value) => setState(() => _landscape = value),
    onKeyboard: (value) => setState(() => _keyboard = value),
    onDark: (value) => setState(() => _dark = value),
    onInsets: (value) => setState(() => _insets = value),
    onReset: () => setState(() => _revision++),
  );
}
