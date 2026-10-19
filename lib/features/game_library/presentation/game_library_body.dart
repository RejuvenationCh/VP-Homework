import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_library_content.dart';

class GameLibraryBody extends StatelessWidget {
  const GameLibraryBody({
    super.key,
    required this.games,
    required this.currentGames,
    required this.hasSavedData,
    required this.onRetry,
    required this.onAddGame,
    required this.onLoadSamples,
    required this.onOpenGame,
  });

  final Future<List<Game>> games;
  final List<Game>? currentGames;
  final bool hasSavedData;
  final VoidCallback onRetry;
  final Future<void> Function(List<Game>) onAddGame;
  final Future<void> Function(List<Game>) onLoadSamples;
  final ValueChanged<Game> onOpenGame;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Game>>(
        future: games,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading games'),
            );
          }
          if (snapshot.hasError) {
            return _loadError(context);
          }

          final current = currentGames;
          final loaded = snapshot.data;
          List<Game> visibleGames;
          if (current != null) {
            visibleGames = current;
          } else if (loaded != null) {
            visibleGames = loaded;
          } else {
            visibleGames = <Game>[];
          }
          return GameLibraryContent(
            games: visibleGames,
            onAddGame: onAddGame,
            onLoadSamples: onLoadSamples,
            onOpenGame: (game) => onOpenGame(game),
          );
        },
      ),
    );
  }

  Widget _loadError(BuildContext context) {
    String message = 'Could not load games';
    if (hasSavedData) {
      message =
          'Could not read saved games. Your saved data was left unchanged.';
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
