import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_library_filter.dart';
import 'game_library_dropdown_filters.dart';

class GameLibraryControls extends StatefulWidget {
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
  State<GameLibraryControls> createState() => _GameLibraryControlsState();
}

class _GameLibraryControlsState extends State<GameLibraryControls> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    var count = 0;
    if (widget.selectedGenre != null) count++;
    if (widget.selectedPlatform != null) count++;
    if (widget.selectedStatus != null) count++;
    var label = 'Filters';
    if (count > 0) label = 'Filters · $count';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.searchController,
          onChanged: widget.onSearchChanged,
          scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          decoration: InputDecoration(
            hintText: 'Search your library',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: widget.query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: widget.onClearSearch,
                    icon: const Icon(Icons.clear),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
              avatar: const Icon(Icons.favorite_border, size: 18),
              showCheckmark: false,
              label: const Text('Favorites'),
              selected: widget.favoritesOnly,
              onSelected: widget.onFavoritesChanged,
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _showFilters = !_showFilters),
              icon: Icon(
                _showFilters ? Icons.expand_less : Icons.tune,
                size: 18,
              ),
              label: Text(label),
            ),
            PopupMenuButton<GameLibrarySort>(
              tooltip: 'Sort games',
              icon: const Icon(Icons.sort),
              initialValue: widget.sort,
              onSelected: widget.onSortChanged,
              itemBuilder: (context) => [
                for (final option in GameLibrarySort.values)
                  CheckedPopupMenuItem<GameLibrarySort>(
                    value: option,
                    checked: widget.sort == option,
                    child: Text(option.label),
                  ),
              ],
            ),
            if (widget.hasActiveFilters)
              TextButton(
                onPressed: widget.onResetFilters,
                child: const Text('Reset filters'),
              ),
          ],
        ),
        if (_showFilters)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: GameLibraryDropdownFilters(
              genres: widget.genres,
              platforms: widget.platforms,
              selectedGenre: widget.selectedGenre,
              selectedPlatform: widget.selectedPlatform,
              selectedStatus: widget.selectedStatus,
              onGenreChanged: widget.onGenreChanged,
              onPlatformChanged: widget.onPlatformChanged,
              onStatusChanged: widget.onStatusChanged,
            ),
          ),
      ],
    );
  }
}
