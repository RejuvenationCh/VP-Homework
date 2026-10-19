import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_artwork.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GameArtwork(imageUrl: game.artworkUrl),
              ),
              const SizedBox(height: 16),
              Text(game.name, style: Theme.of(context).textTheme.headlineSmall),
              if (game.isSample) ...[
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(label: Text('Sample')),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _metadata(context, 'Genre', game.primaryGenre),
                      _metadata(context, 'Platform', game.platform),
                      _metadata(
                        context,
                        'Playtime',
                        _formatPlaytime(game.playtimeMinutes),
                      ),
                      _metadata(context, 'Personal status', game.status.label),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metadata(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  String _formatPlaytime(int? minutes) {
    if (minutes == null || minutes < 0) {
      return 'Unknown';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (hours == 0) {
        return '$minutes min';
      } else if (remainingMinutes == 0) {
        return '$hours hr';
      } else {
        return '$hours hr $remainingMinutes min';
      }
    }
  }
}
