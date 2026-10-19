import 'package:flutter/material.dart';

import '../models/game.dart';

class AchievementListHeader extends StatelessWidget {
  const AchievementListHeader({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(game.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          game.isSample ? 'Sample data' : 'Steam profile data',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
