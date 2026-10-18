import 'package:flutter/material.dart';

import '../features/game_library/data/sample_games.dart';
import '../features/game_library/models/game.dart';
import '../features/game_library/presentation/game_library_screen.dart';

class LibraryRetryDemo extends StatefulWidget {
  const LibraryRetryDemo({super.key});

  @override
  State<LibraryRetryDemo> createState() => _LibraryRetryDemoState();
}

class _LibraryRetryDemoState extends State<LibraryRetryDemo> {
  bool _failedOnce = false;

  Future<List<Game>> _loadGames() async {
    if (!_failedOnce) {
      _failedOnce = true;
      throw StateError('Demo load failed');
    } else {
      return loadSampleGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameLibraryScreen(loadGames: _loadGames);
  }
}
