enum GameStatus {
  backlog('To play'),
  playing('Playing'),
  finished('Finished'),
  dropped('Dropped');

  const GameStatus(this.label);

  final String label;
}

class Game {
  const Game({
    required this.id,
    required this.name,
    required this.primaryGenre,
    required this.platform,
    required this.status,
    this.isSample = false,
    this.isFavorite = false,
    this.isPlayNext = false,
    this.artworkUrl,
    this.playtimeMinutes,
    this.rating,
    this.notes = '',
  });

  // Game info is separate from the personal status below
  final String id;
  final String name;
  final String primaryGenre;
  final String platform;
  final bool isSample;
  final bool isFavorite;
  final bool isPlayNext;
  final String? artworkUrl;
  final int? playtimeMinutes;
  final int? rating;
  final String notes;

  // User chooses the status, not based on playtime or achievements
  final GameStatus status;

  Game copyWith({
    String? name,
    String? primaryGenre,
    String? platform,
    bool? isPlayNext,
    required GameStatus status,
    required int? rating,
    required String notes,
    bool? isFavorite,
  }) {
    String updatedName;
    if (name == null) {
      updatedName = this.name;
    } else {
      updatedName = name;
    }

    String updatedGenre;
    if (primaryGenre == null) {
      updatedGenre = this.primaryGenre;
    } else {
      updatedGenre = primaryGenre;
    }

    String updatedPlatform;
    if (platform == null) {
      updatedPlatform = this.platform;
    } else {
      updatedPlatform = platform;
    }

    bool updatedFavorite;
    if (isFavorite == null) {
      updatedFavorite = this.isFavorite;
    } else {
      updatedFavorite = isFavorite;
    }

    bool updatedPlayNext;
    if (isPlayNext == null) {
      updatedPlayNext = this.isPlayNext;
    } else {
      updatedPlayNext = isPlayNext;
    }

    return Game(
      id: id,
      name: updatedName,
      primaryGenre: updatedGenre,
      platform: updatedPlatform,
      status: status,
      isSample: isSample,
      isFavorite: updatedFavorite,
      isPlayNext: updatedPlayNext,
      artworkUrl: artworkUrl,
      playtimeMinutes: playtimeMinutes,
      rating: rating,
      notes: notes,
    );
  }

  Game withFavorite(bool favorite) {
    return copyWith(
      status: status,
      rating: rating,
      notes: notes,
      isFavorite: favorite,
    );
  }
}
