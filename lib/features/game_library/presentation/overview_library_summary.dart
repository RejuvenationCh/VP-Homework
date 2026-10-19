import 'package:flutter/material.dart';

import '../models/game.dart';

class OverviewLibrarySummary extends StatelessWidget {
  const OverviewLibrarySummary({super.key, required this.games});

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    final counts = <GameStatus, int>{};
    for (final status in GameStatus.values) {
      counts[status] = 0;
    }
    for (final game in games) {
      final current = counts[game.status];
      if (current == null) {
        counts[game.status] = 1;
      } else {
        counts[game.status] = current + 1;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Library summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(_gameTotalLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final status in GameStatus.values)
                  Chip(label: Text('${counts[status]} ${status.label}')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _gameTotalLabel {
    if (games.length == 1) {
      return '1 game';
    } else {
      return '${games.length} games';
    }
  }
}
