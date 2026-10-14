import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/mock_media.dart';
import '../models/media_item.dart';
import 'media_cleaner_screen.dart';
import 'widgets/media_empty_state.dart';

typedef _Folder = ({String name, MediaCategory category, int count, int bytes});

class StorageOverviewScreen extends StatefulWidget {
  const StorageOverviewScreen({super.key, this.items});

  final List<MediaItem>? items;

  @override
  State<StorageOverviewScreen> createState() => _StorageOverviewScreenState();
}

class _StorageOverviewScreenState extends State<StorageOverviewScreen> {
  late final List<MediaItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items ?? mockMedia);
  }

  void _restoreDemo() => setState(() {
    _items.clear();
    _items.addAll(mockMedia);
  });

  bool _largestFirst = true;

  int get _mediaBytes => _items.fold(0, (sum, item) => sum + item.sizeBytes);

  int get _usedBytes =>
      mockUsedBytes -
      mockMedia.fold<int>(0, (sum, item) => sum + item.sizeBytes) +
      _mediaBytes;

  List<_Folder> get _folders {
    // demo folders group the existing files; these aren't scanned directories
    const names = {
      MediaCategory.video: 'DCIM',
      MediaCategory.screenRecording: 'Movies',
      MediaCategory.photo: 'Pictures',
      MediaCategory.screenshot: 'Screenshots',
      MediaCategory.duplicate: 'Duplicates',
    };
    final folders = <_Folder>[];
    for (final entry in names.entries) {
      final files = _items.where((item) => item.category == entry.key);
      folders.add((
        name: entry.value,
        category: entry.key,
        count: files.length,
        bytes: files.fold(0, (sum, item) => sum + item.sizeBytes),
      ));
    }
    folders.sort((a, b) => b.bytes.compareTo(a.bytes));
    return folders;
  }

  void _openFiles([MediaCategory? category]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaCleanerScreen(
          items: _items,
          initialCategory: category,
          usedBytes: _usedBytes,
          onRestore: _restoreDemo,
          onRemoved: (ids) {
            setState(() => _items.removeWhere((item) => ids.contains(item.id)));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final folders = _folders;
    final ordered = _largestFirst ? folders : folders.reversed.toList();
    final mapPanel = Column(
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
              '${formatSize(mockTotalBytes - _usedBytes)} free',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall?.copyWith(color: colors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${formatSize(_usedBytes)} of ${formatSize(mockTotalBytes)} used',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _usedBytes / mockTotalBytes),
        const SizedBox(height: 20),
        Text(
          'Demo media folders · ${formatSize(_mediaBytes)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: text.titleMedium,
        ),
        if (_items.isEmpty)
          MediaEmptyState(
            message: 'No media left. All demo files have been removed.',
            actionLabel: 'Restore demo files',
            onAction: _restoreDemo,
          )
        else
          _FolderMap(folders: folders, onOpen: _openFiles),
        if (_items.isNotEmpty)
          Text(
            'Tap a folder to explore. Small folders have a minimum touch size.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
      ],
    );
    final foldersPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Folders', style: text.titleMedium)),
            TextButton.icon(
              onPressed: () => setState(() => _largestFirst = !_largestFirst),
              icon: Icon(
                _largestFirst ? Icons.arrow_downward : Icons.arrow_upward,
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
              color: _folderColors(colors, folder.category).ink,
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
                        value: _mediaBytes == 0
                            ? 0
                            : folder.bytes / _mediaBytes,
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
            onTap: () => _openFiles(folder.category),
          ),
          const Divider(height: 1, indent: 34),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _openFiles(),
          icon: const Icon(Icons.manage_search),
          label: const Text('Review large files'),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Media Cleaner')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const padding = EdgeInsets.fromLTRB(16, 8, 16, 24);
            return constraints.maxWidth >= 700
                ? Row(
                    key: const Key('overview-wide-layout'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView(padding: padding, children: [mapPanel]),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: ListView(
                          padding: padding,
                          children: [foldersPanel],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: padding,
                    children: [
                      mapPanel,
                      const SizedBox(height: 16),
                      foldersPanel,
                    ],
                  );
          },
        ),
      ),
    );
  }
}

({Color fill, Color ink}) _folderColors(
  ColorScheme colors,
  MediaCategory category,
) {
  switch (category) {
    case MediaCategory.video:
    case MediaCategory.screenRecording:
      return (
        fill: colors.secondaryContainer,
        ink: colors.onSecondaryContainer,
      );
    case MediaCategory.photo:
    case MediaCategory.screenshot:
      return (fill: colors.tertiaryContainer, ink: colors.onTertiaryContainer);
    case MediaCategory.duplicate:
      return (fill: colors.surfaceContainer, ink: colors.onSurfaceVariant);
  }
}

class _FolderMap extends StatelessWidget {
  final List<_Folder> folders;
  final ValueChanged<MediaCategory> onOpen;

  const _FolderMap({required this.folders, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final visible = folders.where((folder) => folder.bytes > 0).toList();
    final theme = Theme.of(context);
    // shortcut: five fixed slots for demo folders; pack dynamically when real folders are added
    const centers = [
      Offset(.36, .43),
      Offset(.82, .28),
      Offset(.82, .67),
      Offset(.60, .85),
      Offset(.26, .85),
    ];
    const slotDiameters = [.64, .32, .26, .24, .22];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 440.0);
        final largest = width * .64;
        return Align(
          child: SizedBox(
            width: width,
            height: width,
            child: Stack(
              children: [
                for (var i = 0; i < visible.length; i++)
                  Builder(
                    builder: (context) {
                      final folder = visible[i];
                      final diameter = math.max(
                        48.0,
                        math.min(
                          width * slotDiameters[i],
                          largest *
                              math.sqrt(folder.bytes / visible.first.bytes),
                        ),
                      );
                      final palette = _folderColors(
                        theme.colorScheme,
                        folder.category,
                      );
                      return Positioned(
                        left: centers[i].dx * width - diameter / 2,
                        top: centers[i].dy * width - diameter / 2,
                        width: diameter,
                        height: diameter,
                        child: Tooltip(
                          message:
                              '${folder.name} · ${formatSize(folder.bytes)}',
                          child: Semantics(
                            label:
                                '${folder.name}, ${formatSize(folder.bytes)}, ${folder.count} files',
                            button: true,
                            child: ExcludeSemantics(
                              child: Material(
                                color: palette.fill,
                                shape: CircleBorder(
                                  side: BorderSide(
                                    color: palette.ink.withValues(alpha: .25),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => onOpen(folder.category),
                                  child: Center(
                                    child:
                                        diameter >= 100 &&
                                            MediaQuery.textScalerOf(context)
                                                    .scale(1) <=
                                                1.3
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.folder,
                                                color: palette.ink,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                folder.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      color: palette.ink,
                                                    ),
                                              ),
                                              Text(
                                                formatSize(folder.bytes),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: palette.ink,
                                                    ),
                                              ),
                                            ],
                                          )
                                        : Icon(
                                            Icons.folder,
                                            color: palette.ink,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
