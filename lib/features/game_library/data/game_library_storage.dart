import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement.dart';
import '../models/achievement_record.dart';
import '../models/game.dart';
import '../models/steam_profile_target.dart';
import 'game_database.dart';
import 'legacy_data_migration.dart';
import 'sqlite_achievement_store.dart';
import 'sqlite_game_store.dart';
import 'steam_profile_store.dart';

class GameLibraryStorage {
  GameLibraryStorage()
    : _database = GameDatabase(),
      _preferences = SharedPreferencesAsync() {
    _games = SqliteGameStore(_database);
    _achievements = SqliteAchievementStore(_database);
    _steamProfile = SteamProfileStore(_database);
    _migration = LegacyDataMigration(
      database: _database,
      games: _games,
      achievements: _achievements,
      preferences: _preferences,
    );
  }

  final GameDatabase _database;
  final SharedPreferencesAsync _preferences;
  late final SqliteGameStore _games;
  late final SqliteAchievementStore _achievements;
  late final SteamProfileStore _steamProfile;
  late final LegacyDataMigration _migration;
  late final Future<void> _ready = _migration.run();

  Future<List<Game>> loadGames() async {
    await _ready;
    return _games.load();
  }

  Future<List<Game>> saveGames(List<Game> games, {List<Game>? previous}) async {
    await _ready;
    final saved = await _games.save(games, previous: previous);
    await _saveGameSnapshot(saved);
    return saved;
  }

  Future<String?> loadSteamServiceUrl() async {
    await _ready;
    final rows = await _database
        .customSelect(
          "SELECT value FROM settings WHERE key = 'steam_service_url'",
        )
        .get();
    if (rows.isEmpty) return null;
    return rows.first.read<String>('value');
  }

  Future<void> saveSteamServiceUrl(String? value) async {
    await _ready;
    if (value == null || value.trim().isEmpty) {
      await _database.customStatement(
        "DELETE FROM settings WHERE key = 'steam_service_url'",
      );
    } else {
      await _database.customInsert(
        'INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)',
        variables: [
          Variable.withString('steam_service_url'),
          Variable.withString(value.trim()),
        ],
      );
    }
  }

  Future<List<AchievementRecord>> saveAchievementPersonalChanges(
    String gameId,
    List<AchievementRecord> previous,
    List<AchievementRecord> updated,
  ) async {
    await _ready;
    final saved = await _achievements.savePersonalChanges(
      gameId,
      previous,
      updated,
    );
    await _saveAchievementSnapshot();
    return saved;
  }

  Future<void> importSteamGames(List<SteamLibraryGame> games) async {
    await _ready;
    await _games.importSteamGames(games);
    await _saveGameSnapshot(await _games.load());
  }

  Future<SteamProfileTarget?> loadSteamProfile() async {
    await _ready;
    return _steamProfile.load();
  }

  Future<void> saveSteamProfile(SteamProfileTarget profile) async {
    await _ready;
    await _steamProfile.save(profile);
  }

  Future<List<AchievementRecord>> loadAchievements(
    String gameId,
    List<Achievement> definitions, {
    bool preserveProgress = false,
    String? profileId,
  }) async {
    await _ready;
    final records = await _achievements.merge(
      gameId,
      definitions,
      preserveProgress: preserveProgress,
      profileId: profileId,
    );
    if (definitions.isNotEmpty) await _saveAchievementSnapshot();
    return records;
  }

  Future<List<AchievementRecord>> loadSavedAchievements(String gameId) async {
    await _ready;
    return _achievements.loadSaved(gameId);
  }

  Future<void> saveAchievements(
    String gameId,
    List<AchievementRecord> records,
  ) async {
    await _ready;
    await _achievements.save(gameId, records);
    await _saveAchievementSnapshot();
  }

  Future<void> _saveGameSnapshot(List<Game> games) async {
    try {
      await _migration.saveGameSnapshot(games);
    } catch (_) {}
  }

  Future<void> _saveAchievementSnapshot() async {
    try {
      final records = await _achievements.loadAll();
      await _migration.saveAchievementSnapshot(records);
    } catch (_) {}
  }
}
