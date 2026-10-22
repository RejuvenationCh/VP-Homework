import 'package:flutter/material.dart';

import './game_library_empty_state.dart';

class GameLibraryStart extends StatelessWidget {
  const GameLibraryStart({
    super.key,
    required this.onAddGame,
    required this.onLoadSamples,
  });

  final VoidCallback onAddGame;
  final VoidCallback onLoadSamples;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: GameLibraryEmptyState(
          icon: Icons.sports_esports_outlined,
          message: 'No games yet',
          actions: [
            FilledButton.icon(
              onPressed: onAddGame,
              icon: const Icon(Icons.add),
              label: const Text('Add game'),
            ),
            TextButton.icon(
              onPressed: onLoadSamples,
              icon: const Icon(Icons.download),
              label: const Text('Load sample games'),
            ),
          ],
        ),
      ),
    ],
  );
}
