import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_artwork.dart';

class GameTile extends StatelessWidget {
  const GameTile({super.key, required this.game, required this.onTap});

  final Game game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String sampleLabel;
    if (game.isSample) {
      sampleLabel = 'Sample. ';
    } else {
      sampleLabel = '';
    }
    String favoriteLabel;
    if (game.isFavorite) {
      favoriteLabel = 'Favorite. ';
    } else {
      favoriteLabel = '';
    }
    Widget? favoriteIcon;
    if (game.isFavorite) {
      favoriteIcon = Icon(
        Icons.favorite,
        color: Theme.of(context).colorScheme.primary,
      );
    } else {
      favoriteIcon = null;
    }

    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      onTap: onTap,
      label:
          '$sampleLabel$favoriteLabel${game.name}. Genre: ${game.primaryGenre}. '
          'Platform: ${game.platform}. Personal status: ${game.status.label}',
      child: ListTile(
        onTap: onTap,
        leading: GameArtwork(imageUrl: game.artworkUrl),
        trailing: favoriteIcon,
        title: Text(game.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (game.isSample) const Text('Sample'),
            Text(
              'Genre: ${game.primaryGenre}\n'
              'Platform: ${game.platform}\n'
              'Personal status: ${game.status.label}',
            ),
          ],
        ),
      ),
    );
  }
}
