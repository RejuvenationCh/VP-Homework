import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/steam_profile_target.dart';
import 'game_database.dart';

class SteamProfileStore {
  const SteamProfileStore(this.database);

  final GameDatabase database;

  Future<SteamProfileTarget?> load() async {
    final rows = await database
        .customSelect("SELECT value FROM settings WHERE key = 'steam_profile'")
        .get();
    if (rows.isEmpty) return null;
    final decoded = jsonDecode(rows.first.read<String>('value'));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved Steam profile is invalid.');
    }
    final steamId = decoded['steamId'];
    final profileUrl = decoded['profileUrl'];
    final input = decoded['input'];
    if (steamId is! String || profileUrl is! String || input is! String) {
      throw const FormatException('Saved Steam profile is invalid.');
    }
    final uri = Uri.tryParse(profileUrl);
    if (!RegExp(r'^7656119[0-9]{10}$').hasMatch(steamId) ||
        uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'steamcommunity.com') {
      throw const FormatException('Saved Steam profile is invalid.');
    }
    return SteamProfileTarget(
      steamId: steamId,
      profileUrl: profileUrl,
      input: input,
    );
  }

  Future<void> save(SteamProfileTarget profile) async {
    final value = jsonEncode({
      'steamId': profile.steamId,
      'profileUrl': profile.profileUrl,
      'input': profile.input,
    });
    await database.customInsert(
      'INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)',
      variables: [
        Variable.withString('steam_profile'),
        Variable.withString(value),
      ],
    );
  }
}
