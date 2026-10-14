import 'package:flutter/material.dart';

import '../features/media_cleaner/presentation/media_cleaner_screen.dart';
import '../features/media_cleaner/presentation/storage_overview_screen.dart';
import '../main.dart';
import 'responsive_fixtures.dart';

// Adapted from W4/lab04: sized frame + MediaQuery + FittedBox.scaleDown.
enum DemoDevice {
  small('Small phone', Size(320, 568)),
  large('Large phone', Size(430, 932)),
  tablet('Tablet', Size(800, 1280));

  const DemoDevice(this.label, this.size);
  final String label;
  final Size size;
}

class DeviceHarness extends StatefulWidget {
  const DeviceHarness({super.key});

  @override
  State<DeviceHarness> createState() => _DeviceHarnessState();
}

class _DeviceHarnessState extends State<DeviceHarness> {
  DemoDevice _device = DemoDevice.small;
  DemoData _data = DemoData.normal;
  bool _files = false;
  bool _landscape = false;
  bool _keyboard = false;
  bool _dark = false;
  bool _insets = false;
  int _revision = 0;

  Size get _screen => _landscape ? _device.size.flipped : _device.size;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Media Cleaner · Week 4 emulator',
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
              final stage = _stage(context);
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
    Widget group(String title, List<Widget> controls) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: controls),
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Media Cleaner · Week 4',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Try both screens and keep the debug console open for overflow warnings.',
        ),
        const SizedBox(height: 16),
        group('Screen', [
          ChoiceChip(
            label: const Text('Storage overview'),
            selected: !_files,
            onSelected: (_) => setState(() => _files = false),
          ),
          ChoiceChip(
            label: const Text('File manager'),
            selected: _files,
            onSelected: (_) => setState(() => _files = true),
          ),
        ]),
        group('Device', [
          for (final device in DemoDevice.values)
            ChoiceChip(
              label: Text(device.label),
              selected: _device == device,
              onSelected: (_) => setState(() => _device = device),
            ),
        ]),
        group('Orientation', [
          ChoiceChip(
            label: const Text('Portrait'),
            selected: !_landscape,
            onSelected: (_) => setState(() => _landscape = false),
          ),
          ChoiceChip(
            label: const Text('Landscape'),
            selected: _landscape,
            onSelected: (_) => setState(() => _landscape = true),
          ),
        ]),
        group('Data', [
          for (final data in DemoData.values)
            ChoiceChip(
              label: Text(data.label),
              selected: _data == data,
              onSelected: (_) => setState(() => _data = data),
            ),
        ]),
        group('Conditions', [
          FilterChip(
            label: const Text('Keyboard open'),
            selected: _keyboard,
            onSelected: (value) => setState(() => _keyboard = value),
          ),
          FilterChip(
            label: const Text('Dark mode'),
            selected: _dark,
            onSelected: (value) => setState(() => _dark = value),
          ),
          FilterChip(
            label: const Text('Notch + gesture bar'),
            selected: _insets,
            onSelected: (value) => setState(() => _insets = value),
          ),
        ]),
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

  Widget _stage(BuildContext context) {
    final size = _screen;
    final keyboard = _keyboard ? (_landscape ? 180.0 : 260.0) : 0.0;
    final padding = !_insets
        ? EdgeInsets.zero
        : _landscape
        ? const EdgeInsets.only(left: 32, bottom: 20)
        : const EdgeInsets.only(top: 32, bottom: 20);
    final safe = keyboard > 0 ? padding.copyWith(bottom: 0) : padding;
    final media = MediaQuery.of(context).copyWith(
      size: size,
      devicePixelRatio: 1,
      padding: safe,
      viewPadding: padding,
      viewInsets: EdgeInsets.only(bottom: keyboard),
    );
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D1F),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox.fromSize(
                  size: size,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: MyApp(
                          key: ValueKey((_data, _files, _revision)),
                          themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
                          // Override after MaterialApp creates its MediaQuery so routes
                          // and Scaffold both receive the simulated constraints.
                          builder: (context, child) =>
                              MediaQuery(data: media, child: child!),
                          home: _files
                              ? MediaCleanerScreen(items: _data.items)
                              : StorageOverviewScreen(items: _data.items),
                        ),
                      ),
                      if (padding.top > 0)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: padding.top,
                          child: const IgnorePointer(
                            child: ColoredBox(
                              color: Color(0xFF1B1D1F),
                              child: Center(
                                child: Text(
                                  '9:41',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (padding.left > 0)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          width: padding.left,
                          child: const IgnorePointer(
                            child: ColoredBox(color: Color(0xFF1B1D1F)),
                          ),
                        ),
                      if (safe.bottom > 0)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: safe.bottom,
                          child: const IgnorePointer(
                            child: ColoredBox(color: Color(0xFF1B1D1F)),
                          ),
                        ),
                      if (keyboard > 0)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: keyboard,
                          child: const IgnorePointer(
                            child: ColoredBox(
                              color: Color(0xFF2B2F33),
                              child: Center(
                                child: Text(
                                  'Simulated keyboard',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
