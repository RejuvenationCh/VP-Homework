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
    this.artworkUrl,
    this.playtimeMinutes,
    this.rating,
  });

  // Game info is separate from the personal status below
  final String id;
  final String name;
  final String primaryGenre;
  final String platform;
  final bool isSample;
  final String? artworkUrl;
  final int? playtimeMinutes;
  final int? rating;

  // User chooses the status, not based on playtime or achievements
  final GameStatus status;

  Game copyWith({required GameStatus status, required int? rating}) {
    return Game(
      id: id,
      name: name,
      primaryGenre: primaryGenre,
      platform: platform,
      status: status,
      isSample: isSample,
      artworkUrl: artworkUrl,
      playtimeMinutes: playtimeMinutes,
      rating: rating,
    );
  }
}
