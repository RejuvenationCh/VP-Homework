import 'package:flutter/material.dart';

import '../../data/game_library_storage.dart';
import '../../data/steam_achievement_loader.dart';
import '../../data/steam_api_parser.dart';
import '../../models/achievement.dart';
import '../../models/game.dart';
import '../widgets/achievement_list.dart';
import '../widgets/game_page_body.dart';

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
  const GameAchievementsScreen({
    super.key,
    required this.game,
    this.storage,
    this.fixtureAchievements,
  });

  final Game game;
  final GameLibraryStorage? storage;
  final List<Achievement>? fixtureAchievements;

  @override
  State<GameAchievementsScreen> createState() => _GameAchievementsScreenState();
}

class _GameAchievementsScreenState extends State<GameAchievementsScreen> {
  late Future<AchievementLoadResult> _achievements;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _achievements = _loadAchievements();
  }

  Future<AchievementLoadResult> _loadAchievements() async {
    try {
      return await loadGameAchievements(
        game: widget.game,
        storage: widget.storage,
        fixtures: widget.fixtureAchievements,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _retry() {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _achievements = _loadAchievements();
    });
  }

  void _back() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _retry,
            tooltip: 'Refresh achievements',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: GamePageBody(
          maxWidth: 800,
          child: FutureBuilder<AchievementLoadResult>(
            future: _achievements,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return _unavailable(context, snapshot.error);
              } else {
                final result = snapshot.data;
                final records = result?.records;
                if (records == null || records.isEmpty) {
                  return _empty(context);
                } else {
                  return Column(
                    children: [
                      if (result?.warning != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                result!.warning!,
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                onPressed: _retry,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: AchievementList(
                          game: widget.game,
                          records: records,
                          storage: widget.storage,
                        ),
                      ),
                    ],
                  );
                }
              }
            },
          ),
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

  Widget _unavailable(BuildContext context, Object? error) {
    var message = 'Achievements are unavailable.';
    if (error is SteamApiException) message = error.message;
    return _message(
      context,
      icon: Icons.cloud_off_outlined,
      message: message,
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
