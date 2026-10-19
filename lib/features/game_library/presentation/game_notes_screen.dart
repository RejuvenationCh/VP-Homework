import 'package:flutter/material.dart';

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
    required this.initialNotes,
    required this.onSave,
  });

  final String initialNotes;
  final Future<bool> Function(String) onSave;

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
        appBar: AppBar(title: const Text('Game notes')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isSaving,
                    autofocus: false,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                    onPressed: _isSaving ? null : _discard,
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                    onPressed: _isSaving ? null : _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
