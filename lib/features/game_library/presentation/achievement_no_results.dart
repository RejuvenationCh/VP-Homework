import 'package:flutter/material.dart';

class AchievementNoResults extends StatelessWidget {
  const AchievementNoResults({
    super.key,
    required this.showClearSearch,
    required this.onClearSearch,
    required this.onShowAll,
  });

  final bool showClearSearch;
  final VoidCallback onClearSearch;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          const Text('No achievements found.'),
          if (showClearSearch)
            TextButton(
              onPressed: onClearSearch,
              child: const Text('Clear search'),
            ),
          TextButton(
            onPressed: onShowAll,
            child: const Text('Show all achievements'),
          ),
        ],
      ),
    );
  }
}
