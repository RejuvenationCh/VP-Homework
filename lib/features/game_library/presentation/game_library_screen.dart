import 'package:flutter/material.dart';

import '../../../dev/constraint_scenario.dart';
import '../data/game_library_changes.dart';
import '../data/game_library_storage.dart';
import '../data/game_save_merge.dart';
import '../models/game.dart';
import 'game_details_screen.dart';
import 'game_library_forms.dart';
import 'game_library_body.dart';

class GameLibraryScreen extends StatefulWidget {
  const GameLibraryScreen({
    super.key,
    this.loadGames,
    this.storage,
    this.genreRequest,
    this.onGamesChanged,
    this.h2Preview,
  });
  final Future<List<Game>> Function()? loadGames;
  final GameLibraryStorage? storage;
  final String? genreRequest;
  final ValueChanged<List<Game>>? onGamesChanged;
  final GameConstraintPreview? h2Preview;
  @override
  State<GameLibraryScreen> createState() => GameLibraryScreenState();
}

class GameLibraryScreenState extends State<GameLibraryScreen> {
  late Future<List<Game>> _games;
  List<Game>? _libraryGames;
  final _manualGameIds = ManualGameIds();
  final Map<String, Game> _editingBaselines = {};
  bool _isSavingLibrary = false;
  Future<List<Game>> _loadGames() async {
    List<Game> games;
    final loader = widget.loadGames;
    final storage = widget.storage;
    if (loader != null) {
      games = await Future.sync(loader);
    } else if (storage != null) {
      games = await storage.loadGames();
    } else {
      games = <Game>[];
    }
    final copy = List<Game>.of(games);
    _libraryGames = copy;
    return copy;
  }

  @override
  void initState() {
    super.initState();
    _games = _loadGames();
  }

  @override
  void didUpdateWidget(GameLibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loadGames != widget.loadGames ||
        oldWidget.storage != widget.storage) {
      _games = _loadGames();
    }
  }

  void reload() => setState(() {
    _games = _loadGames();
  });
  Future<void> _addGame(List<Game> games) => openNewLibraryGame(
    context,
    _manualGameIds.next(_currentGames()),
    _addToCurrentLibrary,
  );

  Future<bool> _addToCurrentLibrary(Game game) async =>
      _saveAndPublish([..._currentGames(), game]);
  Future<void> _loadSamples(List<Game> games) async {
    final current = _currentGames();
    final updatedGames = withSampleGames(current);
    if (updatedGames.length != current.length) {
      await _saveAndPublish(updatedGames);
    }
  }

  Future<void> _openGame(Game game) {
    _editingBaselines[game.id] = game;
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => GameDetailsScreen(
          game: game,
          storage: widget.storage,
          onGameChanged: _updateGame,
          onEditGame: _editGame,
          onRemoveGame: _removeGame,
        ),
      ),
    );
  }

  Future<bool> openGame(Game game) async {
    try {
      await _games;
      if (mounted) {
        await _openGame(game);
        reload();
        return true;
      } else {
        return false;
      }
    } catch (_) {
      if (mounted) _showSaveMessage('Could not load game details.');
      return false;
    }
  }

  Future<Game?> _editGame(Game game) {
    _editingBaselines[game.id] = game;
    return openLibraryGameEditor(context, game, _updateGame);
  }

  Future<bool> _updateGame(Game updated) async {
    final current = _currentGames();
    if (!current.any((game) => game.id == updated.id)) return false;
    final updatedGames = gameSaveIntent(
      current,
      updated,
      widget.storage != null,
    );
    final saved = await _saveAndPublish(
      updatedGames,
      baseline: _editingBaselines[updated.id],
    );
    if (saved) _editingBaselines[updated.id] = updated;
    return saved;
  }

  Future<bool> _removeGame(Game game) async {
    final updatedGames = withoutGame(_currentGames(), game);
    if (updatedGames == null) return false;
    return _saveAndPublish(updatedGames, baseline: game);
  }

  Future<bool> _saveAndPublish(List<Game> games, {Game? baseline}) async {
    if (_isSavingLibrary) {
      if (mounted) {
        _showSaveMessage('Another save is in progress. Try again.');
      }
      return false;
    }
    _isSavingLibrary = true;
    try {
      final storage = widget.storage;
      if (storage != null) {
        final previous = gameSaveBaseline(_currentGames(), baseline);
        games = await storage.saveGames(games, previous: previous);
      }
      if (!mounted) return false;
      setState(() => _libraryGames = List<Game>.of(games));
      final onGamesChanged = widget.onGamesChanged;
      if (onGamesChanged != null) onGamesChanged(games);
      return true;
    } catch (error) {
      if (mounted) {
        if (error is StateError) reload();
        _showSaveMessage('Could not save. Reopen and try again.');
      }
      return false;
    } finally {
      _isSavingLibrary = false;
    }
  }

  void _showSaveMessage(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  List<Game> _currentGames() {
    if (_libraryGames == null) return <Game>[];
    return _libraryGames!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: GameLibraryBody(
        games: _games,
        currentGames: _libraryGames,
        hasSavedData: widget.storage != null,
        genreRequest: widget.genreRequest,
        h2Preview: widget.h2Preview,
        onRetry: reload,
        onAddGame: _addGame,
        onLoadSamples: _loadSamples,
        onOpenGame: _openGame,
      ),
    );
  }
}
