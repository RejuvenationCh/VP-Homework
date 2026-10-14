import 'package:flutter/material.dart';

import '../../models/media_item.dart';
import 'size_badge.dart';

class MediaTile extends StatelessWidget {
  final MediaItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showNameOverflow;

  const MediaTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.showNameOverflow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = theme.cardTheme.shape! as RoundedRectangleBorder;
    return Semantics(
      label: '${item.name}, ${formatSize(item.sizeBytes)}',
      checked: isSelected,
      onTap: onTap,
      excludeSemantics: true,
      child: Card(
        shape: shape.copyWith(
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: ExcludeFocus(
                    child: SizedBox.square(
                      dimension: 24,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onTap(),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Icon(categoryIcon(item.category), size: 32),
                  ),
                ),
                // H2 deliberately removes the filename's width constraint.
                if (showNameOverflow)
                  Row(children: [Text(item.name)])
                else
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                SizeBadge(bytes: item.sizeBytes),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
