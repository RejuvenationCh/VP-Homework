import 'dart:math' as math;

import 'package:flutter/material.dart';

class GenreBubbleMap extends StatelessWidget {
  const GenreBubbleMap({
    super.key,
    required this.counts,
    required this.onSelected,
  });

  final Map<String, int> counts;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final entries = counts.entries.toList();
    entries.sort((first, second) {
      final byCount = second.value.compareTo(first.value);
      if (byCount == 0) {
        return first.key.compareTo(second.key);
      } else {
        return byCount;
      }
    });

    final colors = Theme.of(context).colorScheme;
    final fills = [
      colors.primaryContainer,
      colors.secondaryContainer,
      colors.tertiaryContainer,
    ];
    final inks = [
      colors.onPrimaryContainer,
      colors.onSecondaryContainer,
      colors.onTertiaryContainer,
    ];
    final titleFontSize = Theme.of(context).textTheme.titleSmall?.fontSize;
    double baseFontSize;
    if (titleFontSize == null) {
      baseFontSize = 14;
    } else {
      baseFontSize = titleFontSize;
    }
    final textScale =
        MediaQuery.textScalerOf(context).scale(baseFontSize) / baseFontSize;
    final availableWidth = MediaQuery.sizeOf(context).width - 64;
    double widthRatio = .56;
    double minRatio = .72;
    if (textScale > 1) {
      widthRatio += (textScale - 1) * .22;
      minRatio += (textScale - 1) * .14;
    }
    if (widthRatio > 1) {
      widthRatio = 1;
    }
    if (minRatio > .96) {
      minRatio = .96;
    }
    final maxDiameter = math.min(280 * textScale, availableWidth * widthRatio);
    final minDiameter = math.min(104 * textScale, maxDiameter * minRatio);
    final largestCount = entries.first.value;
    final bubbles = <Widget>[];

    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final countRoot = math.sqrt(entry.value.toDouble());
      final largestRoot = math.sqrt(largestCount.toDouble());
      double proportion;
      if (largestCount == 1) {
        proportion = .55;
      } else {
        proportion = (countRoot - 1) / (largestRoot - 1);
      }
      final diameter = minDiameter + (maxDiameter - minDiameter) * proportion;
      final colorIndex = index % fills.length;
      bubbles.add(
        _GenreBubble(
          genre: entry.key,
          count: entry.value,
          diameter: diameter,
          fill: fills[colorIndex],
          ink: inks[colorIndex],
          onTap: () => onSelected(entry.key),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: bubbles,
    );
  }
}

class _GenreBubble extends StatelessWidget {
  const _GenreBubble({
    required this.genre,
    required this.count,
    required this.diameter,
    required this.fill,
    required this.ink,
    required this.onTap,
  });

  final String genre;
  final int count;
  final double diameter;
  final Color fill;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String countLabel;
    if (count == 1) {
      countLabel = '1 game';
    } else {
      countLabel = '$count games';
    }
    return Semantics(
      label: '$genre, $countLabel',
      button: true,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Tooltip(
          message: '$genre · $countLabel',
          child: SizedBox.square(
            dimension: diameter,
            child: Material(
              color: fill,
              shape: CircleBorder(
                side: BorderSide(color: ink.withValues(alpha: .25)),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(diameter * .08),
                    child: SizedBox(
                      width: diameter * .84,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            genre,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: ink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
