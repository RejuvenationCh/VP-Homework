import 'package:flutter/material.dart';

import 'game_editor_actions.dart';
import 'game_page_body.dart';

class GameNotesEntry extends StatelessWidget {
  const GameNotesEntry({super.key, required this.notes, required this.onTap});

  final String notes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    String preview;
    if (notes.isEmpty) {
      preview = 'No notes yet';
    } else {
      preview = notes;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Notes', style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.edit_note),
      onTap: onTap,
    );
  }
}

class GameNotesScreen extends StatefulWidget {
  const GameNotesScreen({
    super.key,
    required this.title,
    required this.initialNotes,
    required this.onSave,
    this.description,
  });

  final String title;
  final String initialNotes;
  final Future<bool> Function(String) onSave;
  final String? description;

  @override
  State<GameNotesScreen> createState() => _GameNotesScreenState();
}

class _GameNotesScreenState extends State<GameNotesScreen> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(
          child: GamePageBody(
            maxWidth: 640,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _description(context),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isSaving,
                      autofocus: false,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
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

  Widget _description(BuildContext context) {
    if (widget.description == null) {
      return const SizedBox.shrink();
    } else {
      var description = widget.description!;
      if (description.isEmpty) {
        description = 'No description available.';
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(child: Text(description)),
            ),
          ],
        ),
      );
    }
  }

  void _discard() {
    Navigator.of(context).pop();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final saved = await widget.onSave(_controller.text);
    if (!mounted) {
      return;
    } else if (saved) {
      setState(() => _isSaving = false);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } else {
      setState(() => _isSaving = false);
    }
  }
}
