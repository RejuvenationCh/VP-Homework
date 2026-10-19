import 'package:flutter/material.dart';

import '../data/sample_games.dart';
import '../models/game.dart';
import 'add_game_dialog.dart';
import 'game_tile.dart';

class GameLibraryScreen extends StatefulWidget {
  const GameLibraryScreen({super.key, this.loadGames});

  final Future<List<Game>> Function()? loadGames;

  @override
  State<GameLibraryScreen> createState() => _GameLibraryScreenState();
}

class _GameLibraryScreenState extends State<GameLibraryScreen> {
  late Future<List<Game>> _games;
  int _nextManualId = 0;

  Future<List<Game>> _loadGames() {
    final loader = widget.loadGames;
    if (loader == null) {
      return Future.value(<Game>[]);
    } else {
      return Future.sync(loader).then((games) => List<Game>.of(games));
    }
  }

  @override
  void initState() {
    super.initState();
    _games = _loadGames();
  }

  @override
  void didUpdateWidget(GameLibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loadGames != widget.loadGames) {
      _games = _loadGames();
    }
  }

  void _retry() {
    setState(() {
      _games = _loadGames();
    });
  }

  Future<void> _addGame(List<Game> games) async {
    final activeLoad = _games;
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const AddGameDialog(),
    );
    if (!mounted || activeLoad != _games || title == null) {
      return;
    }
    setState(() {
      games.add(
        Game(
          id: 'manual-${_nextManualId++}',
          name: title,
          primaryGenre: 'Unsorted',
          platform: 'Unspecified',
          status: GameStatus.backlog,
        ),
      );
    });
  }

  void _loadSamples(List<Game> games) {
    setState(() {
      for (final sample in sampleGames) {
        if (!games.any((game) => game.id == sample.id)) {
          games.add(sample);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Backlog')),
      body: SafeArea(
        child: FutureBuilder<List<Game>>(
          future: _games,
          builder: (context, snapshot) => _buildLibrary(snapshot),
        ),
      ),
    );
  }

  Widget _buildLibrary(AsyncSnapshot<List<Game>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading games'),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load games'),
              const SizedBox(height: 8),
              FilledButton(onPressed: _retry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final loadedGames = snapshot.data;
    List<Game> games;
    if (loadedGames == null) {
      games = [];
    } else {
      games = loadedGames;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Library', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () => _addGame(games),
              child: const Text('Add game'),
            ),
            TextButton(
              onPressed: () => _loadSamples(games),
              child: const Text('Load sample games'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (games.isEmpty) const Text('No games yet'),
        for (final game in games) GameTile(game: game),
      ],
    );
  }
}
