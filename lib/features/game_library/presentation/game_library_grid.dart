import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_tile.dart';

class GameLibraryGrid extends StatelessWidget {
  const GameLibraryGrid({
    super.key,
    required this.games,
    required this.onOpenGame,
  });

  final List<Game> games;
  final ValueChanged<Game> onOpenGame;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          int columnCount;
          if (constraints.crossAxisExtent >= 600) {
            columnCount = 2;
          } else {
            columnCount = 1;
          }
          double childAspectRatio;
          if (columnCount == 1) {
            childAspectRatio = 1.35;
          } else {
            childAspectRatio = 1.7;
          }
          return SliverGrid.builder(
            itemCount: games.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) => GameTile(
              game: games[index],
              onTap: () => onOpenGame(games[index]),
            ),
          );
        },
      ),
    );
  }
}
