import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import '../data/sample_achievements.dart';
import '../models/achievement_record.dart';
import '../models/game.dart';
import 'achievement_list.dart';

class GameAchievementsEntry extends StatelessWidget {
  const GameAchievementsEntry({super.key, required this.game, this.storage});

  final Game game;
  final GameLibraryStorage? storage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) =>
                GameAchievementsScreen(game: game, storage: storage),
          ),
        ),
        icon: const Icon(Icons.emoji_events_outlined),
        label: const Text('View achievements'),
      ),
    );
  }
}

class GameAchievementsScreen extends StatefulWidget {
  const GameAchievementsScreen({super.key, required this.game, this.storage});

  final Game game;
  final GameLibraryStorage? storage;

  @override
  State<GameAchievementsScreen> createState() => _GameAchievementsScreenState();
}

class _GameAchievementsScreenState extends State<GameAchievementsScreen> {
  late Future<List<AchievementRecord>> _achievements;

  @override
  void initState() {
    super.initState();
    _achievements = _loadAchievements();
  }

  Future<List<AchievementRecord>> _loadAchievements() async {
    final definitions = achievementsForGame(widget.game);
    final storage = widget.storage;
    if (storage == null) {
      return definitions
          .map(
            (achievement) => AchievementRecord(
              gameId: widget.game.id,
              achievement: achievement,
            ),
          )
          .toList();
    } else {
      return storage.loadAchievements(widget.game.id, definitions);
    }
  }

  void _retry() {
    setState(() {
      _achievements = _loadAchievements();
    });
  }

  void _back() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        child: FutureBuilder<List<AchievementRecord>>(
          future: _achievements,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _unavailable(context);
            } else {
              final records = snapshot.data;
              if (records == null || records.isEmpty) {
                return _empty(context);
              } else {
                return AchievementList(
                  game: widget.game,
                  records: records,
                  storage: widget.storage,
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return _message(
      context,
      icon: Icons.emoji_events_outlined,
      message: 'No achievements available for this game.',
      actions: [FilledButton(onPressed: _back, child: const Text('Back'))],
    );
  }

  Widget _unavailable(BuildContext context) {
    return _message(
      context,
      icon: Icons.cloud_off_outlined,
      message: 'Achievements are unavailable.',
      actions: [
        FilledButton(onPressed: _retry, child: const Text('Retry')),
        TextButton(onPressed: _back, child: const Text('Back')),
      ],
    );
  }

  Widget _message(
    BuildContext context, {
    required IconData icon,
    required String message,
    required List<Widget> actions,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: actions),
          ],
        ),
      ),
    );
  }
}
