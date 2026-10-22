import 'package:flutter/material.dart';

import './achievement_progress_filter.dart';

class AchievementProgressFilterSection extends StatelessWidget {
  const AchievementProgressFilterSection({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  final AchievementProgressFilter selectedFilter;
  final ValueChanged<AchievementProgressFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AchievementProgressFilterSelector(
        selectedFilter: selectedFilter,
        onSelected: onSelected,
      ),
    );
  }
}
