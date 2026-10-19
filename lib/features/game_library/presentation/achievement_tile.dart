import 'package:flutter/material.dart';

import '../models/achievement.dart';
import 'achievement_artwork.dart';

class AchievementTile extends StatelessWidget {
  const AchievementTile({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: AchievementArtwork(imageUrl: achievement.artworkUrl),
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
}
