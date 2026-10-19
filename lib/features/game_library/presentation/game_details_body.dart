import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_details_header.dart';
import 'game_details_info_card.dart';
import 'game_page_body.dart';

class GameDetailsBody extends StatelessWidget {
  const GameDetailsBody({
    super.key,
    required this.game,
    required this.isSaving,
    required this.onChanged,
    required this.onEditNotes,
    required this.achievements,
  });

  final Game game;
  final bool isSaving;
  final Future<bool> Function(Game) onChanged;
  final VoidCallback onEditNotes;
  final Widget achievements;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: GamePageBody(
      maxWidth: 1040,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final header = GameDetailsHeader(game: game);
            final controls = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GameDetailsInfoCard(
                  game: game,
                  isSaving: isSaving,
                  onChanged: onChanged,
                  onEditNotes: onEditNotes,
                ),
                achievements,
              ],
            );
            if (constraints.maxWidth >= 760) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: header),
                  const SizedBox(width: 32),
                  Expanded(flex: 5, child: controls),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [header, const SizedBox(height: 24), controls],
              );
            }
          },
        ),
      ),
    ),
  );
}
