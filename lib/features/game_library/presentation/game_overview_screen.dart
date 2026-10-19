import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import '../models/game.dart';
import 'game_overview_content.dart';
import 'game_library_empty_state.dart';
import 'game_page_body.dart';

class GameOverviewScreen extends StatefulWidget {
  const GameOverviewScreen({
    super.key,
    this.storage,
    this.loadGames,
    required this.refreshKey,
    required this.onGenreSelected,
    required this.onGameSelected,
    this.onOpenLibrary,
  });

  final GameLibraryStorage? storage;
  final Future<List<Game>> Function()? loadGames;
  final int refreshKey;
  final ValueChanged<String> onGenreSelected;
  final ValueChanged<Game> onGameSelected;
  final VoidCallback? onOpenLibrary;

  @override
  State<GameOverviewScreen> createState() => GameOverviewScreenState();
}

class GameOverviewScreenState extends State<GameOverviewScreen> {
  late Future<List<Game>> _games;

  @override
  void initState() {
    super.initState();
    _games = _loadGames();
  }

  @override
  void didUpdateWidget(GameOverviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey ||
        oldWidget.storage != widget.storage ||
        oldWidget.loadGames != widget.loadGames) {
      _games = _loadGames();
    }
  }

  void reload() {
    setState(() {
      _games = _loadGames();
    });
  }

  Future<List<Game>> _loadGames() {
    final loader = widget.loadGames;
    if (loader != null) {
      return Future<List<Game>>.sync(loader);
    }
    final storage = widget.storage;
    if (storage != null) {
      return storage.loadGames();
    } else {
      return Future<List<Game>>.value(<Game>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overview')),
      body: SafeArea(
        child: GamePageBody(
          child: FutureBuilder<List<Game>>(
            future: _games,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _loadError();
              }
              final games = snapshot.data;
              if (games == null || games.isEmpty) {
                return _emptyOverview();
              } else {
                return GameOverviewContent(
                  games: games,
                  onGenreSelected: widget.onGenreSelected,
                  onGameSelected: widget.onGameSelected,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _loadError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Could not load games'),
          TextButton(onPressed: reload, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _emptyOverview() => GameLibraryEmptyState(
    icon: Icons.videogame_asset_outlined,
    message: 'Your library is empty',
    actions: [
      if (widget.onOpenLibrary != null)
        FilledButton.icon(
          onPressed: widget.onOpenLibrary,
          icon: const Icon(Icons.add),
          label: const Text('Open Library'),
        ),
    ],
  );
}
