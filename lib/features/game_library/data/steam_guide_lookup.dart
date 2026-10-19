import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game.dart';

const _apiBaseUrl = String.fromEnvironment(
  'STEAM_GUIDE_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8787',
);

class SteamGuideLookupException implements Exception {
  const SteamGuideLookupException();
}

Future<Uri?> findAchievementGuide({
  required Game game,
  required String achievementName,
}) async {
  final appId = game.steamAppId;
  if (appId == null || !RegExp(r'^[1-9][0-9]{0,9}$').hasMatch(appId)) {
    throw const SteamGuideLookupException();
  }
  final searchText = achievementName.trim();
  if (searchText.isEmpty || searchText.length > 120) {
    throw const SteamGuideLookupException();
  }

  final requestUri = Uri.parse(_apiBaseUrl).replace(
    path: '/v1/steam/guides',
    queryParameters: {'app_id': appId, 'search_text': searchText},
  );
  final response = await http
      .get(requestUri, headers: {'Accept': 'application/json'})
      .timeout(const Duration(seconds: 15));
  Object? decoded;
  try {
    decoded = jsonDecode(response.body);
  } on FormatException {
    throw const SteamGuideLookupException();
  }

  if (response.statusCode == 404) {
    if (decoded is Map && decoded['error'] == 'guide_not_found') {
      return null;
    } else {
      throw const SteamGuideLookupException();
    }
  }
  if (response.statusCode != 200 || decoded is! Map) {
    throw const SteamGuideLookupException();
  }

  final guideUrl = decoded['guide_url'];
  if (decoded['found'] != true || guideUrl is! String) {
    throw const SteamGuideLookupException();
  }
  final guideUri = Uri.tryParse(guideUrl);
  if (guideUri == null ||
      guideUri.scheme != 'https' ||
      guideUri.host != 'steamcommunity.com' ||
      !guideUri.path.startsWith('/app/$appId/guides/')) {
    throw const SteamGuideLookupException();
  }
  return guideUri;
}
