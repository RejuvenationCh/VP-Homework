import 'package:flutter/material.dart';

import '../../models/achievement.dart';

class AchievementProgressWidget extends StatelessWidget {
  const AchievementProgressWidget({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final current = achievement.currentProgress;
    final total = achievement.totalProgress;
    if (achievement.progress == AchievementProgress.unknown) {
      return Text(achievement.progress.label);
    } else if (current == null ||
        total == null ||
        total <= 0 ||
        current < 0 ||
        current > total) {
      return Text(achievement.progress.label);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${achievement.progress.label}: $current of $total',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          LinearProgressIndicator(value: current / total),
        ],
      );
    }
  }
}
