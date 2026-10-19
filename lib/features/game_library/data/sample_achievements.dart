import '../models/achievement.dart';
import '../models/game.dart';

const _sampleAchievements = [
  Achievement(
    id: 'first-session',
    name: 'First session',
    description: 'Complete a short play session.',
    currentProgress: 1,
    totalProgress: 1,
    progress: AchievementProgress.unlocked,
  ),
  Achievement(
    id: 'keep-exploring',
    name: 'Keep exploring',
    description: 'Discover more of the game.',
    currentProgress: 2,
    totalProgress: 5,
    progress: AchievementProgress.locked,
  ),
  Achievement(
    id: 'reach-a-milestone',
    name: 'Reach a milestone',
    progress: AchievementProgress.unknown,
  ),
];

const _terrariaSampleAchievements = [
  Achievement(
    id: 'terraria-timber',
    name: 'Timber!!',
    description: 'Cut down a tree for the first time.',
    currentProgress: 1,
    totalProgress: 1,
    progress: AchievementProgress.unlocked,
  ),
  Achievement(
    id: 'terraria-no-hobo',
    name: 'No Hobo',
    description: 'Build a valid home so a town NPC can move in.',
    progress: AchievementProgress.locked,
  ),
  Achievement(
    id: 'terraria-eye-on-you',
    name: 'Eye on You',
    description: 'Defeat the Eye of Cthulhu after nightfall.',
    progress: AchievementProgress.locked,
  ),
];

List<Achievement> achievementsForGame(Game game) {
  if (game.isSample) {
    if (game.steamAppId == '105600') {
      return _terrariaSampleAchievements;
    } else {
      return _sampleAchievements;
    }
  } else {
    return const <Achievement>[];
  }
}
