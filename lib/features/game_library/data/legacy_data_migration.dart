import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement_record.dart';
import '../models/game.dart';
import 'achievement_json.dart';
import 'game_database.dart';
import 'game_json.dart';
import 'sqlite_achievement_store.dart';
import 'sqlite_game_store.dart';

class LegacyDataMigration {
  const LegacyDataMigration({
    required this.database,
    required this.games,
    required this.achievements,
    required this.preferences,
  });

  static const _gameKey = 'game_backlog.library.v1';
  static const _achievementKey = 'game_backlog.achievements.v1';
  static const _migrationKey = 'legacy_data_migrated';

  final GameDatabase database;
  final SqliteGameStore games;
  final SqliteAchievementStore achievements;
  final SharedPreferencesAsync preferences;

  Future<void> saveGameSnapshot(List<Game> games) async {
    final encoded = games.map(gameToJson).toList();
    await preferences.setString(_gameKey, jsonEncode(encoded));
  }

  Future<void> saveAchievementSnapshot(List<AchievementRecord> records) async {
    final encoded = records.map(achievementRecordToJson).toList();
    await preferences.setString(_achievementKey, jsonEncode(encoded));
  }

  Future<void> run() async {
    await database.customSelect('SELECT 1').get();
    final completed = await database
        .customSelect("SELECT value FROM settings WHERE key = '$_migrationKey'")
        .get();
    if (completed.isNotEmpty) return;
    final gameSnapshot = await preferences.getString(_gameKey);
    final achievementSnapshot = await preferences.getString(_achievementKey);
    await database.transaction(() async {
      // Take the write lock before another tab starts the migration
      await database.customStatement(
        'UPDATE settings SET value = value WHERE key = ?',
        [_migrationKey],
      );
      final rows = await database
          .customSelect(
            "SELECT value FROM settings WHERE key = '$_migrationKey'",
          )
          .get();
      if (rows.isNotEmpty) return;
      final savedGames = _readGames(gameSnapshot);
      final savedAchievements = _readAchievements(achievementSnapshot);
      if (savedGames.isNotEmpty) await games.save(savedGames);
      final byGame = <String, List<AchievementRecord>>{};
      for (final record in savedAchievements) {
        byGame
            .putIfAbsent(record.gameId, () => <AchievementRecord>[])
            .add(record);
      }
      for (final entry in byGame.entries) {
        await achievements.save(entry.key, entry.value);
      }
      await database.customInsert(
        'INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)',
        variables: [
          Variable.withString(_migrationKey),
          Variable.withString('complete'),
        ],
      );
    });
  }

  List<Game> _readGames(String? value) {
    if (value == null) return <Game>[];
    final decoded = jsonDecode(value);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Saved game list is invalid.');
    }
    final result = <Game>[];
    final ids = <String>{};
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Saved game entry is invalid.');
      }
      final game = gameFromJson(item);
      if (!ids.add(game.id)) {
        throw const FormatException('Saved game IDs are duplicated.');
      }
      result.add(game);
    }
    return result;
  }

  List<AchievementRecord> _readAchievements(String? value) {
    if (value == null) return <AchievementRecord>[];
    final decoded = jsonDecode(value);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Saved achievement list is invalid.');
    }
    final result = <AchievementRecord>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Saved achievement entry is invalid.');
      }
      result.add(achievementRecordFromJson(item));
    }
    return result;
  }
}
