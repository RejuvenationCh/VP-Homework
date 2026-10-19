import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import '../models/game.dart';

class GameOverviewScreen extends StatefulWidget {
  const GameOverviewScreen({
    super.key,
    required this.storage,
    required this.refreshKey,
  });

  final GameLibraryStorage storage;
  final int refreshKey;

  @override
  State<GameOverviewScreen> createState() => _GameOverviewScreenState();
}

class _GameOverviewScreenState extends State<GameOverviewScreen> {
  late Future<List<Game>> _games;

  @override
  void initState() {
    super.initState();
    _games = widget.storage.loadGames();
  }

  @override
  void didUpdateWidget(GameOverviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey ||
        oldWidget.storage != widget.storage) {
      _games = widget.storage.loadGames();
    }
  }

  void _retry() {
    setState(() => _games = widget.storage.loadGames());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overview')),
      body: SafeArea(
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
              return const Center(child: Text('No games yet'));
            } else {
              return _genreList(context, games);
            }
          },
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
          TextButton(onPressed: _retry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _genreList(BuildContext context, List<Game> games) {
    final counts = <String, int>{};
    for (final game in games) {
      String genre;
      if (game.primaryGenre.trim().isEmpty) {
        genre = 'Unsorted';
      } else {
        genre = game.primaryGenre.trim();
      }
      final count = counts[genre];
      if (count == null) {
        counts[genre] = 1;
      } else {
        counts[genre] = count + 1;
      }
    }
    final genres = counts.keys.toList()..sort();
    final bubbles = <Widget>[];
    final colors = Theme.of(context).colorScheme;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width - 64;
    for (final genre in genres) {
      final count = counts[genre];
      if (count != null) {
        bubbles.add(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    child: Text('$count'),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text(genre, softWrap: true)),
                ],
              ),
            ),
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Primary genres',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(spacing: 8, runSpacing: 4, children: bubbles),
        ),
      ],
    );
  }
}
