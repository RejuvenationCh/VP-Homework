import 'package:flutter/material.dart';

import '../../models/media_item.dart';

class CategoryFilterChips extends StatelessWidget {
  final MediaCategory? selected;
  final ValueChanged<MediaCategory?> onSelected;
  final bool wrap;

  const CategoryFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = [
      ChoiceChip(
        label: const Text('All'),
        selected: selected == null,
        onSelected: (_) => onSelected(null),
      ),
    ];
    // one chip for every category
    for (final c in MediaCategory.values) {
      chips.add(
        ChoiceChip(
          label: Text(
            categoryLabel(c),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          selected: selected == c,
          onSelected: (_) => onSelected(c),
        ),
      );
    }
    if (wrap) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(spacing: 8, runSpacing: 8, children: chips),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(spacing: 8, children: chips),
    );
  }
}
