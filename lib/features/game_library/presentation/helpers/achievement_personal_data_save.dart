import 'package:flutter/material.dart';

import '../../data/game_library_storage.dart';
import '../../models/achievement_record.dart';

Future<bool> saveAchievementPersonalData({
  required BuildContext context,
  required GameLibraryStorage? storage,
  required String gameId,
  required List<AchievementRecord> records,
  required Set<String> trackedAchievementIds,
  required Map<String, String> notesByAchievementId,
  required void Function(bool) onSavingChanged,
  required void Function(List<AchievementRecord>) onSaved,
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
          progressProfileId: record.progressProfileId,
        ),
      );
    }
    final saved = await storage.saveAchievementPersonalChanges(
      gameId,
      records,
      updatedRecords,
    );
    onSaved(saved);
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

void applySavedAchievementPersonalData(
  List<AchievementRecord> records,
  Set<String> tracked,
  Map<String, String> notes,
) {
  tracked.clear();
  notes.clear();
  for (final record in records) {
    final id = record.achievement.id;
    if (record.isTracked) tracked.add(id);
    notes[id] = record.notes;
  }
}
