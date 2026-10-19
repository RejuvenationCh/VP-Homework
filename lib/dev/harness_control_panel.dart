import 'package:flutter/material.dart';

import 'achievement_fixtures.dart';
import 'constraint_scenario.dart';
import 'demo_device.dart';
import 'game_fixtures.dart';
import 'harness_device_controls.dart';
import 'harness_scenario_controls.dart';
import 'responsive_fixtures.dart';

class HarnessControlPanel extends StatelessWidget {
  const HarnessControlPanel({
    super.key,
    required this.page,
    required this.constraint,
    required this.gameConstraint,
    required this.showFix,
    required this.device,
    required this.data,
    required this.gameData,
    required this.achievementData,
    required this.landscape,
    required this.keyboard,
    required this.dark,
    required this.insets,
    required this.screenSize,
    required this.onScreen,
    required this.onConstraint,
    required this.onGameConstraint,
    required this.onFix,
    required this.onDevice,
    required this.onData,
    required this.onGameData,
    required this.onAchievementData,
    required this.onLandscape,
    required this.onKeyboard,
    required this.onDark,
    required this.onInsets,
    required this.onReset,
  });

  final DemoScreen page;
  final ConstraintCase? constraint;
  final GameConstraintCase? gameConstraint;
  final bool showFix;
  final DemoDevice device;
  final DemoData data;
  final GameDemoData gameData;
  final AchievementDemoData achievementData;
  final bool landscape, keyboard, dark, insets;
  final Size screenSize;
  final ValueChanged<DemoScreen> onScreen;
  final ValueChanged<ConstraintCase?> onConstraint;
  final ValueChanged<GameConstraintCase?> onGameConstraint;
  final ValueChanged<bool> onFix;
  final ValueChanged<DemoDevice> onDevice;
  final ValueChanged<DemoData> onData;
  final ValueChanged<GameDemoData> onGameData;
  final ValueChanged<AchievementDemoData> onAchievementData;
  final ValueChanged<bool> onLandscape, onKeyboard, onDark, onInsets;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        'Game Backlog · Week 4',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      const Text('H2 errors are available for game and media screens.'),
      const SizedBox(height: 16),
      HarnessScenarioControls(
        page: page,
        constraint: constraint,
        gameConstraint: gameConstraint,
        showFix: showFix,
        onScreen: onScreen,
        onConstraint: onConstraint,
        onGameConstraint: onGameConstraint,
        onFix: onFix,
      ),
      HarnessDeviceControls(
        device: device,
        data: data,
        gameData: gameData,
        achievementData: achievementData,
        landscape: landscape,
        keyboard: keyboard,
        dark: dark,
        insets: insets,
        onDevice: onDevice,
        onData: onData,
        onGameData: onGameData,
        onAchievementData: onAchievementData,
        onLandscape: onLandscape,
        onKeyboard: onKeyboard,
        onDark: onDark,
        onInsets: onInsets,
      ),
      Text(
        'Screen: ${screenSize.width.toInt()} × ${screenSize.height.toInt()} dp',
      ),
      const SizedBox(height: 8),
      const Text('Keyboard is a simulated inset, not a device keyboard.'),
      TextButton.icon(
        onPressed: onReset,
        icon: const Icon(Icons.restart_alt),
        label: const Text('Reset demo'),
      ),
    ],
  );
}
