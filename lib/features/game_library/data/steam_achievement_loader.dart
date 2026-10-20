import '../models/achievement_record.dart';
import '../models/achievement.dart';
import '../models/game.dart';
import 'game_library_storage.dart';
import 'sample_achievements.dart';
import 'steam_api_client.dart';
import 'steam_api_parser.dart';
import 'steam_service_configuration.dart';

class AchievementLoadResult {
  const AchievementLoadResult(this.records, {this.warning});

  final List<AchievementRecord> records;
  final String? warning;
}

Future<AchievementLoadResult> loadGameAchievements({
  required Game game,
  required GameLibraryStorage? storage,
  List<Achievement>? fixtures,
}) async {
  final definitions = fixtures;
  if (definitions != null) {
    return AchievementLoadResult(
      definitions
          .map((item) => AchievementRecord(gameId: game.id, achievement: item))
          .toList(),
    );
  }
  if (storage == null) return AchievementLoadResult(_sampleRecords(game));
  final profile = await storage.loadSteamProfile();
  final appId = game.steamAppId;
  if (profile == null || appId == null) {
    if (game.isSample || appId == null) {
      return AchievementLoadResult(
        await storage.loadAchievements(game.id, achievementsForGame(game)),
      );
    }
    throw const SteamApiException(
      'Set a Steam profile in Settings to load live achievements.',
    );
  }
  try {
    final client = SteamApiClient(
      baseUrl: await resolveSteamServiceUrl(storage),
    );
    final result = await client.readAchievements(profile.steamId, appId);
    if (result.status == 'no_achievements') {
      return const AchievementLoadResult(<AchievementRecord>[]);
    }
    final achievements = result.items.map(toAchievement).toList();
    if (result.status == 'progress_unavailable') {
      final saved = await storage.loadSavedAchievements(game.id);
      if (_hasOtherProfileProgress(saved, profile.steamId)) {
        return AchievementLoadResult(
          _savedForProfile(saved, profile.steamId),
          warning: 'Live progress is unavailable. Showing saved achievements.',
        );
      }
    }
    final records = await storage.loadAchievements(
      game.id,
      achievements,
      preserveProgress: result.status == 'progress_unavailable',
      profileId: profile.steamId,
    );
    String? warning;
    if (result.status == 'progress_unavailable') {
      warning = 'Live progress is unavailable. Showing saved progress where available.';
    }
    return AchievementLoadResult(records, warning: warning);
  } catch (error) {
    final saved = await storage.loadSavedAchievements(game.id);
    if (saved.isNotEmpty) {
      var message = 'Could not refresh. Showing saved achievements.';
      if (error is SteamApiException) {
        message = '${error.message} Showing saved achievements.';
      }
      return AchievementLoadResult(
        _savedForProfile(saved, profile.steamId),
        warning: message,
      );
    }
    rethrow;
  }
}

bool _hasOtherProfileProgress(
  List<AchievementRecord> records,
  String profileId,
) {
  for (final record in records) {
    if (record.progressProfileId != profileId) return true;
  }
  return false;
}

List<AchievementRecord> _savedForProfile(
  List<AchievementRecord> records,
  String profileId,
) {
  final matching = <AchievementRecord>[];
  for (final record in records) {
    if (record.progressProfileId == profileId) {
      matching.add(record);
    } else {
      final achievement = record.achievement;
      matching.add(
        AchievementRecord(
          gameId: record.gameId,
          achievement: Achievement(
            id: achievement.id,
            name: achievement.name,
            description: achievement.description,
            artworkUrl: achievement.artworkUrl,
            progress: AchievementProgress.unknown,
          ),
          isTracked: record.isTracked,
          notes: record.notes,
        ),
      );
    }
  }
  return matching;
}

List<AchievementRecord> _sampleRecords(Game game) {
  return achievementsForGame(game)
      .map((item) => AchievementRecord(gameId: game.id, achievement: item))
      .toList();
}
