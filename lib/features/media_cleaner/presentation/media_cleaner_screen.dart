import 'package:flutter/material.dart';

import '../data/mock_media.dart';
import '../models/media_item.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/media_tile.dart';
import 'widgets/selection_action_bar.dart';
import 'widgets/storage_summary_header.dart';

class MediaCleanerScreen extends StatefulWidget {
  final List<MediaItem>? items;
  final MediaCategory? initialCategory;
  final int usedBytes;
  final ValueChanged<Set<String>>? onRemoved;

  const MediaCleanerScreen({
    super.key,
    this.items,
    this.initialCategory,
    this.usedBytes = mockUsedBytes,
    this.onRemoved,
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
    _usedBytes = widget.usedBytes;
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
      body: Column(
        children: [
          StorageSummaryHeader(
            usedBytes: _usedBytes,
            totalBytes: mockTotalBytes,
            mediaBytes: _sumBytes(false),
          ),
          CategoryFilterChips(selected: _filter, onSelected: _setFilter),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('No media'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (context, i) => MediaTile(
                      item: visible[i],
                      isSelected: _selectedIds.contains(visible[i].id),
                      onTap: () => _toggleSelect(visible[i].id),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedIds.isEmpty
          ? null
          : SelectionActionBar(
              count: _selectedIds.length,
              totalBytes: _sumBytes(true),
              onDelete: _deleteSelected,
              onOffload: _offloadSelected,
              onClear: _clearSelection,
            ),
    );
  }
}
