import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/steam_guide_lookup.dart';
import '../data/steam_api_parser.dart';
import '../models/achievement.dart';
import '../models/game.dart';
import 'achievement_guide_not_found.dart';

class AchievementGuideButton extends StatefulWidget {
  const AchievementGuideButton({
    super.key,
    required this.game,
    required this.achievement,
  });

  final Game game;
  final Achievement achievement;

  @override
  State<AchievementGuideButton> createState() => _AchievementGuideButtonState();
}

class _AchievementGuideButtonState extends State<AchievementGuideButton> {
  bool _isLoading = false;

  Future<void> _findGuide() async {
    setState(() => _isLoading = true);
    try {
      final guide = await findAchievementGuide(
        game: widget.game,
        achievementName: widget.achievement.name,
      );
      if (!mounted) return;
      if (guide == null) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => AchievementGuideNotFound(
              game: widget.game,
              achievement: widget.achievement,
            ),
          ),
        );
      } else {
        final opened = await launchUrl(
          guide,
          mode: LaunchMode.externalApplication,
        );
        if (!opened && mounted) _showError();
      }
    } on SteamApiException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError([
    String message = 'Guide search is unavailable. Try again.',
  ]) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _isLoading ? null : _findGuide,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.open_in_new, size: 18),
      label: const Text('Guide'),
    );
  }
}
