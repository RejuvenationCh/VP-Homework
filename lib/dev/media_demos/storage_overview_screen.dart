import 'package:flutter/material.dart';

import '../../features/media_cleaner/data/mock_media.dart';
import '../../features/media_cleaner/models/media_item.dart';
import 'media_cleaner_screen.dart';
import '../../features/media_cleaner/presentation/widgets/storage_folder.dart';
import '../../features/media_cleaner/presentation/widgets/storage_map_panel.dart';
import '../../features/media_cleaner/presentation/widgets/storage_folders_panel.dart';

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
    final providedItems = widget.items;
    if (providedItems == null) {
      _items = List.of(mockMedia);
    } else {
      _items = List.of(providedItems);
    }
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

  List<StorageFolder> get _folders {
    // demo folders group the existing files; these aren't scanned directories
    const names = {
      MediaCategory.video: 'DCIM',
      MediaCategory.screenRecording: 'Movies',
      MediaCategory.photo: 'Pictures',
      MediaCategory.screenshot: 'Screenshots',
      MediaCategory.duplicate: 'Duplicates',
    };
    final folders = <StorageFolder>[];
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
    final folders = _folders;
    final mapPanel = StorageMapPanel(
      folders: folders,
      usedBytes: _usedBytes,
      mediaBytes: _mediaBytes,
      isEmpty: _items.isEmpty,
      onRestore: _restoreDemo,
      onOpen: _openFiles,
    );
    final foldersPanel = StorageFoldersPanel(
      folders: folders,
      largestFirst: _largestFirst,
      mediaBytes: _mediaBytes,
      onToggleOrder: () => setState(() => _largestFirst = !_largestFirst),
      onOpen: _openFiles,
    );
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Backlog',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Media overview (previous)',
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
