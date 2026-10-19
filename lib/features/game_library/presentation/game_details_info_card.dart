import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_notes_screen.dart';
import 'game_rating_control.dart';

class GameDetailsInfoCard extends StatelessWidget {
  const GameDetailsInfoCard({
    super.key,
    required this.game,
    required this.isSaving,
    required this.onChanged,
    required this.onEditNotes,
  });

  final Game game;
  final bool isSaving;
  final Future<bool> Function(Game) onChanged;
  final VoidCallback onEditNotes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _statusSelector(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Play next'),
              subtitle: const Text('Pin to Overview'),
              value: game.isPlayNext,
              onChanged: isSaving
                  ? null
                  : (value) => onChanged(
                      game.copyWith(
                        status: game.status,
                        rating: game.rating,
                        notes: game.notes,
                        isPlayNext: value,
                      ),
                    ),
            ),
            const Divider(height: 28),
            GameRatingControl(
              rating: game.rating,
              onChanged: isSaving ? null : _updateRating,
            ),
            const Divider(height: 20),
            GameNotesEntry(
              notes: game.notes,
              onTap: isSaving ? null : onEditNotes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Personal status'),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<GameStatus>(
            value: game.status,
            isExpanded: true,
            items: GameStatus.values
                .map(
                  (status) => DropdownMenuItem<GameStatus>(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(),
            onChanged: isSaving ? null : _updateStatus,
          ),
        ),
      ),
    );
  }

  void _updateStatus(GameStatus? status) {
    if (status == null) {
      return;
    } else {
      onChanged(
        game.copyWith(status: status, rating: game.rating, notes: game.notes),
      );
    }
  }

  void _updateRating(int? rating) {
    onChanged(
      game.copyWith(status: game.status, rating: rating, notes: game.notes),
    );
  }
}
