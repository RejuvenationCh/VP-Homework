import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_status_colors.dart';

class OverviewLibrarySummary extends StatelessWidget {
  const OverviewLibrarySummary({super.key, required this.games});

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your collection',
                style: theme.textTheme.headlineSmall,
              ),
            ),
            Text('${games.length} games', style: theme.textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            var columns = 4;
            if (constraints.maxWidth < 440) columns = 2;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final status in GameStatus.values)
                  SizedBox(
                    width: width,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${games.where((game) => game.status == status).length}',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: gameStatusColor(status, theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
