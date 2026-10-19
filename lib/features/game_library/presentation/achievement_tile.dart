import 'package:flutter/material.dart';

import '../models/achievement.dart';
import 'achievement_artwork.dart';
import 'achievement_progress_widget.dart';

class AchievementTile extends StatelessWidget {
  const AchievementTile({
    super.key,
    required this.achievement,
    required this.isTracked,
    required this.isSaving,
    required this.onTrackChanged,
    required this.notes,
    required this.onNotesTap,
  });

  final Achievement achievement;
  final bool isTracked;
  final bool isSaving;
  final VoidCallback onTrackChanged;
  final String? notes;
  final VoidCallback onNotesTap;

  @override
  Widget build(BuildContext context) {
    var notesTooltip = 'Edit achievement notes';
    if (notes == null) {
      notesTooltip = 'Add achievement notes';
    }
    VoidCallback? notesAction = onNotesTap;
    VoidCallback? trackingAction = onTrackChanged;
    if (isSaving) {
      notesAction = null;
      trackingAction = null;
    }
    return Card(
      child: ListTile(
        leading: AchievementArtwork(imageUrl: achievement.artworkUrl),
        title: Text(achievement.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: notesTooltip,
              onPressed: notesAction,
              icon: const Icon(Icons.edit_note),
            ),
            IconButton(
              tooltip: isTracked ? 'Untrack achievement' : 'Track achievement',
              onPressed: trackingAction,
              icon: Icon(isTracked ? Icons.bookmark : Icons.bookmark_border),
            ),
          ],
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (achievement.description.isNotEmpty)
              Text(achievement.description),
            if (notes != null && notes!.isNotEmpty)
              Text(
                'Note: $notes',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            AchievementProgressWidget(achievement: achievement),
          ],
        ),
      ),
    );
  }
}
