import 'package:flutter/material.dart';

import '../../media_cleaner/presentation/storage_overview_screen.dart';
import '../data/sample_games.dart';

class GameLibraryScreen extends StatelessWidget {
  const GameLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Backlog'),
        actions: [
          IconButton(
            tooltip: 'Previous media screens',
            icon: const Icon(Icons.folder_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const StorageOverviewScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Sample library',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final game in sampleGames)
              ListTile(
                title: Text(game.name),
                subtitle: Text(
                  'Genre: ${game.primaryGenre}\n'
                  'Platform: ${game.platform}\n'
                  'Personal status: ${game.status.label}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
