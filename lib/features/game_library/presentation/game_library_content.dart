import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_library_controls.dart';
import 'game_library_empty_state.dart';
import 'game_library_filter.dart';
import 'game_library_grid.dart';

class GameLibraryContent extends StatefulWidget {
  const GameLibraryContent({
    super.key,
    required this.games,
    required this.onAddGame,
    required this.onLoadSamples,
    required this.onOpenGame,
  });

  final List<Game> games;
  final Future<void> Function(List<Game> games) onAddGame;
  final void Function(List<Game> games) onLoadSamples;
  final ValueChanged<Game> onOpenGame;

  @override
  State<GameLibraryContent> createState() => _GameLibraryContentState();
}

class _GameLibraryContentState extends State<GameLibraryContent> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedGenre;
  String? _selectedPlatform;
  GameStatus? _selectedStatus;
  GameLibrarySort _sort = GameLibrarySort.nameAscending;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedGenre = null;
      _selectedPlatform = null;
      _selectedStatus = null;
    });
  }

  bool get _hasActiveFilters {
    if (_query.trim().isNotEmpty ||
        _selectedGenre != null ||
        _selectedPlatform != null ||
        _selectedStatus != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.games.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: GameLibraryEmptyState(
              icon: Icons.sports_esports_outlined,
              message: 'No games yet',
              actions: [
                FilledButton.icon(
                  onPressed: () {
                    widget.onAddGame(widget.games);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add game'),
                ),
                TextButton.icon(
                  onPressed: () => widget.onLoadSamples(widget.games),
                  icon: const Icon(Icons.download),
                  label: const Text('Load sample games'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final visibleGames = filterAndSortGames(
      games: widget.games,
      query: _query,
      genre: _selectedGenre,
      platform: _selectedPlatform,
      status: _selectedStatus,
      sort: _sort,
    );

    return CustomScrollView(
      slivers: [
        _buildHeader(),
        if (visibleGames.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _buildNoResults())
        else
          GameLibraryGrid(games: visibleGames, onOpenGame: widget.onOpenGame),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Library', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    widget.onAddGame(widget.games);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add game'),
                ),
                TextButton.icon(
                  onPressed: () => widget.onLoadSamples(widget.games),
                  icon: const Icon(Icons.download),
                  label: const Text('Load sample games'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GameLibraryControls(
              searchController: _searchController,
              query: _query,
              genres: libraryGenres(widget.games),
              platforms: libraryPlatforms(widget.games),
              selectedGenre: _selectedGenre,
              selectedPlatform: _selectedPlatform,
              selectedStatus: _selectedStatus,
              sort: _sort,
              hasActiveFilters: _hasActiveFilters,
              onSearchChanged: (value) => setState(() => _query = value),
              onClearSearch: _clearSearch,
              onGenreChanged: (value) => setState(() => _selectedGenre = value),
              onPlatformChanged: (value) =>
                  setState(() => _selectedPlatform = value),
              onStatusChanged: (value) =>
                  setState(() => _selectedStatus = value),
              onSortChanged: (value) => setState(() => _sort = value),
              onResetFilters: _resetFilters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    final actions = <Widget>[];
    if (_query.trim().isNotEmpty) {
      actions.add(
        TextButton(onPressed: _clearSearch, child: const Text('Clear search')),
      );
    }
    if (_selectedGenre != null ||
        _selectedPlatform != null ||
        _selectedStatus != null) {
      actions.add(
        TextButton(
          onPressed: _resetFilters,
          child: const Text('Reset filters'),
        ),
      );
    }
    return GameLibraryEmptyState(
      icon: Icons.search_off,
      message: 'No games found',
      actions: actions,
    );
  }
}
