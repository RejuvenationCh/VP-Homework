import 'package:flutter/material.dart';

import '../../models/game.dart';
import './genre_bubble_map.dart';
import './overview_game_sections.dart';
import './overview_library_summary.dart';

class GameOverviewContent extends StatelessWidget {
  const GameOverviewContent({
    super.key,
    required this.games,
    required this.onGenreSelected,
    required this.onGameSelected,
  });

  final List<Game> games;
  final ValueChanged<String> onGenreSelected;
  final ValueChanged<Game> onGameSelected;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final game in games) {
      var genre = game.primaryGenre.trim();
      if (genre.isEmpty) genre = 'Unsorted';
      final count = counts[genre];
      if (count == null) {
        counts[genre] = 1;
      } else {
        counts[genre] = count + 1;
      }
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        OverviewLibrarySummary(games: games),
        const SizedBox(height: 32),
        OverviewGameSections(games: games, onGameSelected: onGameSelected),
        const SizedBox(height: 32),
        Text('Explore by genre', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Choose a genre to open its games.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        GenreBubbleMap(counts: counts, onSelected: onGenreSelected),
      ],
    );
  }
}
