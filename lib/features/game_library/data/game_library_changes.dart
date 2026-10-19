import '../models/game.dart';
import 'sample_games.dart';

class ManualGameIds {
  int _next = 0;

  String next(List<Game> games) {
    String id = 'manual-${_next++}';
    while (games.any((game) => game.id == id)) {
      id = 'manual-${_next++}';
    }
    return id;
  }
}

List<Game> withSampleGames(List<Game> games) {
  final updated = List<Game>.of(games);
  for (final sample in sampleGames) {
    if (!updated.any((game) => game.id == sample.id)) {
      updated.add(sample);
    }
  }
  return updated;
}

List<Game>? withUpdatedGame(List<Game> games, Game updated) {
  final index = games.indexWhere((game) => game.id == updated.id);
  if (index < 0) {
    return null;
  } else {
    final result = List<Game>.of(games);
    for (var gameIndex = 0; gameIndex < result.length; gameIndex++) {
      if (updated.isPlayNext && gameIndex != index) {
        result[gameIndex] = result[gameIndex].copyWith(
          status: result[gameIndex].status,
          rating: result[gameIndex].rating,
          notes: result[gameIndex].notes,
          isPlayNext: false,
        );
      }
    }
    result[index] = updated;
    return result;
  }
}

List<Game>? withoutGame(List<Game> games, Game removed) {
  final index = games.indexWhere((game) => game.id == removed.id);
  if (index < 0) {
    return null;
  } else {
    final result = List<Game>.of(games);
    result.removeAt(index);
    return result;
  }
}
