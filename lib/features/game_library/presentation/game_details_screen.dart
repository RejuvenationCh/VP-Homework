import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import '../models/game.dart';
import 'game_details_body.dart';
import 'game_details_actions.dart';
import 'game_achievements_screen.dart';
import 'game_notes_screen.dart';

class GameDetailsScreen extends StatefulWidget {
  const GameDetailsScreen({
    super.key,
    required this.game,
    this.storage,
    required this.onGameChanged,
    required this.onEditGame,
    required this.onRemoveGame,
    this.showH2ActionOverflow = false,
  });

  final Game game;
  final GameLibraryStorage? storage;
  final Future<bool> Function(Game) onGameChanged;
  final Future<Game?> Function(Game) onEditGame;
  final Future<bool> Function(Game) onRemoveGame;
  final bool showH2ActionOverflow;

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late Game _game;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Game details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          GameDetailsActions(
            isFavorite: _game.isFavorite,
            isSaving: _isSaving,
            onFavoriteChanged: _updateFavorite,
            onEdit: _editGame,
            onRemove: _removeGame,
            showH2Overflow: widget.showH2ActionOverflow,
          ),
        ],
      ),
      body: GameDetailsBody(
        game: _game,
        isSaving: _isSaving,
        onChanged: _saveGame,
        onEditNotes: _editNotes,
        achievements: GameAchievementsEntry(
          game: _game,
          storage: widget.storage,
        ),
      ),
    );
  }

  void _updateFavorite(bool favorite) {
    _saveGame(_game.withFavorite(favorite));
  }

  Future<bool> _saveGame(Game updated) async {
    if (_isSaving) {
      return false;
    } else {
      setState(() => _isSaving = true);
      final saved = await widget.onGameChanged(updated);
      if (mounted) {
        setState(() {
          if (saved) {
            _game = updated;
          }
          _isSaving = false;
        });
      }
      return saved;
    }
  }

  Future<void> _editGame() async {
    if (_isSaving) {
      return;
    } else {
      final updated = await widget.onEditGame(_game);
      if (!mounted || updated == null) {
        return;
      } else {
        setState(() => _game = updated);
      }
    }
  }

  Future<void> _removeGame() async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from library?'),
        content: Text(
          'Remove ${_game.name} from this library? Steam ownership and '
          'installation will not change.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (!mounted || shouldRemove != true) {
      return;
    } else {
      setState(() => _isSaving = true);
      final removed = await widget.onRemoveGame(_game);
      if (removed && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _editNotes() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => GameNotesScreen(
          title: 'Game notes',
          initialNotes: _game.notes,
          onSave: (notes) => _saveGame(
            _game.copyWith(
              status: _game.status,
              rating: _game.rating,
              notes: notes,
            ),
          ),
        ),
      ),
    );
  }
}
