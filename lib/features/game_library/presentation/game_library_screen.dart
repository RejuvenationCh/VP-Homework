import 'package:flutter/material.dart';

import '../data/sample_games.dart';
import '../models/game.dart';

class GameLibraryScreen extends StatefulWidget {
  const GameLibraryScreen({super.key, this.loadGames = loadSampleGames});

  final Future<List<Game>> Function() loadGames;

  @override
  State<GameLibraryScreen> createState() => _GameLibraryScreenState();
}

class _GameLibraryScreenState extends State<GameLibraryScreen> {
  late Future<List<Game>> _games;

  @override
  void initState() {
    super.initState();
    _games = Future.sync(widget.loadGames);
  }

  @override
  void didUpdateWidget(GameLibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loadGames != widget.loadGames) {
      _games = Future.sync(widget.loadGames);
    }
  }

  void _retry() {
    setState(() {
      _games = Future.sync(widget.loadGames);
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

    final games = snapshot.data;
    if (games == null || games.isEmpty) {
      return const Center(child: Text('No games yet'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Sample library', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final game in games)
          ListTile(
            title: Text(game.name),
            subtitle: Text(
              'Genre: ${game.primaryGenre}\n'
              'Platform: ${game.platform}\n'
              'Personal status: ${game.status.label}',
            ),
          ),
      ],
    );
  }
}
