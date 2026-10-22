import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../screens/game_form_screen.dart';

Future<void> openNewLibraryGame(
  BuildContext context,
  String id,
  Future<bool> Function(Game) onSave,
) => Navigator.of(context).push<void>(
  MaterialPageRoute<void>(
    builder: (context) => GameFormScreen(
      game: Game(
        id: id,
        name: '',
        primaryGenre: 'Unsorted',
        platform: 'Unspecified',
        status: GameStatus.backlog,
      ),
      isNew: true,
      onSave: onSave,
    ),
  ),
);

Future<Game?> openLibraryGameEditor(
  BuildContext context,
  Game game,
  Future<bool> Function(Game) onSave,
) => Navigator.of(context).push<Game>(
  MaterialPageRoute<Game>(
    builder: (context) =>
        GameFormScreen(game: game, isNew: false, onSave: onSave),
  ),
);
