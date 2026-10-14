import 'package:flutter/material.dart';

import '../../models/media_item.dart';

class SelectionActionBar extends StatelessWidget {
  final int count;
  final int totalBytes;
  final VoidCallback onDelete;
  final VoidCallback onOffload;
  final VoidCallback onClear;

  const SelectionActionBar({
    super.key,
    required this.count,
    required this.totalBytes,
    required this.onDelete,
    required this.onOffload,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final summary = Text(
                '$count selected · ${formatSize(totalBytes)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );
              final actions = Wrap(
                spacing: 4,
                children: [
                  TextButton(onPressed: onClear, child: const Text('Clear')),
                  TextButton(
                    onPressed: onOffload,
                    child: const Text('Offload'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                    ),
                    onPressed: onDelete,
                    child: const Text('Delete'),
                  ),
                ],
              );
              return constraints.maxWidth < 398
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [summary, actions],
                    )
                  : Row(
                      children: [
                        Expanded(child: summary),
                        actions,
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
