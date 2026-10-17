import 'package:flutter/material.dart';

import '../../../../dev/constraint_scenario.dart';
import '../../data/mock_media.dart';
import '../../models/media_item.dart';
import 'category_filter_chips.dart';
import 'media_empty_state.dart';
import 'media_tile.dart';
import 'storage_summary_header.dart';

class MediaFilesBody extends StatelessWidget {
  const MediaFilesBody({
    super.key,
    required this.visible,
    required this.usedBytes,
    required this.mediaBytes,
    required this.filter,
    required this.isEmpty,
    required this.selectedIds,
    required this.onFilter,
    required this.onRestore,
    required this.onSelect,
    required this.constraint,
    required this.showConstraintError,
  });

  final List<MediaItem> visible;
  final int usedBytes;
  final int mediaBytes;
  final MediaCategory? filter;
  final bool isEmpty;
  final Set<String> selectedIds;
  final ValueChanged<MediaCategory?> onFilter;
  final VoidCallback onRestore;
  final ValueChanged<String> onSelect;
  final ConstraintCase? constraint;
  final bool showConstraintError;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 700;
          final header = Column(
            children: [
              StorageSummaryHeader(
                usedBytes: usedBytes,
                totalBytes: mockTotalBytes,
                mediaBytes: mediaBytes,
              ),
              CategoryFilterChips(
                selected: filter,
                onSelected: onFilter,
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
                    message: isEmpty
                        ? 'No media left. All demo files have been removed.'
                        : 'No files in this category.',
                    actionLabel: isEmpty
                        ? 'Restore demo files'
                        : 'Show all files',
                    onAction: onRestore,
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
                            showConstraintError &&
                                constraint == ConstraintCase.shortTile
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
                            showConstraintError &&
                            constraint == ConstraintCase.longName,
                        isSelected: selectedIds.contains(visible[i].id),
                        onTap: () => onSelect(visible[i].id),
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
    );
  }
}
