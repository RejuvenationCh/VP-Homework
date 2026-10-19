import '../models/achievement.dart';
import '../models/achievement_record.dart';

Map<String, Object?> achievementRecordToJson(AchievementRecord record) {
  final achievement = record.achievement;
  return {
    'gameId': record.gameId,
    'achievementId': achievement.id,
    'name': achievement.name,
    'description': achievement.description,
    'artworkUrl': achievement.artworkUrl,
    'currentProgress': achievement.currentProgress,
    'totalProgress': achievement.totalProgress,
    'progress': achievement.progress.name,
    'isTracked': record.isTracked,
    'notes': record.notes,
  };
}

AchievementRecord achievementRecordFromJson(Map<String, dynamic> json) {
  final gameId = json['gameId'];
  final id = json['achievementId'];
  final name = json['name'];
  final description = json['description'];
  final artworkUrl = json['artworkUrl'];
  final currentProgress = json['currentProgress'];
  final totalProgress = json['totalProgress'];
  final progressName = json['progress'];
  final isTracked = json['isTracked'];
  final notes = json['notes'];

  if (gameId is! String ||
      id is! String ||
      name is! String ||
      description is! String ||
      (artworkUrl != null && artworkUrl is! String) ||
      (currentProgress != null && currentProgress is! int) ||
      (totalProgress != null && totalProgress is! int) ||
      progressName is! String ||
      isTracked is! bool ||
      notes is! String) {
    throw const FormatException('Saved achievement entry is invalid.');
  }

  AchievementProgress? progress;
  for (final value in AchievementProgress.values) {
    if (value.name == progressName) {
      progress = value;
    }
  }
  if (progress == null) {
    throw const FormatException('Saved achievement progress is invalid.');
  }

  final achievement = Achievement(
    id: id,
    name: name,
    description: description,
    artworkUrl: artworkUrl as String?,
    currentProgress: currentProgress as int?,
    totalProgress: totalProgress as int?,
    progress: progress,
  );
  return AchievementRecord(
    gameId: gameId,
    achievement: achievement,
    isTracked: isTracked,
    notes: notes,
  );
}
