import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import '../models/achievement_record.dart';

Future<bool> saveAchievementPersonalData({
  required BuildContext context,
  required GameLibraryStorage? storage,
  required String gameId,
  required List<AchievementRecord> records,
  required Set<String> trackedAchievementIds,
  required Map<String, String> notesByAchievementId,
  required void Function(bool) onSavingChanged,
}) async {
  if (storage == null) return true;
  onSavingChanged(true);
  try {
    final updatedRecords = <AchievementRecord>[];
    for (final record in records) {
      final achievementId = record.achievement.id;
      var notes = '';
      if (notesByAchievementId.containsKey(achievementId)) {
        notes = notesByAchievementId[achievementId]!;
      }
      updatedRecords.add(
        AchievementRecord(
          gameId: gameId,
          achievement: record.achievement,
          isTracked: trackedAchievementIds.contains(achievementId),
          notes: notes,
        ),
      );
    }
    await storage.saveAchievements(gameId, updatedRecords);
    return true;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save achievement data.')),
      );
    }
    return false;
  } finally {
    onSavingChanged(false);
  }
}
