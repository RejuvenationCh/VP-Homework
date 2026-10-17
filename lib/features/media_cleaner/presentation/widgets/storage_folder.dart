import 'package:flutter/material.dart';

import '../../models/media_item.dart';

typedef StorageFolder = ({
  String name,
  MediaCategory category,
  int count,
  int bytes,
});

({Color fill, Color ink}) folderColors(
  ColorScheme colors,
  MediaCategory category,
) {
  switch (category) {
    case MediaCategory.video:
    case MediaCategory.screenRecording:
      return (
        fill: colors.secondaryContainer,
        ink: colors.onSecondaryContainer,
      );
    case MediaCategory.photo:
    case MediaCategory.screenshot:
      return (fill: colors.tertiaryContainer, ink: colors.onTertiaryContainer);
    case MediaCategory.duplicate:
      return (fill: colors.surfaceContainer, ink: colors.onSurfaceVariant);
  }
}
