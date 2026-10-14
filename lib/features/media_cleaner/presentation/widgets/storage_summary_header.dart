import 'package:flutter/material.dart';

import '../../models/media_item.dart';
import 'size_badge.dart';

class StorageSummaryHeader extends StatelessWidget {
  final int usedBytes;
  final int totalBytes;
  final int mediaBytes;

  const StorageSummaryHeader({
    super.key,
    required this.usedBytes,
    required this.totalBytes,
    required this.mediaBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatSize(usedBytes)} of ${formatSize(totalBytes)} used',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: usedBytes / totalBytes),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Media: '),
              SizeBadge(bytes: mediaBytes),
            ],
          ),
        ],
      ),
    );
  }
}
