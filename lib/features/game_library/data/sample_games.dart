import '../models/game.dart';

Future<List<Game>> loadSampleGames() async {
  return sampleGames;
}

// Game names picked by the user, statuses are samples
const sampleGames = [
  Game(
    id: 'sample-payday-2',
    name: 'PAYDAY 2',
    primaryGenre: 'Shooter',
    platform: 'PC',
    status: GameStatus.backlog,
  ),
  Game(
    id: 'sample-terraria',
    name: 'Terraria',
    primaryGenre: 'Adventure',
    platform: 'PC',
    status: GameStatus.playing,
  ),
  Game(
    id: 'sample-counter-strike-2',
    name: 'Counter-Strike 2',
    primaryGenre: 'Shooter',
    platform: 'PC',
    status: GameStatus.finished,
  ),
  Game(
    id: 'sample-forza-horizon-4',
    name: 'Forza Horizon 4',
    primaryGenre: 'Racing',
    platform: 'PC',
    status: GameStatus.dropped,
  ),
  Game(
    id: 'sample-forza-horizon-5',
    name: 'Forza Horizon 5',
    primaryGenre: 'Racing',
    platform: 'PC',
    status: GameStatus.backlog,
  ),
];
