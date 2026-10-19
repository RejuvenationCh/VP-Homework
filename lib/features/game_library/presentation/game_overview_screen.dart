import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import '../models/game.dart';
import 'genre_bubble_map.dart';
import 'overview_library_summary.dart';
import 'overview_game_sections.dart';

class GameOverviewScreen extends StatefulWidget {
  const GameOverviewScreen({
    super.key,
    required this.storage,
    required this.refreshKey,
    required this.onGenreSelected,
    required this.onGameSelected,
  });

  final GameLibraryStorage storage;
  final int refreshKey;
  final ValueChanged<String> onGenreSelected;
  final ValueChanged<Game> onGameSelected;

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
              return _emptyOverview();
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

  Widget _emptyOverview() {
    return const CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(child: OverviewLibrarySummary(games: [])),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('No games yet')),
        ),
      ],
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OverviewLibrarySummary(games: games),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Primary genres',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GenreBubbleMap(
            counts: counts,
            onSelected: widget.onGenreSelected,
          ),
        ),
        OverviewGameSections(
          games: games,
          onGameSelected: widget.onGameSelected,
        ),
      ],
    );
  }
}
