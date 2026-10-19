import '../models/game.dart';

Future<List<Game>> loadSampleGames() async {
  return sampleGames;
}

// Game names picked by the user, statuses are samples
const sampleGames = [
  Game(
    isSample: true,
    id: 'sample-payday-2',
    name: 'PAYDAY 2',
    primaryGenre: 'Shooter',
    platform: 'PC',
    status: GameStatus.backlog,
    artworkUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/218620/c44949287e8ffa2518f01b5033b8431dd0f984e4/header.jpg?t=1789555107',
  ),
  Game(
    isSample: true,
    id: 'sample-terraria',
    name: 'Terraria',
    primaryGenre: 'Adventure',
    platform: 'PC',
    status: GameStatus.playing,
    artworkUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/105600/header.jpg?t=1769844435',
  ),
  Game(
    isSample: true,
    id: 'sample-counter-strike-2',
    name: 'Counter-Strike 2',
    primaryGenre: 'Shooter',
    platform: 'PC',
    status: GameStatus.finished,
    artworkUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/730/162664aa5da85f418105350c5d67ca565f6c3713/header.jpg?t=1791824795',
  ),
  Game(
    isSample: true,
    id: 'sample-forza-horizon-4',
    name: 'Forza Horizon 4',
    primaryGenre: 'Racing',
    platform: 'PC',
    status: GameStatus.dropped,
    artworkUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1293830/header.jpg?t=1734336342',
  ),
  Game(
    isSample: true,
    id: 'sample-forza-horizon-5',
    name: 'Forza Horizon 5',
    primaryGenre: 'Racing',
    platform: 'PC',
    status: GameStatus.backlog,
    artworkUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1551360/header.jpg?t=1788546569',
  ),
];
