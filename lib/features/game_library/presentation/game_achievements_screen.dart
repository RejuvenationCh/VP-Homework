import 'package:flutter/material.dart';

import '../data/sample_achievements.dart';
import '../models/achievement.dart';
import '../models/game.dart';

class GameAchievementsEntry extends StatelessWidget {
  const GameAchievementsEntry({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => GameAchievementsScreen(game: game),
          ),
        ),
        icon: const Icon(Icons.emoji_events_outlined),
        label: const Text('View achievements'),
      ),
    );
  }
}

class GameAchievementsScreen extends StatelessWidget {
  const GameAchievementsScreen({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final achievements = achievementsForGame(game);
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(game.name, style: Theme.of(context).textTheme.titleLarge),
            const Align(
              alignment: Alignment.centerLeft,
              child: Chip(label: Text('Sample data')),
            ),
            for (final achievement in achievements)
              _achievementTile(context, achievement),
          ],
        ),
      ),
    );
  }

  Widget _achievementTile(BuildContext context, Achievement achievement) {
    return Card(
      child: ListTile(
        leading: Icon(_progressIcon(achievement.progress)),
        title: Text(achievement.name),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (achievement.description.isNotEmpty)
              Text(achievement.description),
            Text(
              achievement.progress.label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }

  IconData _progressIcon(AchievementProgress progress) {
    if (progress == AchievementProgress.unlocked) {
      return Icons.check_circle_outline;
    } else if (progress == AchievementProgress.locked) {
      return Icons.lock_outline;
    } else {
      return Icons.help_outline;
    }
  }
}
