import 'package:flutter/material.dart';

class GameFavoriteButton extends StatefulWidget {
  const GameFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onChanged,
  });

  final bool isFavorite;
  final ValueChanged<bool> onChanged;

  @override
  State<GameFavoriteButton> createState() => _GameFavoriteButtonState();
}

class _GameFavoriteButtonState extends State<GameFavoriteButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggle() {
    bool favorite;
    if (_isFavorite) {
      favorite = false;
    } else {
      favorite = true;
    }
    setState(() => _isFavorite = favorite);
    widget.onChanged(favorite);
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String tooltip;
    if (_isFavorite) {
      icon = Icons.favorite;
      tooltip = 'Remove from favorites';
    } else {
      icon = Icons.favorite_border;
      tooltip = 'Add to favorites';
    }
    return IconButton(
      tooltip: tooltip,
      onPressed: _toggle,
      icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
    );
  }
}
