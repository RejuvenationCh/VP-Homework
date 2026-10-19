import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_artwork.dart';
import 'game_notes_screen.dart';
import 'game_rating_control.dart';

class GameDetailsScreen extends StatefulWidget {
  const GameDetailsScreen({
    super.key,
    required this.game,
    required this.onStatusChanged,
    required this.onRatingChanged,
    required this.onNotesChanged,
  });

  final Game game;
  final ValueChanged<GameStatus> onStatusChanged;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<String> onNotesChanged;

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late GameStatus _status;
  int? _rating;
  late String _notes;

  @override
  void initState() {
    super.initState();
    _status = widget.game.status;
    _rating = widget.game.rating;
    _notes = widget.game.notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GameArtwork(imageUrl: widget.game.artworkUrl),
              ),
              const SizedBox(height: 16),
              Text(
                widget.game.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.game.isSample) ...[
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(label: Text('Sample')),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _metadata(context, 'Genre', widget.game.primaryGenre),
                      _metadata(context, 'Platform', widget.game.platform),
                      _metadata(
                        context,
                        'Playtime',
                        _formatPlaytime(widget.game.playtimeMinutes),
                      ),
                      _statusSelector(context),
                      GameRatingControl(
                        rating: _rating,
                        onChanged: _updateRating,
                      ),
                      GameNotesEntry(notes: _notes, onTap: _editNotes),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget _statusSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<GameStatus>(
        initialValue: _status,
        decoration: const InputDecoration(labelText: 'Personal status'),
        items: GameStatus.values
            .map(
              (status) => DropdownMenuItem<GameStatus>(
                value: status,
                child: Text(status.label),
              ),
            )
            .toList(),
        onChanged: (status) {
          if (status == null) {
            return;
          } else {
            setState(() => _status = status);
            widget.onStatusChanged(status);
          }
        },
      ),
    );
  }

  void _updateRating(int? rating) {
    setState(() => _rating = rating);
    widget.onRatingChanged(rating);
  }

  Future<void> _editNotes() async {
    final notes = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => GameNotesScreen(initialNotes: _notes),
      ),
    );
    if (!mounted || notes == null) {
      return;
    } else {
      setState(() => _notes = notes);
      widget.onNotesChanged(notes);
    }
  }
}
