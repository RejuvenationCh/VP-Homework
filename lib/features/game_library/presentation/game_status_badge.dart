import 'package:flutter/material.dart';

import '../models/game.dart';

class GameStatusBadge extends StatelessWidget {
  const GameStatusBadge({super.key, required this.status});

  final GameStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    Color fill;
    Color ink;
    IconData icon;
    if (status == GameStatus.playing) {
      fill = colors.primaryContainer;
      ink = colors.onPrimaryContainer;
      icon = Icons.play_arrow_rounded;
    } else if (status == GameStatus.finished) {
      fill = colors.tertiaryContainer;
      ink = colors.onTertiaryContainer;
      icon = Icons.check_rounded;
    } else if (status == GameStatus.dropped) {
      fill = colors.surfaceContainerHighest;
      ink = colors.onSurfaceVariant;
      icon = Icons.pause_rounded;
    } else {
      fill = colors.secondaryContainer;
      ink = colors.onSecondaryContainer;
      icon = Icons.bookmark_outline_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: ink),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(color: ink),
          ),
        ],
      ),
    );
  }
}
