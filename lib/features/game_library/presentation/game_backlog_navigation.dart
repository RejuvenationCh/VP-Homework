import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import '../models/game.dart';
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
  String? _genreRequest;
  bool _isOpeningOverviewGame = false;
  final _libraryKey = GlobalKey<GameLibraryScreenState>();

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _overviewRefreshKey++;
        _genreRequest = null;
      }
    });
  }

  void _openGenre(String genre) {
    setState(() {
      _genreRequest = genre;
      _selectedIndex = 1;
    });
  }

  Future<void> _openOverviewGame(Game game) async {
    if (_isOpeningOverviewGame) return;
    _isOpeningOverviewGame = true;
    final library = _libraryKey.currentState;
    if (library != null) {
      final opened = await library.openGame(game);
      if (opened && mounted) _selectDestination(0);
    }
    _isOpeningOverviewGame = false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex != 1 || _genreRequest == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex == 1 && _genreRequest != null) {
          _selectDestination(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            GameOverviewScreen(
              storage: widget.storage,
              refreshKey: _overviewRefreshKey,
              onGenreSelected: _openGenre,
              onGameSelected: _openOverviewGame,
            ),
            GameLibraryScreen(
              key: _libraryKey,
              storage: widget.storage,
              genreRequest: _genreRequest,
            ),
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
      ),
    );
  }
}
