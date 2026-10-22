import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../helpers/game_status_colors.dart';

class GameStatusBadge extends StatelessWidget {
  const GameStatusBadge({super.key, required this.status});

  final GameStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = gameStatusColor(status, theme);
    IconData icon;
    if (status == GameStatus.playing) {
      icon = Icons.play_arrow_rounded;
    } else if (status == GameStatus.finished) {
      icon = Icons.check_rounded;
    } else if (status == GameStatus.dropped) {
      icon = Icons.stop_rounded;
    } else {
      icon = Icons.bookmark_outline_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
