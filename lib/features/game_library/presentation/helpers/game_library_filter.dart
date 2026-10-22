import '../../models/game.dart';

enum GameLibrarySort {
  nameAscending,
  nameDescending,
  playtimeAscending,
  playtimeDescending,
}

extension GameLibrarySortLabel on GameLibrarySort {
  String get label {
    if (this == GameLibrarySort.nameAscending) {
      return 'Name A to Z';
    } else if (this == GameLibrarySort.nameDescending) {
      return 'Name Z to A';
    } else if (this == GameLibrarySort.playtimeAscending) {
      return 'Playtime low to high';
    } else {
      return 'Playtime high to low';
    }
  }
}

String libraryGenre(Game game) {
  if (game.primaryGenre.trim().isEmpty) {
    return 'Unsorted';
  } else {
    return game.primaryGenre.trim();
  }
}

String libraryPlatform(Game game) {
  if (game.platform.trim().isEmpty) {
    return 'Unspecified';
  } else {
    return game.platform;
  }
}

List<String> libraryGenres(List<Game> games) {
  final values = <String>{};
  for (final game in games) {
    values.add(libraryGenre(game));
  }
  final genres = values.toList();
  genres.sort();
  return genres;
}

List<String> libraryPlatforms(List<Game> games) {
  final values = <String>{};
  for (final game in games) {
    values.add(libraryPlatform(game));
  }
  final platforms = values.toList();
  platforms.sort();
  return platforms;
}

List<Game> filterAndSortGames({
  required List<Game> games,
  required String query,
  required String? genre,
  required String? platform,
  required GameStatus? status,
  required bool favoritesOnly,
  required GameLibrarySort sort,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final visibleGames = games.where((game) {
    if (normalizedQuery.isNotEmpty) {
      final matchesName = game.name.toLowerCase().contains(normalizedQuery);
      final matchesGenre = libraryGenre(game)
          .toLowerCase()
          .contains(normalizedQuery);
      final matchesPlatform = libraryPlatform(game)
          .toLowerCase()
          .contains(normalizedQuery);
      if (!matchesName && !matchesGenre && !matchesPlatform) {
        return false;
      }
    }
    if (genre != null && libraryGenre(game) != genre) {
      return false;
    }
    if (platform != null && libraryPlatform(game) != platform) {
      return false;
    }
    if (status != null && game.status != status) {
      return false;
    }
    if (favoritesOnly && !game.isFavorite) {
      return false;
    }
    return true;
  }).toList();

  visibleGames.sort((first, second) => _compareGames(first, second, sort));
  return visibleGames;
}

int _compareGames(Game first, Game second, GameLibrarySort sort) {
  if (sort == GameLibrarySort.nameAscending ||
      sort == GameLibrarySort.nameDescending) {
    final nameOrder = first.name.toLowerCase().compareTo(
      second.name.toLowerCase(),
    );
    if (sort == GameLibrarySort.nameDescending) {
      return -nameOrder;
    } else {
      return nameOrder;
    }
  }

  final firstPlaytime = first.playtimeMinutes;
  final secondPlaytime = second.playtimeMinutes;
  if (firstPlaytime == null && secondPlaytime == null) {
    return first.name.toLowerCase().compareTo(second.name.toLowerCase());
  } else if (firstPlaytime == null) {
    return 1;
  } else if (secondPlaytime == null) {
    return -1;
  } else {
    final playtimeOrder = firstPlaytime.compareTo(secondPlaytime);
    if (playtimeOrder != 0) {
      if (sort == GameLibrarySort.playtimeDescending) {
        return -playtimeOrder;
      } else {
        return playtimeOrder;
      }
    } else {
      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    }
  }
}
