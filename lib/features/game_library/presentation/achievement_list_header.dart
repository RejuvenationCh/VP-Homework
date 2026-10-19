import 'package:flutter/material.dart';

class AchievementListHeader extends StatelessWidget {
  const AchievementListHeader({super.key, required this.gameName});

  final String gameName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(gameName, style: Theme.of(context).textTheme.titleLarge),
        const Align(
          alignment: Alignment.centerLeft,
          child: Chip(label: Text('Sample data')),
        ),
      ],
    );
  }
}
