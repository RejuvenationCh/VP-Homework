import 'package:flutter/material.dart';

import 'game_favorite_button.dart';

class GameDetailsActions extends StatelessWidget {
  const GameDetailsActions({
    super.key,
    required this.isFavorite,
    required this.isSaving,
    required this.onFavoriteChanged,
    required this.onEdit,
    required this.onRemove,
    this.showH2Overflow = false,
  });

  final bool isFavorite;
  final bool isSaving;
  final ValueChanged<bool> onFavoriteChanged;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final bool showH2Overflow;

  @override
  Widget build(BuildContext context) {
    if (showH2Overflow) {
      return Row(
        children: [
          TextButton(
            onPressed: isSaving ? null : () => onFavoriteChanged(!isFavorite),
            child: const Text('Change favorite status'),
          ),
          TextButton(
            onPressed: isSaving ? null : onEdit,
            child: const Text('Edit game details'),
          ),
          TextButton(
            onPressed: isSaving ? null : onRemove,
            child: const Text('Remove from library'),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameFavoriteButton(
            isFavorite: isFavorite,
            isSaving: isSaving,
            onChanged: onFavoriteChanged,
          ),
          PopupMenuButton<String>(
            tooltip: 'Game options',
            enabled: !isSaving,
            onSelected: (action) {
              if (action == 'edit') {
                onEdit();
              } else {
                onRemove();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit game')),
              PopupMenuItem(
                value: 'remove',
                child: Text(
                  'Remove from library',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
