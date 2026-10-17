import 'package:flutter/material.dart';

import '../../models/media_item.dart';
import 'storage_folder.dart';

class StorageFoldersPanel extends StatelessWidget {
  const StorageFoldersPanel({
    super.key,
    required this.folders,
    required this.largestFirst,
    required this.mediaBytes,
    required this.onToggleOrder,
    required this.onOpen,
  });

  final List<StorageFolder> folders;
  final bool largestFirst;
  final int mediaBytes;
  final VoidCallback onToggleOrder;
  final void Function([MediaCategory? category]) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final ordered = largestFirst ? folders : folders.reversed.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Folders', style: text.titleMedium)),
            TextButton.icon(
              onPressed: onToggleOrder,
              icon: Icon(
                largestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                size: 18,
              ),
              label: const Text('Size'),
            ),
          ],
        ),
        for (final folder in ordered.where((folder) => folder.count > 0)) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: 64,
            minVerticalPadding: 8,
            horizontalTitleGap: 12,
            leading: Icon(
              Icons.folder,
              size: 22,
              color: folderColors(colors, folder.category).ink,
            ),
            title: Text(
              folder.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${folder.count} files',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatSize(folder.bytes),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: mediaBytes == 0 ? 0 : folder.bytes / mediaBytes,
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(2),
                        semanticsLabel: '${folder.name} share of media storage',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
            onTap: () => onOpen(folder.category),
          ),
          const Divider(height: 1, indent: 34),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => onOpen(),
          icon: const Icon(Icons.manage_search),
          label: const Text('Review large files'),
        ),
      ],
    );
  }
}
