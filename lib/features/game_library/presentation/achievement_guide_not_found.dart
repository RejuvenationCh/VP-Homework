import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../models/game.dart';

class AchievementGuideNotFound extends StatelessWidget {
  const AchievementGuideNotFound({
    super.key,
    required this.game,
    required this.achievement,
  });

  final Game game;
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guide search')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('404', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 12),
              Text(
                'No matching guide appeared in the first 30 results for ${achievement.name} in ${game.name}.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to achievements'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
