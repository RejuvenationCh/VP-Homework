enum GameStatus {
  backlog('Backlog'),
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

    return Game(
      id: id,
      name: updatedName,
      primaryGenre: updatedGenre,
      platform: updatedPlatform,
      status: status,
      isSample: isSample,
      isFavorite: updatedFavorite,
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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryGenre': primaryGenre,
      'platform': platform,
      'status': status.name,
      'isSample': isSample,
      'isFavorite': isFavorite,
      'artworkUrl': artworkUrl,
      'playtimeMinutes': playtimeMinutes,
      'rating': rating,
      'notes': notes,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final primaryGenre = json['primaryGenre'];
    final platform = json['platform'];
    final statusName = json['status'];
    final isSample = json['isSample'];
    final isFavorite = json['isFavorite'];
    final artworkUrl = json['artworkUrl'];
    final playtimeMinutes = json['playtimeMinutes'];
    final rating = json['rating'];
    final notes = json['notes'];

    if (id is! String ||
        name is! String ||
        primaryGenre is! String ||
        platform is! String ||
        statusName is! String ||
        isSample is! bool ||
        isFavorite is! bool ||
        (artworkUrl != null && artworkUrl is! String) ||
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
        artworkUrl: artworkUrl,
        playtimeMinutes: playtimeMinutes,
        rating: rating,
        notes: notes,
      );
    }
  }
}
