import 'package:flutter/material.dart';

import '../../../dev/constraint_scenario.dart';

import '../data/mock_media.dart';
import '../models/media_item.dart';
import 'widgets/selection_action_bar.dart';
import 'widgets/media_files_body.dart';

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
    final providedItems = widget.items;
    if (providedItems == null) {
      _items = List.of(mockMedia);
    } else {
      _items = List.of(providedItems);
    }
    _filter = widget.initialCategory;
    if (widget.constraint == ConstraintCase.actionRow && _items.isNotEmpty) {
      _selectedIds.add(_items.first.id);
    }
    final providedUsedBytes = widget.usedBytes;
    if (providedUsedBytes == null) {
      _usedBytes =
          mockUsedBytes -
          mockMedia.fold<int>(0, (sum, item) => sum + item.sizeBytes) +
          _sumBytes(false);
    } else {
      _usedBytes = providedUsedBytes;
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Backlog',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Media files (previous)',
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _sortBySize ? 'Sorted by size' : 'Sorted by date',
            icon: Icon(_sortBySize ? Icons.sort : Icons.calendar_today),
            onPressed: _toggleSort,
          ),
        ],
      ),
      body: MediaFilesBody(
        visible: visible,
        usedBytes: _usedBytes,
        mediaBytes: _sumBytes(false),
        filter: _filter,
        isEmpty: _items.isEmpty,
        selectedIds: _selectedIds,
        onFilter: _setFilter,
        onSelect: _toggleSelect,
        constraint: widget.constraint,
        showConstraintError: widget.showConstraintError,
        onRestore: () => setState(() {
          _filter = null;
          if (_items.isEmpty) {
            _items.addAll(mockMedia);
            _usedBytes = mockUsedBytes;
            widget.onRestore?.call();
          }
        }),
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
