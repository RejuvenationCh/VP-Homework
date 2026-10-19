import '../models/game.dart';

Map<String, Object?> gameToJson(Game game) {
  return {
    'id': game.id,
    'name': game.name,
    'primaryGenre': game.primaryGenre,
    'platform': game.platform,
    'status': game.status.name,
    'isSample': game.isSample,
    'isFavorite': game.isFavorite,
    'isPlayNext': game.isPlayNext,
    'artworkUrl': game.artworkUrl,
    'steamAppId': game.steamAppId,
    'playtimeMinutes': game.playtimeMinutes,
    'rating': game.rating,
    'notes': game.notes,
  };
}

Game gameFromJson(Map<String, dynamic> json) {
  final id = json['id'];
  final name = json['name'];
  final primaryGenre = json['primaryGenre'];
  final platform = json['platform'];
  final statusName = json['status'];
  final isSample = json['isSample'];
  final isFavorite = json['isFavorite'];
  final artworkUrl = json['artworkUrl'];
  final savedSteamAppId = json['steamAppId'];
  String? steamAppId;
  if (savedSteamAppId == null && id is String) {
    steamAppId = _sampleSteamAppIdFor(id);
  } else if (savedSteamAppId is String) {
    steamAppId = savedSteamAppId;
  } else {
    throw const FormatException('Saved game has an invalid Steam app ID.');
  }
  final playtimeMinutes = json['playtimeMinutes'];
  final rating = json['rating'];
  final notes = json['notes'];
  bool isPlayNext;
  if (json.containsKey('isPlayNext')) {
    final savedPlayNext = json['isPlayNext'];
    if (savedPlayNext is! bool) {
      throw const FormatException('Saved game has invalid play-next state.');
    } else {
      isPlayNext = savedPlayNext;
    }
  } else {
    isPlayNext = false;
  }

  if (id is! String ||
      name is! String ||
      primaryGenre is! String ||
      platform is! String ||
      statusName is! String ||
      isSample is! bool ||
      isFavorite is! bool ||
      (artworkUrl != null && artworkUrl is! String) ||
      !_isValidSteamAppId(steamAppId) ||
      (playtimeMinutes != null && playtimeMinutes is! int) ||
      (rating != null && rating is! int) ||
      notes is! String) {
    throw const FormatException('Saved game has invalid fields.');
  }

  GameStatus? status;
  for (final option in GameStatus.values) {
    if (option.name == statusName) {
      status = option;
    }
  }
  if (status == null) {
    throw const FormatException('Saved game has an invalid status.');
  } else if (rating != null && (rating < 1 || rating > 5)) {
    throw const FormatException('Saved game has an invalid rating.');
  } else {
    return Game(
      id: id,
      name: name,
      primaryGenre: primaryGenre,
      platform: platform,
      status: status,
      isSample: isSample,
      isFavorite: isFavorite,
      isPlayNext: isPlayNext,
      artworkUrl: artworkUrl,
      steamAppId: steamAppId,
      playtimeMinutes: playtimeMinutes,
      rating: rating,
      notes: notes,
    );
  }
}

bool _isValidSteamAppId(Object? value) {
  if (value == null) return true;
  if (value is! String) return false;
  return RegExp(r'^[1-9][0-9]{0,9}$').hasMatch(value);
}

String? _sampleSteamAppIdFor(String gameId) {
  if (gameId == 'sample-payday-2') return '218620';
  if (gameId == 'sample-terraria') return '105600';
  if (gameId == 'sample-counter-strike-2') return '730';
  if (gameId == 'sample-forza-horizon-4') return '1293830';
  if (gameId == 'sample-forza-horizon-5') return '1551360';
  return null;
}
