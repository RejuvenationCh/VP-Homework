import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_library_controls.dart';
import 'game_library_filter.dart';

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
            Text('Library', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => onAddGame(games),
                  icon: const Icon(Icons.add),
                  label: const Text('Add game'),
                ),
                TextButton.icon(
                  onPressed: () => onLoadSamples(games),
                  icon: const Icon(Icons.download),
                  label: const Text('Load sample games'),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
