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
            _metadata(context, 'Genre', game.primaryGenre),
            _metadata(context, 'Platform', game.platform),
            _metadata(
              context,
              'Playtime',
              _formatPlaytime(game.playtimeMinutes),
            ),
            _statusSelector(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Play next'),
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
            GameRatingControl(
              rating: game.rating,
              onChanged: isSaving ? null : _updateRating,
            ),
            GameNotesEntry(
              notes: game.notes,
              onTap: isSaving ? null : onEditNotes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _metadata(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  String _formatPlaytime(int? minutes) {
    if (minutes == null || minutes < 0) {
      return 'Unknown';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (hours == 0) {
        return '$minutes min';
      } else if (remainingMinutes == 0) {
        return '$hours hr';
      } else {
        return '$hours hr $remainingMinutes min';
      }
    }
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
