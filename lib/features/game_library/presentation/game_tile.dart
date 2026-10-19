import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_artwork.dart';
import 'game_status_badge.dart';

class GameTile extends StatelessWidget {
  const GameTile({
    super.key,
    required this.game,
    required this.onTap,
    this.showNameOverflow = false,
  });

  final Game game;
  final VoidCallback onTap;
  final bool showNameOverflow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var sampleLabel = '';
    var favoriteLabel = '';
    if (game.isSample) sampleLabel = 'Sample. ';
    if (game.isFavorite) favoriteLabel = 'Favorite. ';
    Widget title;
    if (showNameOverflow) {
      title = Row(children: [Text(game.name)]);
    } else {
      title = Text(
        game.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium,
      );
    }
    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      onTap: onTap,
      label:
          '$sampleLabel$favoriteLabel${game.name}. Genre: ${game.primaryGenre}. '
          'Platform: ${game.platform}. Personal status: ${game.status.label}',
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: GameArtwork(
                      imageUrl: game.artworkUrl,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  if (game.isFavorite)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.surface,
                        child: Icon(
                          Icons.favorite,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 4),
                    Text(
                      '${game.primaryGenre} · ${game.platform}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        GameStatusBadge(status: game.status),
                        if (game.isSample)
                          Text('Sample', style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
