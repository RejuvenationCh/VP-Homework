import 'package:flutter/material.dart';

import '../models/game.dart';

class GameLibraryDropdownFilters extends StatelessWidget {
  const GameLibraryDropdownFilters({
    super.key,
    required this.genres,
    required this.platforms,
    required this.selectedGenre,
    required this.selectedPlatform,
    required this.selectedStatus,
    required this.onGenreChanged,
    required this.onPlatformChanged,
    required this.onStatusChanged,
  });

  final List<String> genres;
  final List<String> platforms;
  final String? selectedGenre;
  final String? selectedPlatform;
  final GameStatus? selectedStatus;
  final ValueChanged<String?> onGenreChanged;
  final ValueChanged<String?> onPlatformChanged;
  final ValueChanged<GameStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth;
        if (constraints.maxWidth >= 640) {
          itemWidth = (constraints.maxWidth - 24) / 3;
        } else {
          itemWidth = constraints.maxWidth;
        }
        return Wrap(
          spacing: 8,
          runSpacing: 12,
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
    );
  }

  Widget _stringFilter(
    String allLabel,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    var label = 'Genre';
    if (allLabel == 'All platforms') label = 'Platform';
    final items = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(value: null, child: Text(allLabel)),
      for (final option in options)
        DropdownMenuItem<String?>(
          value: option,
          child: Text(option, overflow: TextOverflow.ellipsis),
        ),
    ];
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
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
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Status'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GameStatus?>(
          value: selectedStatus,
          isExpanded: true,
          items: items,
          onChanged: onStatusChanged,
        ),
      ),
    );
  }
}
