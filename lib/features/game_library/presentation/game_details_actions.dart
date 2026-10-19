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
  });

  final bool isFavorite;
  final bool isSaving;
  final ValueChanged<bool> onFavoriteChanged;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameFavoriteButton(
          isFavorite: isFavorite,
          isSaving: isSaving,
          onChanged: onFavoriteChanged,
        ),
        IconButton(
          tooltip: 'Edit game',
          onPressed: isSaving ? null : onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Remove from library',
          onPressed: isSaving ? null : onRemove,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
