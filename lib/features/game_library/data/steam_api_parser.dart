import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/achievement.dart';
import '../models/steam_profile_target.dart';

class SteamApiException implements Exception {
  const SteamApiException(this.message);

  final String message;
}

bool isValidSteamId(String value) =>
    RegExp(r'^7656119[0-9]{10}$').hasMatch(value);

SteamProfileTarget parseSteamProfileResponse(
  http.Response response,
  String input,
) {
  final body = _decode(response);
  final steamId = body['steam_id'];
  final profileUrl = body['profile_url'];
  if (response.statusCode != 200 ||
      steamId is! String ||
      !isValidSteamId(steamId) ||
      profileUrl is! String) {
    throw _error(response.statusCode, body);
  }
  final uri = Uri.tryParse(profileUrl);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host != 'steamcommunity.com' ||
      !uri.path.startsWith('/profiles/$steamId')) {
    throw const SteamApiException('Steam returned an invalid profile.');
  }
  return SteamProfileTarget(
    steamId: steamId,
    profileUrl: profileUrl,
    input: input,
  );
}

SteamLibraryResult parseSteamGamesResponse(http.Response response) {
  final body = _decode(response);
  if (response.statusCode != 200) throw _error(response.statusCode, body);
  final status = body['status'];
  final source = body['games'];
  if ((status != 'available' && status != 'empty' && status != 'private') ||
      source is! List) {
    throw const SteamApiException('Steam game data is unavailable.');
  }
  final games = <SteamLibraryGame>[];
  final ids = <String>{};
  for (final item in source) {
    if (item is! Map<String, dynamic>) {
      throw const SteamApiException('Steam returned an invalid game list.');
    }
    final appId = item['app_id'];
    final name = item['name'];
    final playtime = item['playtime_forever_minutes'];
    if (appId is! int ||
        name is! String ||
        name.trim().isEmpty ||
        (playtime != null && playtime is! int)) {
      throw const SteamApiException('Steam returned an invalid game list.');
    }
    final id = appId.toString();
    if (!ids.add(id)) {
      throw const SteamApiException('Steam returned a duplicate game.');
    }
    games.add(
      SteamLibraryGame(
        appId: id,
        name: name,
        playtimeMinutes: playtime as int?,
      ),
    );
  }
  return SteamLibraryResult(status: status as String, games: games);
}

SteamAchievementsResult parseSteamAchievementsResponse(http.Response response) {
  final body = _decode(response);
  if (response.statusCode != 200) throw _error(response.statusCode, body);
  final status = body['status'];
  final source = body['achievements'];
  if ((status != 'available' &&
          status != 'progress_unavailable' &&
          status != 'no_achievements') ||
      source is! List) {
    throw const SteamApiException('Steam achievements are unavailable.');
  }
  final items = <SteamAchievementItem>[];
  for (final item in source) {
    if (item is! Map<String, dynamic>) {
      throw const SteamApiException('Steam returned invalid achievements.');
    }
    final id = item['achievement_id'];
    final name = item['display_name'];
    final description = item['description'];
    final icon = item['icon_url'];
    final unlocked = item['unlocked'];
    if (id is! String ||
        id.isEmpty ||
        name is! String ||
        (description != null && description is! String) ||
        (icon != null && icon is! String) ||
        (unlocked != null && unlocked is! bool)) {
      throw const SteamApiException('Steam returned invalid achievements.');
    }
    var descriptionText = '';
    if (description is String) descriptionText = description;
    items.add(
      SteamAchievementItem(
        id: id,
        name: name,
        description: descriptionText,
        iconUrl: _steamImageUrl(icon as String?),
        isUnlocked: unlocked as bool?,
      ),
    );
  }
  return SteamAchievementsResult(status: status as String, items: items);
}

String? _steamImageUrl(String? value) {
  if (value == null) return null;
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host != 'steamcdn-a.akamaihd.net' ||
      !uri.path.startsWith('/steamcommunity/public/images/apps/')) {
    return null;
  }
  return uri.toString();
}

Achievement toAchievement(SteamAchievementItem item) {
  AchievementProgress progress;
  if (item.isUnlocked == true) {
    progress = AchievementProgress.unlocked;
  } else if (item.isUnlocked == false) {
    progress = AchievementProgress.locked;
  } else {
    progress = AchievementProgress.unknown;
  }
  return Achievement(
    id: item.id,
    name: item.name,
    description: item.description,
    artworkUrl: item.iconUrl,
    progress: progress,
  );
}

Map<String, dynamic> _decode(http.Response response) {
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
  } on FormatException {
    throw const SteamApiException('Steam service returned an invalid reply.');
  }
  throw const SteamApiException('Steam service returned an invalid reply.');
}

SteamApiException _error(int status, Map<String, dynamic> body) {
  final error = body['error'];
  if (error == 'steam_api_not_configured') {
    return const SteamApiException('The local Steam service has no API key.');
  }
  if (status == 429) {
    return const SteamApiException('Too many requests. Try again shortly.');
  }
  if (error == 'profile_not_found') {
    return const SteamApiException('Steam profile was not found.');
  }
  return const SteamApiException('Steam service is unavailable. Try again.');
}
