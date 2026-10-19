import '../models/achievement.dart';
import '../models/game.dart';

const _sampleAchievements = [
  Achievement(
    id: 'first-session',
    name: 'First session',
    description: 'Complete a short play session.',
    progress: AchievementProgress.unlocked,
  ),
  Achievement(
    id: 'keep-exploring',
    name: 'Keep exploring',
    description: 'Discover more of the game.',
    progress: AchievementProgress.locked,
  ),
  Achievement(
    id: 'reach-a-milestone',
    name: 'Reach a milestone',
    progress: AchievementProgress.unknown,
  ),
];

List<Achievement> achievementsForGame(Game game) {
  if (game.isSample) {
    return _sampleAchievements;
  } else {
    return const <Achievement>[];
  }
}
