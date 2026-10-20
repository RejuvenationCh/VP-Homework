import 'dart:convert';

import 'package:http/http.dart' as http;

import 'game_library_storage.dart';
import 'steam_api_parser.dart';

Future<bool> fillSteamGenres(GameLibraryStorage storage, String baseUrl) async {
  final games = await storage.loadGames();
  final ids = <String>{};
  for (final game in games) {
    final id = game.steamAppId;
    if (id != null &&
        (game.primaryGenre.trim().isEmpty || game.primaryGenre == 'Unsorted')) {
      ids.add(id);
    }
  }
  final pending = ids.toList();
  var complete = true;
  for (var start = 0; start < pending.length; start += 10) {
    var end = start + 10;
    if (end > pending.length) end = pending.length;
    final batch = pending.sublist(start, end);
    Map<String, String?> genres;
    try {
      genres = await _readGenres(baseUrl, batch);
    } catch (_) {
      complete = false;
      continue;
    }
    if (genres.values.any((genre) => genre == null)) complete = false;
    await storage.applySteamGenres(genres);
  }
  return complete;
}

Future<Map<String, String?>> _readGenres(
  String baseUrl,
  List<String> ids,
) async {
  final uri = Uri.parse('$baseUrl/v1/steam/games/genres')
      .replace(queryParameters: {'app_ids': ids.join(',')});
  final response = await http
      .get(uri, headers: {'Accept': 'application/json'})
      .timeout(const Duration(seconds: 20));
  if (response.statusCode != 200) {
    throw const SteamApiException('Steam genres are unavailable.');
  }
  final decoded = jsonDecode(response.body);
  if (decoded is! Map<String, dynamic> || decoded['games'] is! List) {
    throw const FormatException('Steam genres are invalid.');
  }
  final result = <String, String?>{};
  final rows = decoded['games'] as List;
  for (final row in rows) {
    if (row is! Map<String, dynamic>) {
      throw const FormatException('Steam genre entry is invalid.');
    }
    final id = row['app_id'];
    final genre = row['primary_genre'];
    if (!row.containsKey('primary_genre') ||
        id is! int ||
        !ids.contains(id.toString()) ||
        result.containsKey(id.toString()) ||
        (genre != null &&
            (genre is! String || genre.trim().isEmpty || genre.length > 80))) {
      throw const FormatException('Steam genre entry is invalid.');
    }
    result[id.toString()] = genre as String?;
  }
  if (result.length != ids.length) {
    throw const FormatException('Steam genres are incomplete.');
  }
  return result;
}
