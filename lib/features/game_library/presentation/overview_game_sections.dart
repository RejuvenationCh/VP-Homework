import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_tile.dart';

class OverviewGameSections extends StatelessWidget {
  const OverviewGameSections({
    super.key,
    required this.games,
    required this.onGameSelected,
  });

  final List<Game> games;
  final ValueChanged<Game> onGameSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(context, 'Play next'),
        _playNextCard(),
        _sectionTitle(context, 'Currently playing'),
        ..._playingTiles(),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _playNextCard() {
    Game? pinnedGame;
    for (final game in games) {
      if (game.isPlayNext) {
        pinnedGame = game;
        break;
      }
    }
    if (pinnedGame == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('No game pinned for next'),
      );
    } else {
      return Card(
        child: GameTile(
          game: pinnedGame,
          onTap: () => onGameSelected(pinnedGame!),
        ),
      );
    }
  }

  List<Widget> _playingTiles() {
    final playingGames = games
        .where((game) => game.status == GameStatus.playing)
        .toList();
    if (playingGames.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('No games currently playing'),
        ),
      ];
    } else {
      return [
        for (final game in playingGames)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GameTile(game: game, onTap: () => onGameSelected(game)),
          ),
      ];
    }
  }
}
