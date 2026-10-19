import 'package:flutter/material.dart';

import '../data/game_library_changes.dart';
import '../data/game_library_storage.dart';
import '../models/game.dart';
import 'game_details_screen.dart';
import 'game_form_screen.dart';
import 'game_library_body.dart';

class GameLibraryScreen extends StatefulWidget {
  const GameLibraryScreen({super.key, this.loadGames, this.storage});

  final Future<List<Game>> Function()? loadGames;
  final GameLibraryStorage? storage;

  @override
  State<GameLibraryScreen> createState() => _GameLibraryScreenState();
}

class _GameLibraryScreenState extends State<GameLibraryScreen> {
  late Future<List<Game>> _games;
  List<Game>? _libraryGames;
  final _manualGameIds = ManualGameIds();
  bool _isSavingLibrary = false;

  Future<List<Game>> _loadGames() async {
    List<Game> games;
    final loader = widget.loadGames;
    if (loader != null) {
      games = await Future.sync(loader);
    } else {
      final storage = widget.storage;
      if (storage != null) {
        games = await storage.loadGames();
      } else {
        games = <Game>[];
      }
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

  void _retry() {
    setState(() {
      _games = _loadGames();
    });
  }

  Future<void> _addGame(List<Game> games) async {
    final draft = Game(
      id: _manualGameIds.next(_currentGames()),
      name: '',
      primaryGenre: 'Unsorted',
      platform: 'Unspecified',
      status: GameStatus.backlog,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => GameFormScreen(
          game: draft,
          isNew: true,
          onSave: _addToCurrentLibrary,
        ),
      ),
    );
  }

  Future<bool> _addToCurrentLibrary(Game game) async {
    final updatedGames = List<Game>.of(_currentGames());
    updatedGames.add(game);
    return _saveAndPublish(updatedGames);
  }

  Future<void> _loadSamples(List<Game> games) async {
    final current = _currentGames();
    final updatedGames = withSampleGames(current);
    if (updatedGames.length != current.length) {
      await _saveAndPublish(updatedGames);
    }
  }

  void _openGame(Game game) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => GameDetailsScreen(
          game: game,
          onGameChanged: _updateGame,
          onEditGame: _editGame,
          onRemoveGame: _removeGame,
        ),
      ),
    );
  }

  Future<Game?> _editGame(Game game) {
    return Navigator.of(context).push<Game>(
      MaterialPageRoute<Game>(
        builder: (context) =>
            GameFormScreen(game: game, isNew: false, onSave: _updateGame),
      ),
    );
  }

  Future<bool> _updateGame(Game updated) async {
    final updatedGames = withUpdatedGame(_currentGames(), updated);
    if (updatedGames == null) {
      return false;
    } else {
      return _saveAndPublish(updatedGames);
    }
  }

  Future<bool> _removeGame(Game game) async {
    final updatedGames = withoutGame(_currentGames(), game);
    if (updatedGames == null) {
      return false;
    } else {
      return _saveAndPublish(updatedGames);
    }
  }

  Future<bool> _saveAndPublish(List<Game> games) async {
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
        await storage.saveGames(games);
      }
      if (!mounted) {
        return false;
      } else {
        setState(() => _libraryGames = List<Game>.of(games));
        return true;
      }
    } catch (_) {
      if (mounted) {
        _showSaveMessage('Could not save. Your previous library was kept.');
      }
      return false;
    } finally {
      _isSavingLibrary = false;
    }
  }

  void _showSaveMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  List<Game> _currentGames() {
    final games = _libraryGames;
    if (games == null) {
      return <Game>[];
    } else {
      return games;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Backlog')),
      body: GameLibraryBody(
        games: _games,
        currentGames: _libraryGames,
        hasSavedData: widget.storage != null,
        onRetry: _retry,
        onAddGame: _addGame,
        onLoadSamples: _loadSamples,
        onOpenGame: _openGame,
      ),
    );
  }
}
