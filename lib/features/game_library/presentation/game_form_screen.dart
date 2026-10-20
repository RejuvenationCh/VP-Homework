import 'package:flutter/material.dart';

import 'game_editor_actions.dart';
import 'game_page_body.dart';
import 'game_cover_field.dart';

import '../models/game.dart';

class GameFormScreen extends StatefulWidget {
  const GameFormScreen({
    super.key,
    required this.game,
    required this.isNew,
    required this.onSave,
  });

  final Game game;
  final bool isNew;
  final Future<bool> Function(Game) onSave;

  @override
  State<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends State<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _platformController;
  late final TextEditingController _genreController;
  late final TextEditingController _coverController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.game.name);
    _platformController = TextEditingController(text: widget.game.platform);
    _genreController = TextEditingController(text: widget.game.primaryGenre);
    _coverController = TextEditingController(text: widget.game.artworkUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _platformController.dispose();
    _genreController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.isNew) {
      title = 'Add game';
    } else {
      title = 'Edit game';
    }

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: GamePageBody(
            maxWidth: 640,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Game details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _textField(
                    _titleController,
                    'Game title',
                    'Enter a game title',
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    _platformController,
                    'Platform',
                    'Enter a platform',
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    _genreController,
                    'Primary genre',
                    'Enter a primary genre',
                  ),
                  const SizedBox(height: 12),
                  GameCoverField(
                    controller: _coverController,
                    enabled: !_isSaving,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: GameEditorActions(
          isSaving: _isSaving,
          onDiscard: _discard,
          onSave: _save,
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    String error,
  ) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return error;
        } else {
          return null;
        }
      },
    );
  }

  void _discard() {
    Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    } else {
      final editedGame = widget.game.copyWith(
        name: _titleController.text.trim(),
        platform: _platformController.text.trim(),
        primaryGenre: _genreController.text.trim(),
        artworkUrl: _coverController.text.trim(),
        clearArtwork: _coverController.text.trim().isEmpty,
        status: widget.game.status,
        rating: widget.game.rating,
        notes: widget.game.notes,
      );
      setState(() => _isSaving = true);
      final saved = await widget.onSave(editedGame);
      if (!mounted) {
        return;
      } else if (saved) {
        setState(() => _isSaving = false);
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(editedGame);
      } else {
        setState(() => _isSaving = false);
      }
    }
  }
}
