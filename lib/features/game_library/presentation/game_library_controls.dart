import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_library_filter.dart';

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
    required this.sort,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onGenreChanged,
    required this.onPlatformChanged,
    required this.onStatusChanged,
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
  final GameLibrarySort sort;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String?> onGenreChanged;
  final ValueChanged<String?> onPlatformChanged;
  final ValueChanged<GameStatus?> onStatusChanged;
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
        LayoutBuilder(
          builder: (context, constraints) {
            double itemWidth;
            if (constraints.maxWidth >= 700) {
              itemWidth = 164;
            } else {
              itemWidth = (constraints.maxWidth - 8) / 2;
            }
            return Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _stringFilter(
                    'All genres',
                    selectedGenre,
                    genres,
                    onGenreChanged,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _stringFilter(
                    'All platforms',
                    selectedPlatform,
                    platforms,
                    onPlatformChanged,
                  ),
                ),
                SizedBox(width: itemWidth, child: _statusFilter()),
              ],
            );
          },
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

  Widget _stringFilter(
    String allLabel,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final items = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(value: null, child: Text(allLabel)),
      for (final option in options)
        DropdownMenuItem<String?>(
          value: option,
          child: Text(option, overflow: TextOverflow.ellipsis),
        ),
    ];
    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: value,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _statusFilter() {
    final items = <DropdownMenuItem<GameStatus?>>[
      const DropdownMenuItem<GameStatus?>(
        value: null,
        child: Text('All statuses'),
      ),
      for (final status in GameStatus.values)
        DropdownMenuItem<GameStatus?>(value: status, child: Text(status.label)),
    ];
    return DropdownButtonHideUnderline(
      child: DropdownButton<GameStatus?>(
        value: selectedStatus,
        isExpanded: true,
        items: items,
        onChanged: onStatusChanged,
      ),
    );
  }
}
