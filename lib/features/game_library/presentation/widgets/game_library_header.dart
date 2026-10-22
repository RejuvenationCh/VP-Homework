import 'package:flutter/material.dart';

import '../../models/game.dart';
import './game_library_controls.dart';
import '../helpers/game_library_filter.dart';

class GameLibraryHeader extends StatelessWidget {
  const GameLibraryHeader({
    super.key,
    required this.games,
    required this.searchController,
    required this.query,
    required this.selectedGenre,
    required this.selectedPlatform,
    required this.selectedStatus,
    required this.favoritesOnly,
    required this.sort,
    required this.hasActiveFilters,
    required this.onAddGame,
    required this.onLoadSamples,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onGenreChanged,
    required this.onPlatformChanged,
    required this.onStatusChanged,
    required this.onFavoritesChanged,
    required this.onSortChanged,
    required this.onResetFilters,
  });

  final List<Game> games;
  final TextEditingController searchController;
  final String query;
  final String? selectedGenre;
  final String? selectedPlatform;
  final GameStatus? selectedStatus;
  final bool favoritesOnly;
  final GameLibrarySort sort;
  final bool hasActiveFilters;
  final Future<void> Function(List<Game>) onAddGame;
  final Future<void> Function(List<Game>) onLoadSamples;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String?> onGenreChanged;
  final ValueChanged<String?> onPlatformChanged;
  final ValueChanged<GameStatus?> onStatusChanged;
  final ValueChanged<bool> onFavoritesChanged;
  final ValueChanged<GameLibrarySort> onSortChanged;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Games: ${games.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => onAddGame(games),
                  icon: const Icon(Icons.add),
                  label: const Text('Add game'),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Library options',
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (_) => onLoadSamples(games),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'samples',
                      child: Text('Load sample games'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GameLibraryControls(
              searchController: searchController,
              query: query,
              genres: libraryGenres(games),
              platforms: libraryPlatforms(games),
              selectedGenre: selectedGenre,
              selectedPlatform: selectedPlatform,
              selectedStatus: selectedStatus,
              favoritesOnly: favoritesOnly,
              sort: sort,
              hasActiveFilters: hasActiveFilters,
              onSearchChanged: onSearchChanged,
              onClearSearch: onClearSearch,
              onGenreChanged: onGenreChanged,
              onPlatformChanged: onPlatformChanged,
              onStatusChanged: onStatusChanged,
              onFavoritesChanged: onFavoritesChanged,
              onSortChanged: onSortChanged,
              onResetFilters: onResetFilters,
            ),
          ],
        ),
      ),
    );
  }
}
