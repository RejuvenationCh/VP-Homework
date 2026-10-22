import 'package:flutter/material.dart';

import '../../data/game_library_storage.dart';
import '../widgets/game_page_body.dart';
import '../widgets/steam_profile_settings_card.dart';

class GameSettingsScreen extends StatelessWidget {
  const GameSettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    this.storage,
    this.onGamesImported,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final GameLibraryStorage? storage;
  final VoidCallback? onGamesImported;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: GamePageBody(
          maxWidth: 720,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Follow your device theme or choose a look for the app.',
                      ),
                      const SizedBox(height: 20),
                      _appearanceControl(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (storage != null)
                SteamProfileSettingsCard(
                  storage: storage!,
                  onImported: onGamesImported,
                ),
              if (storage != null) const SizedBox(height: 16),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('Local data'),
                  subtitle: Text(
                    'Your library and notes stay here. The Steam profile is sent to this app’s configured Steam service.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appearanceControl(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSize = MediaQuery.textScalerOf(context).scale(14);
        if (constraints.maxWidth < 340 || textSize > 17) {
          return DropdownButton<ThemeMode>(
            value: themeMode,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
            onChanged: (mode) {
              if (mode != null) {
                onThemeModeChanged(mode);
              }
            },
          );
        } else {
          return SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                onThemeModeChanged(selection.first);
              }
            },
          );
        }
      },
    );
  }
}
