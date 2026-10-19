import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_library_filter.dart';
import 'game_library_dropdown_filters.dart';

class GameLibraryControls extends StatelessWidget {
  const GameLibraryControls({
    super.key,
    required this.searchController,
    required this.query,
    required this.genres,
    required this.platforms,
    required this.selectedGenre,
    required this.selectedPlatform,
    required this.selectedStatus,
    required this.favoritesOnly,
    required this.sort,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onGenreChanged,
    required this.onPlatformChanged,
    required this.onStatusChanged,
    required this.onFavoritesChanged,
    required this.onSortChanged,
    required this.onResetFilters,
  });

  final TextEditingController searchController;
  final String query;
  final List<String> genres;
  final List<String> platforms;
  final String? selectedGenre;
  final String? selectedPlatform;
  final GameStatus? selectedStatus;
  final bool favoritesOnly;
  final GameLibrarySort sort;
  final bool hasActiveFilters;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          decoration: InputDecoration(
            hintText: 'Search games',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.clear),
                  ),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        GameLibraryDropdownFilters(
          genres: genres,
          platforms: platforms,
          selectedGenre: selectedGenre,
          selectedPlatform: selectedPlatform,
          selectedStatus: selectedStatus,
          onGenreChanged: onGenreChanged,
          onPlatformChanged: onPlatformChanged,
          onStatusChanged: onStatusChanged,
        ),
        FilterChip(
          label: const Text('Favorites'),
          selected: favoritesOnly,
          onSelected: onFavoritesChanged,
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PopupMenuButton<GameLibrarySort>(
              tooltip: 'Sort games',
              initialValue: sort,
              onSelected: onSortChanged,
              itemBuilder: (context) => [
                for (final option in GameLibrarySort.values)
                  PopupMenuItem<GameLibrarySort>(
                    value: option,
                    child: Text(option.label),
                  ),
              ],
              child: Chip(
                avatar: const Icon(Icons.sort),
                label: Text(sort.label),
              ),
            ),
            if (hasActiveFilters)
              TextButton(
                onPressed: onResetFilters,
                child: const Text('Reset filters'),
              ),
          ],
        ),
      ],
    );
  }
}
