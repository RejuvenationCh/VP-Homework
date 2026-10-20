import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/steam_profile_target.dart';
import 'steam_api_parser.dart';

class SteamApiClient {
  SteamApiClient({required this.baseUrl});

  final String baseUrl;
  static final http.Client _client = http.Client();

  Future<SteamProfileTarget> resolveProfile(String input) async {
    final response = await _client
        .post(
          Uri.parse('$baseUrl/v1/steam/profile/resolve'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'profile': input}),
        )
        .timeout(const Duration(seconds: 15));
    return parseSteamProfileResponse(response, input);
  }

  Future<SteamLibraryResult> readGames(String steamId) async {
    if (!isValidSteamId(steamId)) {
      throw const SteamApiException('Steam profile ID is invalid.');
    }
    final uri = Uri.parse('$baseUrl/v1/steam/profiles/$steamId/games');
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));
    return parseSteamGamesResponse(response);
  }

  Future<SteamAchievementsResult> readAchievements(
    String steamId,
    String appId,
  ) async {
    if (!isValidSteamId(steamId) ||
        !RegExp(r'^[1-9][0-9]{0,9}$').hasMatch(appId)) {
      throw const SteamApiException('Steam game target is invalid.');
    }
    final uri = Uri.parse(
      '$baseUrl/v1/steam/profiles/$steamId/games/$appId/achievements',
    );
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));
    return parseSteamAchievementsResponse(response);
  }
}
