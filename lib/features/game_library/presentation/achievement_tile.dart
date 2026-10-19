import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../models/game.dart';
import 'achievement_artwork.dart';
import 'achievement_guide_button.dart';
import 'achievement_progress_widget.dart';

class AchievementTile extends StatelessWidget {
  const AchievementTile({
    super.key,
    required this.game,
    required this.achievement,
    required this.isTracked,
    required this.isSaving,
    required this.onTrackChanged,
    required this.notes,
    required this.onNotesTap,
  });

  final Game game;
  final Achievement achievement;
  final bool isTracked;
  final bool isSaving;
  final VoidCallback onTrackChanged;
  final String? notes;
  final VoidCallback onNotesTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var notesTooltip = 'Edit achievement notes';
    if (notes == null) notesTooltip = 'Add achievement notes';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AchievementArtwork(imageUrl: achievement.artworkUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      achievement.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              if (achievement.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              AchievementProgressWidget(achievement: achievement),
              if (notes != null && notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Note: $notes',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 4),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: isTracked
                        ? 'Untrack achievement'
                        : 'Track achievement',
                    child: TextButton.icon(
                      onPressed: isSaving ? null : onTrackChanged,
                      icon: Icon(
                        isTracked ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                      ),
                      label: Text(isTracked ? 'Tracked' : 'Track'),
                    ),
                  ),
                  if (game.steamAppId != null)
                    AchievementGuideButton(
                      game: game,
                      achievement: achievement,
                    ),
                  IconButton(
                    tooltip: notesTooltip,
                    onPressed: isSaving ? null : onNotesTap,
                    icon: const Icon(Icons.edit_note),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
