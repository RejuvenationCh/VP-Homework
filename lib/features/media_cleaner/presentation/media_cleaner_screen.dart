import 'package:flutter/material.dart';

import '../../../dev/constraint_scenario.dart';

import '../data/mock_media.dart';
import '../models/media_item.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/media_tile.dart';
import 'widgets/media_empty_state.dart';
import 'widgets/selection_action_bar.dart';
import 'widgets/storage_summary_header.dart';

class MediaCleanerScreen extends StatefulWidget {
  final List<MediaItem>? items;
  final MediaCategory? initialCategory;
  final int? usedBytes;
  final ValueChanged<Set<String>>? onRemoved;
  final VoidCallback? onRestore;
  final ConstraintCase? constraint;
  final bool showConstraintError;

  const MediaCleanerScreen({
    super.key,
    this.items,
    this.initialCategory,
    this.usedBytes,
    this.onRemoved,
    this.onRestore,
    this.constraint,
    this.showConstraintError = false,
  });

  @override
  State<MediaCleanerScreen> createState() => _MediaCleanerScreenState();
}

class _MediaCleanerScreenState extends State<MediaCleanerScreen> {
  late final List<MediaItem> _items;
  late MediaCategory? _filter; // null = All
  late int _usedBytes;
  bool _sortBySize = true;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items ?? mockMedia);
    _filter = widget.initialCategory;
    if (widget.constraint == ConstraintCase.actionRow && _items.isNotEmpty) {
      _selectedIds.add(_items.first.id);
    }
    _usedBytes =
        widget.usedBytes ??
        mockUsedBytes -
            mockMedia.fold<int>(0, (sum, item) => sum + item.sizeBytes) +
            _sumBytes(false);
  }

  // filter first, then sort (size = biggest first, date = newest first)
  List<MediaItem> get _visibleItems {
    final List<MediaItem> result = [];
    for (final item in _items) {
      if (_filter == null || item.category == _filter) result.add(item);
    }
    if (_sortBySize) {
      result.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    } else {
      result.sort((a, b) => b.date.compareTo(a.date));
    }
    return result;
  }

  // total size of everything, or only the selected ones
  int _sumBytes(bool selectedOnly) {
    int total = 0;
    for (final item in _items) {
      if (!selectedOnly || _selectedIds.contains(item.id)) {
        total += item.sizeBytes;
      }
    }
    return total;
  }

  void _toggleSelect(String id) {
    setState(() {
      // remove() returns false if it wasn't selected yet
      if (!_selectedIds.remove(id)) _selectedIds.add(id);
    });
  }

  void _setFilter(MediaCategory? c) => setState(() => _filter = c);

  void _toggleSort() => setState(() => _sortBySize = !_sortBySize);

  void _clearSelection() => setState(() => _selectedIds.clear());

  // delete and offload do the same thing here, only diff message
  void _removeSelected(String message) {
    final removedIds = Set<String>.of(_selectedIds);
    final removedBytes = _sumBytes(true);
    setState(() {
      _items.removeWhere((item) => _selectedIds.contains(item.id));
      _selectedIds.clear();
      _usedBytes -= removedBytes;
    });
    widget.onRemoved?.call(removedIds);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  void _deleteSelected() {
    // build the message before the selection gets cleared
    _removeSelected(
      'Deleted ${_selectedIds.length} items · ${formatSize(_sumBytes(true))} freed',
    );
  }

  void _offloadSelected() {
    _removeSelected(
      'Offloaded ${_selectedIds.length} items to Google Drive (mock)',
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Cleaner'),
        actions: [
          IconButton(
            tooltip: _sortBySize ? 'Sorted by size' : 'Sorted by date',
            icon: Icon(_sortBySize ? Icons.sort : Icons.calendar_today),
            onPressed: _toggleSort,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            final header = Column(
              children: [
                StorageSummaryHeader(
                  usedBytes: _usedBytes,
                  totalBytes: mockTotalBytes,
                  mediaBytes: _sumBytes(false),
                ),
                CategoryFilterChips(
                  selected: _filter,
                  onSelected: _setFilter,
                  wrap: wide,
                ),
              ],
            );
            final files = CustomScrollView(
              key: const Key('files-scroll'),
              slivers: [
                if (!wide) SliverToBoxAdapter(child: header),
                if (visible.isEmpty)
                  SliverToBoxAdapter(
                    child: MediaEmptyState(
                      message: _items.isEmpty
                          ? 'No media left. All demo files have been removed.'
                          : 'No files in this category.',
                      actionLabel: _items.isEmpty
                          ? 'Restore demo files'
                          : 'Show all files',
                      onAction: () => setState(() {
                        _filter = null;
                        if (_items.isEmpty) {
                          _items.addAll(mockMedia);
                          _usedBytes = mockUsedBytes;
                          widget.onRestore?.call();
                        }
                      }),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) => SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.crossAxisExtent < 360
                              ? 2
                              : constraints.crossAxisExtent < 700
                              ? 3
                              : 4,
                          mainAxisExtent:
                              widget.showConstraintError &&
                                  widget.constraint == ConstraintCase.shortTile
                              ? 64
                              : 160 +
                                    48 *
                                        (MediaQuery.textScalerOf(context)
                                                .scale(1) -
                                            1),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, i) => MediaTile(
                          item: visible[i],
                          showNameOverflow:
                              i == 0 &&
                              widget.showConstraintError &&
                              widget.constraint == ConstraintCase.longName,
                          isSelected: _selectedIds.contains(visible[i].id),
                          onTap: () => _toggleSelect(visible[i].id),
                        ),
                      ),
                    ),
                  ),
              ],
            );
            return wide
                ? Row(
                    key: const Key('files-wide-layout'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 250,
                        child: SingleChildScrollView(child: header),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: files),
                    ],
                  )
                : files;
          },
        ),
      ),
      bottomNavigationBar: _selectedIds.isEmpty
          ? null
          : SelectionActionBar(
              showOverflow:
                  widget.showConstraintError &&
                  widget.constraint == ConstraintCase.actionRow,
              count: _selectedIds.length,
              totalBytes: _sumBytes(true),
              onDelete: _deleteSelected,
              onOffload: _offloadSelected,
              onClear: _clearSelection,
            ),
    );
  }
}
