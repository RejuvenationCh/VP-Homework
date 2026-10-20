import '../models/achievement_record.dart';

List<AchievementRecord> mergeAchievementPersonalChanges(
  List<AchievementRecord> current,
  List<AchievementRecord> previous,
  List<AchievementRecord> updated,
) {
  final before = {for (final item in previous) item.achievement.id: item};
  final after = {for (final item in updated) item.achievement.id: item};
  final saved = {for (final item in current) item.achievement.id: item};
  for (final entry in after.entries) {
    final old = before[entry.key];
    final latest = saved[entry.key];
    final next = entry.value;
    if (old == null) throw StateError('Achievement baseline is missing.');
    if (next.notes == old.notes && next.isTracked == old.isTracked) continue;
    if (latest == null) throw StateError('Achievement was removed. Reload it.');
    var notes = latest.notes;
    var tracked = latest.isTracked;
    if (next.notes != old.notes) {
      if (notes != old.notes && notes != next.notes) {
        throw StateError('Achievement notes changed. Reload before saving.');
      }
      notes = next.notes;
    }
    if (next.isTracked != old.isTracked) {
      if (tracked != old.isTracked && tracked != next.isTracked) {
        throw StateError('Achievement tracking changed. Reload before saving.');
      }
      tracked = next.isTracked;
    }
    saved[entry.key] = AchievementRecord(
      gameId: latest.gameId,
      achievement: latest.achievement,
      progressProfileId: latest.progressProfileId,
      notes: notes,
      isTracked: tracked,
    );
  }
  return saved.values.toList();
}
