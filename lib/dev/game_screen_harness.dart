import 'package:flutter/material.dart';

import 'constraint_scenario.dart';
import '../features/game_library/data/game_library_storage.dart';
import '../features/game_library/data/sample_games.dart';
import '../features/game_library/models/game.dart';
import '../features/game_library/presentation/screens/game_details_screen.dart';
import '../features/game_library/presentation/screens/game_form_screen.dart';
import '../features/game_library/presentation/screens/game_library_screen.dart';
import '../features/game_library/presentation/screens/game_overview_screen.dart';
import '../features/game_library/presentation/screens/game_settings_screen.dart';
import 'demo_device.dart';
import 'game_fixtures.dart';
import 'achievement_fixtures.dart';

class GameScreenHarness extends StatefulWidget {
  const GameScreenHarness({
    super.key,
    required this.screen,
    this.storage,
    required this.memoryGames,
    required this.achievementData,
    this.gamePreview,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onMemoryGamesChanged,
  });

  final DemoScreen screen;
  final GameLibraryStorage? storage;
  final List<Game> memoryGames;
  final AchievementDemoData achievementData;
  final GameConstraintPreview? gamePreview;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<List<Game>> onMemoryGamesChanged;
  @override
  State<GameScreenHarness> createState() => _GameScreenHarnessState();
}

class _GameScreenHarnessState extends State<GameScreenHarness> {
  final _overviewKey = GlobalKey<GameOverviewScreenState>();
  final _libraryKey = GlobalKey<GameLibraryScreenState>();
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateInitialRoutes: (navigator, initialRoute) => _routes(),
      onGenerateRoute: (settings) =>
          MaterialPageRoute<void>(builder: (context) => _library(context)),
    );
  }

  List<Route<void>> _routes() {
    final routes = <Route<void>>[];
    if (widget.screen == DemoScreen.overview) {
      routes.add(_route(_overview));
    } else if (widget.screen == DemoScreen.settings) {
      routes.add(_route(_settings));
    } else {
      routes.add(_route(_library));
      if (widget.screen == DemoScreen.details ||
          widget.screen == DemoScreen.achievements) {
        routes.add(_route(_details));
      }
      if (widget.screen == DemoScreen.addEdit) {
        routes.add(_route(_addGame));
      } else if (widget.screen == DemoScreen.achievements) {
        routes.add(_route(_achievements));
      }
    }
    return routes;
  }

  MaterialPageRoute<void> _route(Widget Function(BuildContext) page) =>
      MaterialPageRoute<void>(builder: page);
  Widget _overview(BuildContext context) => GameOverviewScreen(
    key: _overviewKey,
    storage: widget.storage,
    loadGames: _loadGames,
    refreshKey: 0,
    onGenreSelected: (genre) => Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            builder: (context) => _library(context, genre),
          ),
        )
        .then((_) => _overviewKey.currentState?.reload()),
    onOpenLibrary: () => Navigator.of(context).push<void>(_route(_library)),
    onGameSelected: (game) => Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (context) => _details(context, game)),
    ),
  );

  Widget _library(BuildContext context, [String? genre]) {
    final storage = widget.storage;
    if (storage != null) {
      return GameLibraryScreen(
        key: genre == null ? _libraryKey : null,
        storage: storage,
        genreRequest: genre,
        h2Preview: widget.gamePreview,
      );
    } else {
      return GameLibraryScreen(
        key: genre == null ? _libraryKey : null,
        loadGames: _loadGames,
        genreRequest: genre,
        onGamesChanged: widget.onMemoryGamesChanged,
        h2Preview: widget.gamePreview,
      );
    }
  }

  Widget _details(BuildContext context, [Game? selectedGame]) {
    Game game;
    if (selectedGame == null) {
      if (widget.memoryGames.isNotEmpty) {
        game = widget.memoryGames.first;
      } else {
        game = sampleGames.first;
      }
    } else {
      game = selectedGame;
    }
    return GameDetailsScreen(
      game: game,
      storage: widget.storage,
      showH2ActionOverflow: widget.gamePreview?.showActionOverflow == true,
      onGameChanged: _saveGame,
      onEditGame: (game) => Navigator.of(context).push<Game>(
        MaterialPageRoute<Game>(
          builder: (context) =>
              GameFormScreen(game: game, isNew: false, onSave: _saveGame),
        ),
      ),
      onRemoveGame: _removeGame,
    );
  }

  Widget _addGame(BuildContext context) =>
      GameFormScreen(game: emulatorNewGame, isNew: true, onSave: _saveGame);

  Widget _achievements(BuildContext context) =>
      widget.achievementData.screen(widget.storage);

  Widget _settings(BuildContext context) => GameSettingsScreen(
    themeMode: widget.themeMode,
    onThemeModeChanged: widget.onThemeModeChanged,
  );

  Future<List<Game>> _loadGames() async {
    final preview = widget.gamePreview;
    if (preview != null &&
        (preview.type == GameConstraintCase.longName ||
            preview.type == GameConstraintCase.shortTile)) {
      return GameDemoData.longName.games;
    }
    final storage = widget.storage;
    if (storage != null) {
      return storage.loadGames();
    } else {
      return List<Game>.of(widget.memoryGames);
    }
  }

  Future<bool> _saveGame(Game updated) => _changeGame(updated);

  Future<bool> _removeGame(Game removed) => _changeGame(removed, remove: true);

  Future<bool> _changeGame(Game target, {bool remove = false}) async {
    try {
      final games = await _loadGames();
      final index = games.indexWhere((game) => game.id == target.id);
      if (remove) {
        games.removeWhere((game) => game.id == target.id);
      } else if (index < 0) {
        games.add(target);
      } else {
        games[index] = target;
      }
      final storage = widget.storage;
      if (storage != null) {
        await storage.saveGames(games);
      } else if (widget.gamePreview == null) {
        widget.onMemoryGamesChanged(games);
      }
      if (mounted) _scheduleReload();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _scheduleReload() => WidgetsBinding.instance.addPostFrameCallback((_) {
    _overviewKey.currentState?.reload();
    _libraryKey.currentState?.reload();
  });
}
