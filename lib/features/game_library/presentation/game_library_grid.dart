import 'package:flutter/material.dart';

import '../../../dev/constraint_scenario.dart';
import '../models/game.dart';
import 'game_tile.dart';

class GameLibraryGrid extends StatelessWidget {
  const GameLibraryGrid({
    super.key,
    required this.games,
    required this.onOpenGame,
    this.h2Preview,
  });

  final List<Game> games;
  final ValueChanged<Game> onOpenGame;
  final GameConstraintPreview? h2Preview;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    sliver: SliverLayoutBuilder(
      builder: (context, constraints) {
        var columns = 1;
        if (constraints.crossAxisExtent >= 960) {
          columns = 4;
        } else if (constraints.crossAxisExtent >= 650) {
          columns = 3;
        } else if (constraints.crossAxisExtent >= 360) {
          columns = 2;
        }
        final width =
            (constraints.crossAxisExtent - (columns - 1) * 16) / columns;
        var height =
            width * 9 / 16 + MediaQuery.textScalerOf(context).scale(132) + 8;
        final preview = h2Preview;
        var longName = false;
        if (preview != null && preview.showError) {
          if (preview.type == GameConstraintCase.shortTile) {
            height = 64;
          } else if (preview.type == GameConstraintCase.longName) {
            longName = true;
          }
        }
        return SliverGrid.builder(
          itemCount: games.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: height,
          ),
          itemBuilder: (context, index) => GameTile(
            game: games[index],
            showNameOverflow: longName,
            onTap: () => onOpenGame(games[index]),
          ),
        );
      },
    ),
  );
}
