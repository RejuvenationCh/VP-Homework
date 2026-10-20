import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/game.dart';
import '../models/steam_profile_target.dart';
import 'game_database.dart';
import 'game_json.dart';
import 'game_save_merge.dart';

class SqliteGameStore {
  const SqliteGameStore(this.database);

  final GameDatabase database;

  Future<List<Game>> load() async {
    final rows = await database
        .customSelect('SELECT payload FROM games ORDER BY position')
        .get();
    final games = <Game>[];
    for (final row in rows) {
      final decoded = jsonDecode(row.read<String>('payload'));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Saved game entry is invalid.');
      }
      games.add(gameFromJson(decoded));
    }
    return games;
  }

  Future<List<Game>> save(List<Game> games, {List<Game>? previous}) async {
    return database.transaction(() async {
      final existing = await load();
      var merged = games;
      if (previous != null) {
        merged = mergeGameChanges(existing, previous, games);
      }
      final keptIds = merged.map((game) => game.id).toSet();
      for (final game in existing) {
        if (!keptIds.contains(game.id) && game.steamAppId != null) {
          await database.customInsert(
            'INSERT OR IGNORE INTO hidden_steam_games (app_id) VALUES (?)',
            variables: [Variable.withString(game.steamAppId!)],
          );
        }
      }
      await _replace(merged);
      return merged;
    });
  }

  Future<void> importSteamGames(List<SteamLibraryGame> imported) async {
    await database.transaction(() async {
      final games = await load();
      final hiddenRows = await database
          .customSelect('SELECT app_id FROM hidden_steam_games')
          .get();
      final hiddenIds = <String>{};
      for (final row in hiddenRows) {
        hiddenIds.add(row.read<String>('app_id'));
      }
      for (final steamGame in imported) {
        if (hiddenIds.contains(steamGame.appId)) continue;
        var index = -1;
        for (var i = 0; i < games.length; i++) {
          if (games[i].steamAppId == steamGame.appId) index = i;
        }
        final previous = index < 0 ? null : games[index];
        final game = _mergeGame(previous, steamGame);
        if (index < 0) {
          games.add(game);
        } else {
          games[index] = game;
        }
      }
      await _replace(games);
    });
  }

  Future<void> _replace(List<Game> games) async {
    await database.customStatement('DELETE FROM games');
    for (var index = 0; index < games.length; index++) {
      final game = games[index];
      await database.customInsert(
        'INSERT INTO games (id, position, payload) VALUES (?, ?, ?)',
        variables: [
          Variable.withString(game.id),
          Variable.withInt(index),
          Variable.withString(jsonEncode(gameToJson(game))),
        ],
      );
    }
  }

  Game _mergeGame(Game? previous, SteamLibraryGame imported) {
    var id = 'steam-${imported.appId}';
    var name = imported.name;
    var genre = 'Unsorted';
    var platform = 'PC';
    var status = GameStatus.backlog;
    var favorite = false;
    var playNext = false;
    String? artwork;
    int? rating;
    var notes = '';
    if (previous != null) {
      id = previous.id;
      name = previous.name;
      genre = previous.primaryGenre;
      platform = previous.platform;
      status = previous.status;
      favorite = previous.isFavorite;
      playNext = previous.isPlayNext;
      artwork = previous.artworkUrl;
      rating = previous.rating;
      notes = previous.notes;
    }
    return Game(
      id: id,
      name: name,
      primaryGenre: genre,
      platform: platform,
      status: status,
      isSample: false,
      isFavorite: favorite,
      isPlayNext: playNext,
      artworkUrl: artwork,
      steamAppId: imported.appId,
      playtimeMinutes: imported.playtimeMinutes,
      rating: rating,
      notes: notes,
    );
  }
}
