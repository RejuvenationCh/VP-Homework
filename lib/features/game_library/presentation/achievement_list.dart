import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../models/game.dart';
import 'achievement_list_header.dart';
import 'achievement_no_results.dart';
import 'achievement_progress_filter.dart';
import 'achievement_search_field.dart';
import 'achievement_tile.dart';
import 'game_notes_screen.dart';

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
  final Set<String> _trackedAchievementIds = {};
  final Map<String, String> _notesByAchievementId = {};
  String _query = '';
  AchievementProgressFilter _progressFilter = AchievementProgressFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Achievement> _filteredAchievements() {
    final query = _query.trim().toLowerCase();
    return widget.achievements.where((achievement) {
      if (_progressFilter == AchievementProgressFilter.tracked) {
        if (!_trackedAchievementIds.contains(achievement.id)) {
          return false;
        }
      } else if (_progressFilter == AchievementProgressFilter.unlocked) {
        if (achievement.progress != AchievementProgress.unlocked) {
          return false;
        }
      } else if (_progressFilter == AchievementProgressFilter.locked) {
        if (achievement.progress != AchievementProgress.locked) {
          return false;
        }
      }
      if (query.isEmpty) {
        return true;
      } else {
        final name = achievement.name.toLowerCase();
        final description = achievement.description.toLowerCase();
        if (name.contains(query) || description.contains(query)) {
          return true;
        } else {
          return false;
        }
      }
    }).toList();
  }

  void _toggleTracked(Achievement achievement) {
    setState(() {
      if (_trackedAchievementIds.contains(achievement.id)) {
        _trackedAchievementIds.remove(achievement.id);
      } else {
        _trackedAchievementIds.add(achievement.id);
      }
    });
  }

  Future<void> _editNotes(Achievement achievement) async {
    var notes = '';
    if (_notesByAchievementId.containsKey(achievement.id)) {
      notes = _notesByAchievementId[achievement.id]!;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => GameNotesScreen(
          title: '${achievement.name} notes',
          initialNotes: notes,
          description: achievement.description,
          onSave: (value) async {
            setState(() => _notesByAchievementId[achievement.id] = value);
            return true;
          },
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  void _updateQuery(String value) {
    setState(() {
      _query = value;
    });
  }

  void _showAllAchievements() {
    _searchController.clear();
    setState(() {
      _query = '';
      _progressFilter = AchievementProgressFilter.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _filteredAchievements();
    var itemCount = achievements.length + 3;
    if (achievements.isEmpty) {
      itemCount = 4;
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return AchievementListHeader(gameName: widget.game.name);
        } else if (index == 1) {
          return _progressFilterSelector();
        } else if (index == 2) {
          return AchievementSearchField(
            controller: _searchController,
            query: _query,
            onChanged: _updateQuery,
            onClear: _clearSearch,
          );
        } else if (achievements.isEmpty) {
          return AchievementNoResults(
            showClearSearch: _query.trim().isNotEmpty,
            onClearSearch: _clearSearch,
            onShowAll: _showAllAchievements,
          );
        } else {
          final achievement = achievements[index - 3];
          return AchievementTile(
            achievement: achievement,
            isTracked: _trackedAchievementIds.contains(achievement.id),
            onTrackChanged: () => _toggleTracked(achievement),
            notes: _notesByAchievementId[achievement.id],
            onNotesTap: () => _editNotes(achievement),
          );
        }
      },
    );
  }

  Widget _progressFilterSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AchievementProgressFilterSelector(
        selectedFilter: _progressFilter,
        onSelected: (filter) {
          setState(() {
            _progressFilter = filter;
          });
        },
      ),
    );
  }
}
