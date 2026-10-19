import '../features/game_library/data/sample_games.dart';
import '../features/game_library/models/game.dart';

const emulatorNewGame = Game(
  id: 'emulator-new-game',
  name: '',
  primaryGenre: 'Unsorted',
  platform: 'Unspecified',
  status: GameStatus.backlog,
);

enum GameDemoData {
  current('Current data'),
  longName('Long name'),
  empty('Empty'),
  big('500 games');

  const GameDemoData(this.label);
  final String label;

  List<Game> get games {
    if (this == GameDemoData.longName) {
      final game = sampleGames.first;
      return [
        Game(
          id: 'fixture-long-name',
          name: List.filled(200, 'W').join(),
          primaryGenre: game.primaryGenre,
          platform: game.platform,
          status: game.status,
          isSample: true,
          artworkUrl: game.artworkUrl,
          steamAppId: game.steamAppId,
        ),
      ];
    } else if (this == GameDemoData.empty) {
      return <Game>[];
    } else if (this == GameDemoData.big) {
      return List<Game>.generate(500, (index) {
        final game = sampleGames[index % sampleGames.length];
        return Game(
          id: 'fixture-$index',
          name: '${game.name} ${index + 1}',
          primaryGenre: game.primaryGenre,
          platform: game.platform,
          status: game.status,
          isSample: true,
          artworkUrl: game.artworkUrl,
          steamAppId: game.steamAppId,
        );
      });
    } else {
      return <Game>[];
    }
  }
}

class GameFixtureSelection {
  GameDemoData selected = GameDemoData.current;
  List<Game> memoryGames = [];
  List<Game> fixtureGames = [];

  List<Game> get games {
    if (selected == GameDemoData.current) {
      return memoryGames;
    } else {
      return fixtureGames;
    }
  }

  void select(GameDemoData data) {
    selected = data;
    if (data == GameDemoData.current) {
      fixtureGames = [];
    } else {
      fixtureGames = data.games;
    }
  }

  void update(List<Game> games) {
    if (selected == GameDemoData.current) {
      memoryGames = List<Game>.of(games);
    } else {
      fixtureGames = List<Game>.of(games);
    }
  }
}
