import 'package:flutter/material.dart';

import '../../data/mock_media.dart';
import '../../models/media_item.dart';
import 'folder_map.dart';
import 'media_empty_state.dart';
import 'storage_folder.dart';

class StorageMapPanel extends StatelessWidget {
  const StorageMapPanel({
    super.key,
    required this.folders,
    required this.usedBytes,
    required this.mediaBytes,
    required this.isEmpty,
    required this.onRestore,
    required this.onOpen,
  });

  final List<StorageFolder> folders;
  final int usedBytes;
  final int mediaBytes;
  final bool isEmpty;
  final VoidCallback onRestore;
  final void Function([MediaCategory? category]) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.phone_android_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Internal storage',
                style: text.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${formatSize(mockTotalBytes - usedBytes)} free',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall?.copyWith(color: colors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${formatSize(usedBytes)} of ${formatSize(mockTotalBytes)} used',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: usedBytes / mockTotalBytes),
        const SizedBox(height: 20),
        Text(
          'Demo media folders · ${formatSize(mediaBytes)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: text.titleMedium,
        ),
        if (isEmpty)
          MediaEmptyState(
            message: 'No media left. All demo files have been removed.',
            actionLabel: 'Restore demo files',
            onAction: onRestore,
          )
        else
          FolderMap(folders: folders, onOpen: onOpen),
        if (!isEmpty)
          Text(
            'Tap a folder to explore. Small folders have a minimum touch size.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
      ],
    );
  }
}
