import 'package:flutter/material.dart';

import '../../data/game_library_storage.dart';
import '../../models/game.dart';
import '../../models/achievement_record.dart';
import './achievement_list_header.dart';
import '../helpers/achievement_filtering.dart';
import './achievement_no_results.dart';
import '../helpers/achievement_notes_editor.dart';
import '../helpers/achievement_personal_data_save.dart';
import './achievement_progress_filter_section.dart';
import './achievement_progress_filter.dart';
import './achievement_search_field.dart';
import './achievement_tile.dart';

class AchievementList extends StatefulWidget {
  const AchievementList({
    super.key,
    required this.game,
    required this.records,
    this.storage,
  });
  final Game game;
  final List<AchievementRecord> records;
  final GameLibraryStorage? storage;
  @override
  State<AchievementList> createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  final _searchController = TextEditingController();
  final Set<String> _trackedAchievementIds = {};
  final Map<String, String> _notesByAchievementId = {};
  bool _isSavingPersonalData = false;
  late List<AchievementRecord> _personalBaseline;
  String _query = '';
  AchievementProgressFilter _progressFilter = AchievementProgressFilter.all;
  @override
  void initState() {
    super.initState();
    _personalBaseline = widget.records;
    applySavedAchievementPersonalData(
      widget.records,
      _trackedAchievementIds,
      _notesByAchievementId,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AchievementRecord> _filteredAchievements() => filterAchievementRecords(
    records: widget.records,
    query: _query,
    progressFilter: _progressFilter,
    trackedAchievementIds: _trackedAchievementIds,
  );
  Future<void> _toggleTracked(AchievementRecord record) async {
    if (_isSavingPersonalData) return;
    final achievementId = record.achievement.id;
    final wasTracked = _trackedAchievementIds.contains(achievementId);
    setState(() {
      if (wasTracked) {
        _trackedAchievementIds.remove(achievementId);
      } else {
        _trackedAchievementIds.add(achievementId);
      }
    });
    final saved = await _savePersonalData();
    if (!saved && mounted) {
      setState(() {
        if (wasTracked) {
          _trackedAchievementIds.add(achievementId);
        } else {
          _trackedAchievementIds.remove(achievementId);
        }
      });
    }
  }

  Future<void> _editNotes(AchievementRecord record) async {
    final achievement = record.achievement;
    var notes = '';
    if (_notesByAchievementId.containsKey(achievement.id)) {
      notes = _notesByAchievementId[achievement.id]!;
    }
    await openAchievementNotes(
      context: context,
      title: '${achievement.name} notes',
      notes: notes,
      description: achievement.description,
      onSave: (value) async {
        _notesByAchievementId[achievement.id] = value;
        final saved = await _savePersonalData();
        if (!saved) {
          if (notes.isEmpty) {
            _notesByAchievementId.remove(achievement.id);
          } else {
            _notesByAchievementId[achievement.id] = notes;
          }
          if (mounted) setState(() {});
          return false;
        } else if (mounted) {
          setState(() {});
          return true;
        } else {
          return false;
        }
      },
    );
  }

  Future<bool> _savePersonalData() async {
    if (_isSavingPersonalData) return false;
    return saveAchievementPersonalData(
      context: context,
      storage: widget.storage,
      gameId: widget.game.id,
      records: _personalBaseline,
      trackedAchievementIds: _trackedAchievementIds,
      notesByAchievementId: _notesByAchievementId,
      onSaved: (records) {
        _personalBaseline = records;
        applySavedAchievementPersonalData(
          records,
          _trackedAchievementIds,
          _notesByAchievementId,
        );
      },
      onSavingChanged: (value) {
        if (mounted) setState(() => _isSavingPersonalData = value);
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _updateQuery(String value) => setState(() => _query = value);
  void _showAllAchievements() {
    _clearSearch();
    setState(() => _progressFilter = AchievementProgressFilter.all);
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredAchievements();
    var itemCount = records.length + 3;
    if (records.isEmpty) {
      itemCount = 4;
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return AchievementListHeader(game: widget.game);
        } else if (index == 1) {
          return AchievementSearchField(
            controller: _searchController,
            query: _query,
            onChanged: _updateQuery,
            onClear: _clearSearch,
          );
        } else if (index == 2) {
          return AchievementProgressFilterSection(
            selectedFilter: _progressFilter,
            onSelected: (filter) {
              setState(() => _progressFilter = filter);
            },
          );
        } else if (records.isEmpty) {
          return AchievementNoResults(
            showClearSearch: _query.trim().isNotEmpty,
            onClearSearch: _clearSearch,
            onShowAll: _showAllAchievements,
          );
        } else {
          final record = records[index - 3];
          final achievement = record.achievement;
          return AchievementTile(
            game: widget.game,
            achievement: achievement,
            isTracked: _trackedAchievementIds.contains(achievement.id),
            isSaving: _isSavingPersonalData,
            onTrackChanged: () => _toggleTracked(record),
            notes: _notesByAchievementId[achievement.id],
            onNotesTap: () => _editNotes(record),
          );
        }
      },
    );
  }
}
