import 'package:flutter/material.dart';

enum AchievementProgressFilter { all, unlocked, locked, tracked }

class AchievementProgressFilterSelector extends StatelessWidget {
  const AchievementProgressFilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  final AchievementProgressFilter selectedFilter;
  final ValueChanged<AchievementProgressFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _chip(AchievementProgressFilter.all, 'All'),
        _chip(AchievementProgressFilter.unlocked, 'Unlocked'),
        _chip(AchievementProgressFilter.locked, 'Locked'),
        _chip(AchievementProgressFilter.tracked, 'Tracked'),
      ],
    );
  }

  Widget _chip(AchievementProgressFilter filter, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedFilter == filter,
      onSelected: (selected) {
        if (selected) {
          onSelected(filter);
        }
      },
    );
  }
}
