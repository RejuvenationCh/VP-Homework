import 'package:flutter/material.dart';

class AchievementSearchField extends StatelessWidget {
  const AchievementSearchField({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    Widget? clearButton;
    if (query.isNotEmpty) {
      clearButton = IconButton(
        tooltip: 'Clear search',
        onPressed: onClear,
        icon: const Icon(Icons.clear),
      );
    } else {
      clearButton = null;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Search achievements',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: clearButton,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
