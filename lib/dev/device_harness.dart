import 'package:flutter/material.dart';

import 'media_demos/media_cleaner_screen.dart';
import 'media_demos/storage_overview_screen.dart';
import '../main.dart';
import '../features/game_library/presentation/game_library_screen.dart';
import 'responsive_fixtures.dart';
import 'constraint_scenario.dart';
import 'demo_device.dart';
import 'device_stage.dart';
import 'library_retry_demo.dart';
import 'harness_scenario_controls.dart';
import 'harness_device_controls.dart';

class DeviceHarness extends StatefulWidget {
  const DeviceHarness({super.key});

  @override
  State<DeviceHarness> createState() => _DeviceHarnessState();
}

class _DeviceHarnessState extends State<DeviceHarness> {
  DemoDevice _device = DemoDevice.small;
  DemoData _data = DemoData.normal;
  DemoScreen _page = DemoScreen.library;
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
              final panel = _panel(context);
              final stage = DeviceStage(
                size: _screen,
                landscape: _landscape,
                showKeyboard: _keyboard,
                showInsets: _insets,
                appBuilder: (media) => MyApp(
                  key: ValueKey((_data, _page, _constraint, _revision)),
                  themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
                  // Override after MaterialApp creates its MediaQuery so routes
                  // and Scaffold both receive the simulated constraints.
                  builder: (context, child) =>
                      MediaQuery(data: media, child: child!),
                  home: switch (_page) {
                    DemoScreen.library => const GameLibraryScreen(),
                    DemoScreen.retry => const LibraryRetryDemo(),
                    DemoScreen.overview => StorageOverviewScreen(
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

  Widget _panel(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Game Backlog · Week 4',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'H2 uses the media demos. Data scenarios apply to media demos.',
        ),
        const SizedBox(height: 16),
        HarnessScenarioControls(
          page: _page,
          constraint: _constraint,
          showFix: _showFix,
          onScreen: (screen) => setState(() {
            _page = screen;
            _constraint = null;
            _showFix = true;
          }),
          onConstraint: (fault) => setState(() {
            _constraint = fault;
            _showFix = true;
            if (fault != null) {
              _page = DemoScreen.files;
              _data = fault == ConstraintCase.longName
                  ? DemoData.longName
                  : DemoData.normal;
            }
          }),
          onFix: (value) => setState(() => _showFix = value),
        ),
        HarnessDeviceControls(
          device: _device,
          data: _data,
          landscape: _landscape,
          keyboard: _keyboard,
          dark: _dark,
          insets: _insets,
          onDevice: (value) => setState(() => _device = value),
          onData: (value) => setState(() => _data = value),
          onLandscape: (value) => setState(() => _landscape = value),
          onKeyboard: (value) => setState(() => _keyboard = value),
          onDark: (value) => setState(() => _dark = value),
          onInsets: (value) => setState(() => _insets = value),
        ),
        Text('Screen: ${_screen.width.toInt()} × ${_screen.height.toInt()} dp'),
        const SizedBox(height: 8),
        const Text(
          'Keyboard is a simulated inset. These screens have no text fields.',
        ),
        TextButton.icon(
          onPressed: () => setState(() => _revision++),
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset demo'),
        ),
      ],
    );
  }
}
