import 'achievement.dart';

class AchievementRecord {
  const AchievementRecord({
    required this.gameId,
    required this.achievement,
    this.isTracked = false,
    this.notes = '',
    this.progressProfileId,
  });

  final String gameId;
  final Achievement achievement;
  final bool isTracked;
  final String notes;
  final String? progressProfileId;
}
