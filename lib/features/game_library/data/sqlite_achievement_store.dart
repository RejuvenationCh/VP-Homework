import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/achievement.dart';
import '../models/achievement_record.dart';
import 'achievement_json.dart';
import 'achievement_personal_merge.dart';
import 'game_database.dart';

class SqliteAchievementStore {
  const SqliteAchievementStore(this.database);

  final GameDatabase database;

  Future<List<AchievementRecord>> loadAll() async {
    final rows = await database
        .customSelect(
          'SELECT payload FROM achievements ORDER BY game_id, achievement_id',
        )
        .get();
    final records = <AchievementRecord>[];
    for (final row in rows) {
      final decoded = jsonDecode(row.read<String>('payload'));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Saved achievement entry is invalid.');
      }
      records.add(achievementRecordFromJson(decoded));
    }
    return records;
  }

  Future<List<AchievementRecord>> loadSaved(String gameId) async {
    final rows = await database
        .customSelect(
          'SELECT payload FROM achievements WHERE game_id = ? ORDER BY achievement_id',
          variables: [Variable.withString(gameId)],
        )
        .get();
    final records = <AchievementRecord>[];
    for (final row in rows) {
      final decoded = jsonDecode(row.read<String>('payload'));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Saved achievement entry is invalid.');
      }
      records.add(achievementRecordFromJson(decoded));
    }
    return records;
  }

  Future<List<AchievementRecord>> merge(
    String gameId,
    List<Achievement> definitions, {
    bool preserveProgress = false,
    String? profileId,
  }) async {
    return database.transaction(
      () => _mergeDefinitions(
        gameId,
        definitions,
        preserveProgress: preserveProgress,
        profileId: profileId,
      ),
    );
  }

  Future<List<AchievementRecord>> savePersonalChanges(
    String gameId,
    List<AchievementRecord> previous,
    List<AchievementRecord> updated,
  ) async {
    return database.transaction(() async {
      final saved = mergeAchievementPersonalChanges(
        await loadSaved(gameId),
        previous,
        updated,
      );
      await save(gameId, saved);
      return saved;
    });
  }

  Future<List<AchievementRecord>> _mergeDefinitions(
    String gameId,
    List<Achievement> definitions, {
    required bool preserveProgress,
    String? profileId,
  }) async {
    final ids = <String>{};
    for (final definition in definitions) {
      if (!ids.add(definition.id)) {
        throw const FormatException('Achievement IDs are duplicated.');
      }
    }
    final saved = await loadSaved(gameId);
    final existing = <String, AchievementRecord>{};
    for (final record in saved) {
      existing[record.achievement.id] = record;
    }
    final records = <AchievementRecord>[];
    for (final definition in definitions) {
      final previous = existing.remove(definition.id);
      if (previous == null) {
        records.add(
          AchievementRecord(
            gameId: gameId,
            achievement: definition,
            progressProfileId: profileId,
          ),
        );
      } else {
        var achievement = definition;
        if (preserveProgress &&
            previous.progressProfileId == profileId &&
            definition.progress == AchievementProgress.unknown) {
          achievement = Achievement(
            id: definition.id,
            name: definition.name,
            description: definition.description,
            artworkUrl: definition.artworkUrl,
            currentProgress: previous.achievement.currentProgress,
            totalProgress: previous.achievement.totalProgress,
            progress: previous.achievement.progress,
          );
        }
        records.add(
          AchievementRecord(
            gameId: gameId,
            achievement: achievement,
            isTracked: previous.isTracked,
            notes: previous.notes,
            progressProfileId: profileId,
          ),
        );
      }
    }
    records.addAll(existing.values);
    if (definitions.isNotEmpty) await save(gameId, records);
    return records;
  }

  Future<void> save(String gameId, List<AchievementRecord> records) async {
    final ids = <String>{};
    for (final record in records) {
      if (record.gameId != gameId || !ids.add(record.achievement.id)) {
        throw const FormatException('Achievement IDs are invalid.');
      }
    }
    await database.transaction(() async {
      await database.customUpdate(
        'DELETE FROM achievements WHERE game_id = ?',
        variables: [Variable.withString(gameId)],
      );
      for (final record in records) {
        await database.customInsert(
          'INSERT INTO achievements (game_id, achievement_id, payload) VALUES (?, ?, ?)',
          variables: [
            Variable.withString(gameId),
            Variable.withString(record.achievement.id),
            Variable.withString(jsonEncode(achievementRecordToJson(record))),
          ],
        );
      }
    });
  }
}
