import 'package:flutter/material.dart';

class GameRatingControl extends StatelessWidget {
  const GameRatingControl({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final int? rating;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final currentRating = rating;
    String ratingLabel;
    if (currentRating == null) {
      ratingLabel = 'Not rated';
    } else {
      ratingLabel = 'Rating: $currentRating out of 5';
    }

    VoidCallback? clearRating;
    final onChangedHandler = onChanged;
    if (currentRating != null && onChangedHandler != null) {
      clearRating = () => onChangedHandler(null);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your rating', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => _starButton(
                context,
                index + 1,
                currentRating,
                onChangedHandler,
              ),
            ),
          ),
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(ratingLabel, style: Theme.of(context).textTheme.bodySmall),
              if (currentRating != null)
                TextButton(
                  onPressed: clearRating,
                  child: const Text('Clear rating'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starButton(
    BuildContext context,
    int value,
    int? rating,
    ValueChanged<int?>? onChanged,
  ) {
    IconData icon;
    if (rating != null && value <= rating) {
      icon = Icons.star;
    } else {
      icon = Icons.star_border;
    }

    return IconButton(
      tooltip: 'Rate $value out of 5',
      onPressed: onChanged == null ? null : () => onChanged(value),
      icon: Icon(icon),
      color: Theme.of(context).colorScheme.primary,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}
