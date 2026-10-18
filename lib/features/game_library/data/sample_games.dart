import '../models/game.dart';

// Sample games and statuses, not from a Steam account
const sampleGames = [
  Game(
    id: 'sample-lantern-valley',
    name: 'Lantern Valley',
    primaryGenre: 'Adventure',
    platform: 'PC',
    status: GameStatus.backlog,
  ),
  Game(
    id: 'sample-orbit-racers',
    name: 'Orbit Racers',
    primaryGenre: 'Racing',
    platform: 'PC',
    status: GameStatus.playing,
  ),
  Game(
    id: 'sample-clockwork-quest',
    name: 'Clockwork Quest',
    primaryGenre: 'Puzzle',
    platform: 'Mobile',
    status: GameStatus.finished,
  ),
  Game(
    id: 'sample-harbor-tactics',
    name: 'Harbor Tactics',
    primaryGenre: 'Strategy',
    platform: 'Console',
    status: GameStatus.dropped,
  ),
];
