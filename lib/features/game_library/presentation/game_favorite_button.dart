import 'package:flutter/material.dart';

class GameFavoriteButton extends StatelessWidget {
  const GameFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.isSaving,
    required this.onChanged,
  });

  final bool isFavorite;
  final bool isSaving;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String tooltip;
    if (isFavorite) {
      icon = Icons.favorite;
      tooltip = 'Remove from favorites';
    } else {
      icon = Icons.favorite_border;
      tooltip = 'Add to favorites';
    }
    return IconButton(
      tooltip: tooltip,
      onPressed: isSaving ? null : () => onChanged(!isFavorite),
      icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
    );
  }
}
