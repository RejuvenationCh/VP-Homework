import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import 'game_library_screen.dart';
import 'game_overview_screen.dart';

class GameBacklogNavigation extends StatefulWidget {
  const GameBacklogNavigation({super.key, required this.storage});

  final GameLibraryStorage storage;

  @override
  State<GameBacklogNavigation> createState() => _GameBacklogNavigationState();
}

class _GameBacklogNavigationState extends State<GameBacklogNavigation> {
  int _selectedIndex = 1;
  int _overviewRefreshKey = 0;

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _overviewRefreshKey++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          GameOverviewScreen(
            storage: widget.storage,
            refreshKey: _overviewRefreshKey,
          ),
          GameLibraryScreen(storage: widget.storage),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
