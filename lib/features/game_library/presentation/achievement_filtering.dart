import '../models/achievement.dart';
import '../models/achievement_record.dart';
import 'achievement_progress_filter.dart';

List<AchievementRecord> filterAchievementRecords({
  required List<AchievementRecord> records,
  required String query,
  required AchievementProgressFilter progressFilter,
  required Set<String> trackedAchievementIds,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  return records.where((record) {
    final achievement = record.achievement;
    if (progressFilter == AchievementProgressFilter.tracked) {
      if (!trackedAchievementIds.contains(achievement.id)) {
        return false;
      }
    } else if (progressFilter == AchievementProgressFilter.unlocked) {
      if (achievement.progress != AchievementProgress.unlocked) {
        return false;
      }
    } else if (progressFilter == AchievementProgressFilter.locked) {
      if (achievement.progress != AchievementProgress.locked) {
        return false;
      }
    }
    if (normalizedQuery.isEmpty) {
      return true;
    } else {
      final name = achievement.name.toLowerCase();
      final description = achievement.description.toLowerCase();
      if (name.contains(normalizedQuery) ||
          description.contains(normalizedQuery)) {
        return true;
      } else {
        return false;
      }
    }
  }).toList();
}
