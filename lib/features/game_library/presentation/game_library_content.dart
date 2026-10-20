import 'package:flutter/material.dart';

import '../../../dev/constraint_scenario.dart';
import '../models/game.dart';
import 'game_library_empty_state.dart';
import 'game_library_filter.dart';
import 'game_library_grid.dart';
import 'game_library_header.dart';
import 'game_library_start.dart';

class GameLibraryContent extends StatefulWidget {
  const GameLibraryContent({
    super.key,
    required this.games,
    required this.onAddGame,
    required this.onLoadSamples,
    required this.onOpenGame,
    this.genreRequest,
    this.h2Preview,
  });

  final List<Game> games;
  final Future<void> Function(List<Game> games) onAddGame;
  final Future<void> Function(List<Game> games) onLoadSamples;
  final ValueChanged<Game> onOpenGame;
  final String? genreRequest;
  final GameConstraintPreview? h2Preview;

  @override
  State<GameLibraryContent> createState() => _GameLibraryContentState();
}

class _GameLibraryContentState extends State<GameLibraryContent> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedGenre;
  String? _selectedPlatform;
  GameStatus? _selectedStatus;
  bool _favoritesOnly = false;
  GameLibrarySort _sort = GameLibrarySort.nameAscending;

  @override
  void initState() {
    super.initState();
    _selectedGenre = widget.genreRequest;
  }

  @override
  void didUpdateWidget(GameLibraryContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.genreRequest != null &&
        oldWidget.genreRequest != widget.genreRequest) {
      _searchController.clear();
      _query = '';
      _selectedPlatform = null;
      _selectedStatus = null;
      _favoritesOnly = false;
      _selectedGenre = widget.genreRequest;
    }
    if (_selectedGenre != null &&
        !libraryGenres(widget.games).contains(_selectedGenre)) {
      _selectedGenre = null;
    }
    if (_selectedPlatform != null &&
        !libraryPlatforms(widget.games).contains(_selectedPlatform)) {
      _selectedPlatform = null;
    }
  }

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
      _favoritesOnly = false;
    });
  }

  bool get _hasActiveFilters {
    if (_query.trim().isNotEmpty ||
        _selectedGenre != null ||
        _selectedPlatform != null ||
        _selectedStatus != null ||
        _favoritesOnly) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.games.isEmpty) {
      return GameLibraryStart(
        onAddGame: () => widget.onAddGame(widget.games),
        onLoadSamples: () => widget.onLoadSamples(widget.games),
      );
    }

    final visibleGames = filterAndSortGames(
      games: widget.games,
      query: _query,
      genre: _selectedGenre,
      platform: _selectedPlatform,
      status: _selectedStatus,
      favoritesOnly: _favoritesOnly,
      sort: _sort,
    );

    return CustomScrollView(
      slivers: [
        GameLibraryHeader(
          games: widget.games,
          searchController: _searchController,
          query: _query,
          selectedGenre: _selectedGenre,
          selectedPlatform: _selectedPlatform,
          selectedStatus: _selectedStatus,
          favoritesOnly: _favoritesOnly,
          sort: _sort,
          hasActiveFilters: _hasActiveFilters,
          onAddGame: widget.onAddGame,
          onLoadSamples: widget.onLoadSamples,
          onSearchChanged: (value) => setState(() => _query = value),
          onClearSearch: _clearSearch,
          onGenreChanged: (value) => setState(() => _selectedGenre = value),
          onPlatformChanged: (value) =>
              setState(() => _selectedPlatform = value),
          onStatusChanged: (value) => setState(() => _selectedStatus = value),
          onFavoritesChanged: (value) => setState(() => _favoritesOnly = value),
          onSortChanged: (value) => setState(() => _sort = value),
          onResetFilters: _resetFilters,
        ),
        if (visibleGames.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _buildNoResults())
        else
          GameLibraryGrid(
            games: visibleGames,
            onOpenGame: widget.onOpenGame,
            h2Preview: widget.h2Preview,
          ),
      ],
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
        _selectedStatus != null ||
        _favoritesOnly) {
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
