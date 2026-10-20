import '../models/game.dart';
import 'game_json.dart';
import 'game_library_changes.dart';

List<Game> mergeGameChanges(
  List<Game> current,
  List<Game> previous,
  List<Game> updated,
) {
  final before = {for (final game in previous) game.id: game};
  final after = {for (final game in updated) game.id: game};
  final latest = {for (final game in current) game.id: game};
  for (final game in previous) {
    final next = after[game.id];
    final saved = latest[game.id];
    if (next == null) {
      if (saved != null && !_sameGame(saved, game)) {
        throw StateError('This game changed. Reload before removing it.');
      }
      latest.remove(game.id);
    } else {
      final oldFields = gameToJson(game);
      final nextFields = gameToJson(next);
      if (saved == null) {
        if (!_sameGame(game, next)) {
          throw StateError('This game was removed. Reload your library.');
        }
        continue;
      }
      final fields = gameToJson(saved);
      for (final key in oldFields.keys) {
        if (oldFields[key] == nextFields[key]) continue;
        if (fields[key] != oldFields[key] && fields[key] != nextFields[key]) {
          throw StateError('This game changed. Reload before saving.');
        }
        fields[key] = nextFields[key];
      }
      latest[game.id] = gameFromJson(fields);
    }
  }
  for (final game in updated) {
    if (before.containsKey(game.id)) continue;
    if (latest.containsKey(game.id)) {
      throw StateError('This game ID already exists. Reload your library.');
    }
    latest[game.id] = game;
  }
  // Only one game can be pinned for next
  final pins = updated.where((game) {
    final old = before[game.id];
    return game.isPlayNext && (old == null || !old.isPlayNext);
  }).toList();
  if (pins.isNotEmpty) {
    for (final entry in latest.entries.toList()) {
      final game = entry.value;
      if (game.id != pins.last.id && game.isPlayNext) {
        latest[game.id] = game.copyWith(
          status: game.status,
          rating: game.rating,
          notes: game.notes,
          isPlayNext: false,
        );
      }
    }
  }
  return latest.values.toList();
}

bool _sameGame(Game first, Game second) {
  final left = gameToJson(first);
  final right = gameToJson(second);
  return left.keys.every((key) => left[key] == right[key]);
}

List<Game> gameSaveIntent(List<Game> current, Game updated, bool persisted) {
  if (!persisted) {
    final result = withUpdatedGame(current, updated);
    if (result != null) return result;
    throw StateError('Game no longer exists.');
  }
  return current.map((game) {
    if (game.id == updated.id) return updated;
    return game;
  }).toList();
}

List<Game> gameSaveBaseline(List<Game> games, Game? baseline) {
  return games.map((game) {
    if (baseline != null && game.id == baseline.id) return baseline;
    return game;
  }).toList();
}
