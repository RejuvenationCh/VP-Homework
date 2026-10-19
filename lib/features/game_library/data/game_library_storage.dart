import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game.dart';

class GameLibraryStorage {
  GameLibraryStorage() : _preferences = SharedPreferencesAsync();

  static const _storageKey = 'game_backlog.library.v1';
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
      final game = Game.fromJson(item);
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
      encodedGames.add(game.toJson());
    }
    await _preferences.setString(_storageKey, jsonEncode(encodedGames));
  }
}
