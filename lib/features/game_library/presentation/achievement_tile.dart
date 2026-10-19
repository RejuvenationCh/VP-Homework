import 'package:flutter/material.dart';

import '../models/achievement.dart';
import 'achievement_artwork.dart';
import 'achievement_progress_widget.dart';

class AchievementTile extends StatelessWidget {
  const AchievementTile({
    super.key,
    required this.achievement,
    required this.isTracked,
    required this.onTrackChanged,
  });

  final Achievement achievement;
  final bool isTracked;
  final VoidCallback onTrackChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: AchievementArtwork(imageUrl: achievement.artworkUrl),
        title: Text(achievement.name),
        trailing: IconButton(
          tooltip: isTracked ? 'Untrack achievement' : 'Track achievement',
          onPressed: onTrackChanged,
          icon: Icon(isTracked ? Icons.bookmark : Icons.bookmark_border),
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (achievement.description.isNotEmpty)
              Text(achievement.description),
            AchievementProgressWidget(achievement: achievement),
          ],
        ),
      ),
    );
  }
}
