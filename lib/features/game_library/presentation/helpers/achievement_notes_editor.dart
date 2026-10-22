import 'package:flutter/material.dart';

import '../screens/game_notes_screen.dart';

Future<void> openAchievementNotes({
  required BuildContext context,
  required String title,
  required String notes,
  required String description,
  required Future<bool> Function(String) onSave,
}) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => GameNotesScreen(
        title: title,
        initialNotes: notes,
        description: description,
        onSave: onSave,
      ),
    ),
  );
}
