import 'package:flutter/material.dart';

import 'demo_device.dart';
import 'responsive_fixtures.dart';
import 'game_fixtures.dart';
import 'achievement_fixtures.dart';
import 'harness_control_group.dart';

class HarnessDeviceControls extends StatelessWidget {
  const HarnessDeviceControls({
    super.key,
    required this.device,
    required this.data,
    required this.gameData,
    required this.achievementData,
    required this.landscape,
    required this.keyboard,
    required this.dark,
    required this.insets,
    required this.onDevice,
    required this.onData,
    required this.onGameData,
    required this.onAchievementData,
    required this.onLandscape,
    required this.onKeyboard,
    required this.onDark,
    required this.onInsets,
  });

  final DemoDevice device;
  final DemoData data;
  final GameDemoData gameData;
  final AchievementDemoData achievementData;
  final bool landscape, keyboard, dark, insets;
  final ValueChanged<DemoDevice> onDevice;
  final ValueChanged<DemoData> onData;
  final ValueChanged<GameDemoData> onGameData;
  final ValueChanged<AchievementDemoData> onAchievementData;
  final ValueChanged<bool> onLandscape, onKeyboard, onDark, onInsets;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      HarnessControlGroup('Device', [
        for (final device in DemoDevice.values)
          ChoiceChip(
            label: Text(device.label),
            selected: this.device == device,
            onSelected: (value) => onDevice(device),
          ),
      ]),
      HarnessControlGroup('Orientation', [
        ChoiceChip(
          label: const Text('Portrait'),
          selected: !landscape,
          onSelected: (value) => onLandscape(false),
        ),
        ChoiceChip(
          label: const Text('Landscape'),
          selected: landscape,
          onSelected: (value) => onLandscape(true),
        ),
      ]),
      HarnessControlGroup('Data', [
        for (final data in DemoData.values)
          ChoiceChip(
            label: Text(data.label),
            selected: this.data == data,
            onSelected: (value) => onData(data),
          ),
      ]),
      HarnessControlGroup('Game data', [
        for (final data in GameDemoData.values)
          ChoiceChip(
            label: Text(data.label),
            selected: gameData == data,
            onSelected: (_) => onGameData(data),
          ),
      ]),
      HarnessControlGroup('Achievement data', [
        for (final data in AchievementDemoData.values)
          ChoiceChip(
            label: Text(data.label),
            selected: achievementData == data,
            onSelected: (_) => onAchievementData(data),
          ),
      ]),
      HarnessControlGroup('Conditions', [
        FilterChip(
          label: const Text('Keyboard open'),
          selected: keyboard,
          onSelected: (value) => onKeyboard(value),
        ),
        FilterChip(
          label: const Text('Dark mode'),
          selected: dark,
          onSelected: (value) => onDark(value),
        ),
        FilterChip(
          label: const Text('Notch + gesture bar'),
          selected: insets,
          onSelected: (value) => onInsets(value),
        ),
      ]),
    ],
  );
}
