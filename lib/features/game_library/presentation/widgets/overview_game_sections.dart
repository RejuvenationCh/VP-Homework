import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/game.dart';
import './game_tile.dart';

class OverviewGameSections extends StatelessWidget {
  const OverviewGameSections({
    super.key,
    required this.games,
    required this.onGameSelected,
  });

  final List<Game> games;
  final ValueChanged<Game> onGameSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final pinned = _pinnedSection(context);
      final playing = _playingSection(context);
      if (constraints.maxWidth >= 760) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: pinned),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: playing),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [pinned, const SizedBox(height: 28), playing],
        );
      }
    },
  );

  Widget _pinnedSection(BuildContext context) {
    Game? pinned;
    for (final game in games) {
      if (game.isPlayNext) {
        pinned = game;
        break;
      }
    }
    Widget content;
    if (pinned == null) {
      content = _empty(
        'No game pinned for next',
        'Choose Play next in a game’s details.',
        Icons.push_pin_outlined,
      );
    } else {
      final game = pinned;
      content = GameTile(game: game, onTap: () => onGameSelected(game));
    }
    return _section(context, 'Play next', content);
  }

  Widget _playingSection(BuildContext context) {
    final playing = games
        .where((game) => game.status == GameStatus.playing)
        .toList();
    Widget content;
    if (playing.isEmpty) {
      content = _empty(
        'No games currently playing',
        'Set a game’s status to Playing to keep it here.',
        Icons.play_circle_outline,
      );
    } else {
      content = LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(280.0, constraints.maxWidth * .9);
          final height =
              width * 9 / 16 + MediaQuery.textScalerOf(context).scale(132);
          return SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: playing.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) => SizedBox(
                width: width,
                child: GameTile(
                  game: playing[index],
                  onTap: () => onGameSelected(playing[index]),
                ),
              ),
            ),
          );
        },
      );
    }
    return _section(context, 'Currently playing', content);
  }

  Widget _section(BuildContext context, String title, Widget content) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      content,
    ],
  );

  Widget _empty(String title, String subtitle, IconData icon) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
  );
}
