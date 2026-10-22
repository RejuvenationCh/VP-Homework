import 'package:flutter/material.dart';

import '../features/game_library/data/game_library_storage.dart';
import '../features/game_library/data/sample_games.dart';
import '../features/game_library/models/achievement.dart';
import '../features/game_library/presentation/screens/game_achievements_screen.dart';

enum AchievementDemoData {
  current('Current data'),
  longText('Long text'),
  empty('Empty'),
  big('500 achievements'),
  unavailable('Unavailable progress');

  const AchievementDemoData(this.label);
  final String label;

  Widget screen(GameLibraryStorage? storage) => GameAchievementsScreen(
    game: sampleGames.first,
    storage: this == AchievementDemoData.current ? storage : null,
    fixtureAchievements: achievements,
  );

  List<Achievement>? get achievements {
    if (this == AchievementDemoData.current) {
      return null;
    } else if (this == AchievementDemoData.longText) {
      return [
        Achievement(
          id: 'fixture-long-text',
          name: List.filled(30, 'Long name').join(' '),
          description: List.filled(50, 'Long description').join(' '),
          progress: AchievementProgress.locked,
        ),
      ];
    } else if (this == AchievementDemoData.empty) {
      return <Achievement>[];
    } else if (this == AchievementDemoData.big) {
      return List<Achievement>.generate(500, (index) {
        return Achievement(
          id: 'fixture-achievement-$index',
          name: 'Achievement ${index + 1}',
          description: 'Fixture achievement description ${index + 1}.',
          currentProgress: index % 10,
          totalProgress: 10,
          progress: AchievementProgress.locked,
        );
      });
    } else {
      return List<Achievement>.generate(5, (index) {
        return Achievement(
          id: 'fixture-unavailable-$index',
          name: 'Unavailable progress ${index + 1}',
          progress: AchievementProgress.unknown,
        );
      });
    }
  }
}
