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
    return BottomAppBar(
      child: Row(
        children: [
          Expanded(child: Text('$count selected · ${formatSize(totalBytes)}')),
          TextButton(onPressed: onClear, child: const Text('Clear')),
          TextButton(onPressed: onOffload, child: const Text('Offload')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: onDelete,
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
