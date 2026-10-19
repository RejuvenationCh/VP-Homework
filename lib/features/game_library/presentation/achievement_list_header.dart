import 'package:flutter/material.dart';

class AchievementListHeader extends StatelessWidget {
  const AchievementListHeader({super.key, required this.gameName});

  final String gameName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(gameName, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Sample data', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 20),
      ],
    );
  }
}
