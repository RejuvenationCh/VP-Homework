import 'package:flutter/material.dart';

import '../../models/media_item.dart';

class SizeBadge extends StatelessWidget {
  final int bytes;

  const SizeBadge({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(
        formatSize(bytes),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
