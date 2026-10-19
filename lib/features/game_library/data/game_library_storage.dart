import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_json.dart';
import 'achievement_json.dart';
import '../models/achievement.dart';
import '../models/achievement_record.dart';
import '../models/game.dart';

class GameLibraryStorage {
  GameLibraryStorage() : _preferences = SharedPreferencesAsync();

  static const _storageKey = 'game_backlog.library.v1';
  static const _achievementStorageKey = 'game_backlog.achievements.v1';
  final SharedPreferencesAsync _preferences;

  Future<List<Game>> loadGames() async {
    final savedValue = await _preferences.getString(_storageKey);
    if (savedValue == null) {
      return <Game>[];
    }

    final decoded = jsonDecode(savedValue);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Saved game list is invalid.');
    }

    final games = <Game>[];
    final ids = <String>{};
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Saved game entry is invalid.');
      }
      final game = gameFromJson(item);
      if (!ids.add(game.id)) {
        throw const FormatException('Saved game IDs are duplicated.');
      }
      games.add(game);
    }
    return games;
  }

  Future<void> saveGames(List<Game> games) async {
    final encodedGames = <Map<String, Object?>>[];
    for (final game in games) {
      encodedGames.add(gameToJson(game));
    }
    await _preferences.setString(_storageKey, jsonEncode(encodedGames));
  }

  Future<List<AchievementRecord>> loadAchievements(
    String gameId,
    List<Achievement> definitions,
  ) async {
    final definitionIds = <String>{};
    for (final definition in definitions) {
      if (!definitionIds.add(definition.id)) {
        throw const FormatException('Achievement IDs are duplicated.');
      }
    }
    final saved = await _loadAchievementRecords();
    final existing = <String, AchievementRecord>{};
    for (final record in saved) {
      if (record.gameId == gameId) {
        existing[record.achievement.id] = record;
      }
    }
    final records = <AchievementRecord>[];
    var needsWrite = existing.isEmpty && definitions.isNotEmpty;
    for (final definition in definitions) {
      final savedRecord = existing.remove(definition.id);
      if (savedRecord == null) {
        needsWrite = true;
        records.add(AchievementRecord(gameId: gameId, achievement: definition));
      } else {
        records.add(
          AchievementRecord(
            gameId: gameId,
            achievement: savedRecord.achievement,
            isTracked: savedRecord.isTracked,
            notes: savedRecord.notes,
          ),
        );
      }
    }
    records.addAll(existing.values);
    if (needsWrite) {
      final otherGames = saved.where((record) => record.gameId != gameId);
      await _writeAchievementRecords([...otherGames, ...records]);
    }
    return records;
  }

  Future<void> saveAchievements(
    String gameId,
    List<AchievementRecord> records,
  ) async {
    final ids = <String>{};
    for (final record in records) {
      if (record.gameId != gameId || !ids.add(record.achievement.id)) {
        throw const FormatException('Achievement IDs are invalid.');
      }
    }
    final saved = await _loadAchievementRecords();
    final otherGames = saved.where((record) => record.gameId != gameId);
    await _writeAchievementRecords([...otherGames, ...records]);
  }

  Future<List<AchievementRecord>> _loadAchievementRecords() async {
    final savedValue = await _preferences.getString(_achievementStorageKey);
    if (savedValue == null) {
      return <AchievementRecord>[];
    }
    final decoded = jsonDecode(savedValue);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Saved achievement list is invalid.');
    }
    final records = <AchievementRecord>[];
    final idsByGame = <String, Set<String>>{};
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Saved achievement entry is invalid.');
      }
      final record = achievementRecordFromJson(item);
      var ids = idsByGame[record.gameId];
      if (ids == null) {
        ids = <String>{};
        idsByGame[record.gameId] = ids;
      }
      if (!ids.add(record.achievement.id)) {
        throw const FormatException('Saved achievement IDs are duplicated.');
      }
      records.add(record);
    }
    return records;
  }

  Future<void> _writeAchievementRecords(
    Iterable<AchievementRecord> records,
  ) async {
    final encoded = records.map(achievementRecordToJson).toList();
    await _preferences.setString(_achievementStorageKey, jsonEncode(encoded));
  }
}
