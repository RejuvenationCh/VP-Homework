import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../models/game.dart';
import 'achievement_tile.dart';

class AchievementList extends StatefulWidget {
  const AchievementList({
    super.key,
    required this.game,
    required this.achievements,
  });

  final Game game;
  final List<Achievement> achievements;

  @override
  State<AchievementList> createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Achievement> _filteredAchievements() {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.achievements;
    } else {
      return widget.achievements.where((achievement) {
        final name = achievement.name.toLowerCase();
        final description = achievement.description.toLowerCase();
        if (name.contains(query) || description.contains(query)) {
          return true;
        } else {
          return false;
        }
      }).toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _filteredAchievements();
    var itemCount = achievements.length + 2;
    if (achievements.isEmpty) {
      itemCount = 3;
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _header(context);
        } else if (index == 1) {
          return _searchField();
        } else if (achievements.isEmpty) {
          return _noResults(context);
        } else {
          return AchievementTile(achievement: achievements[index - 2]);
        }
      },
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.game.name, style: Theme.of(context).textTheme.titleLarge),
        const Align(
          alignment: Alignment.centerLeft,
          child: Chip(label: Text('Sample data')),
        ),
      ],
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search achievements',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _clearButton(),
        ),
        onChanged: (value) {
          setState(() {
            _query = value;
          });
        },
      ),
    );
  }

  Widget? _clearButton() {
    if (_query.isNotEmpty) {
      return IconButton(
        tooltip: 'Clear search',
        onPressed: _clearSearch,
        icon: const Icon(Icons.clear),
      );
    } else {
      return null;
    }
  }

  Widget _noResults(BuildContext context) {
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
          TextButton(
            onPressed: _clearSearch,
            child: const Text('Clear search'),
          ),
        ],
      ),
    );
  }
}
