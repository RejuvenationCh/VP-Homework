import 'package:flutter/material.dart';

import '../../models/game.dart';
import './game_artwork.dart';

class GameDetailsHeader extends StatelessWidget {
  const GameDetailsHeader({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: GameArtwork(
            imageUrl: game.resolvedArtworkUrl,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        const SizedBox(height: 20),
        Text(game.name, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text(game.primaryGenre)),
            Chip(label: Text(game.platform)),
            if (game.isSample) const Chip(label: Text('Sample')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.schedule_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Playtime: ${_playtime()}',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _playtime() {
    final minutes = game.playtimeMinutes;
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
