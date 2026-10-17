import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/media_item.dart';
import 'storage_folder.dart';

class FolderMap extends StatelessWidget {
  final List<StorageFolder> folders;
  final ValueChanged<MediaCategory> onOpen;

  const FolderMap({super.key, required this.folders, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final visible = folders.where((folder) => folder.bytes > 0).toList();
    final theme = Theme.of(context);
    // shortcut: five fixed slots for demo folders; pack dynamically when real folders are added
    const centers = [
      Offset(.36, .43),
      Offset(.82, .28),
      Offset(.82, .67),
      Offset(.60, .85),
      Offset(.26, .85),
    ];
    const slotDiameters = [.64, .32, .26, .24, .22];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 440.0);
        final largest = width * .64;
        return Align(
          child: SizedBox(
            width: width,
            height: width,
            child: Stack(
              children: [
                for (var i = 0; i < visible.length; i++)
                  Builder(
                    builder: (context) {
                      final folder = visible[i];
                      final diameter = math.max(
                        48.0,
                        math.min(
                          width * slotDiameters[i],
                          largest *
                              math.sqrt(folder.bytes / visible.first.bytes),
                        ),
                      );
                      final palette = folderColors(
                        theme.colorScheme,
                        folder.category,
                      );
                      return Positioned(
                        left: centers[i].dx * width - diameter / 2,
                        top: centers[i].dy * width - diameter / 2,
                        width: diameter,
                        height: diameter,
                        child: Tooltip(
                          message:
                              '${folder.name} · ${formatSize(folder.bytes)}',
                          child: Semantics(
                            label:
                                '${folder.name}, ${formatSize(folder.bytes)}, ${folder.count} files',
                            button: true,
                            child: ExcludeSemantics(
                              child: Material(
                                color: palette.fill,
                                shape: CircleBorder(
                                  side: BorderSide(
                                    color: palette.ink.withValues(alpha: .25),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => onOpen(folder.category),
                                  child: Center(
                                    child:
                                        diameter >= 100 &&
                                            MediaQuery.textScalerOf(context)
                                                    .scale(1) <=
                                                1.3
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.folder,
                                                color: palette.ink,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                folder.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      color: palette.ink,
                                                    ),
                                              ),
                                              Text(
                                                formatSize(folder.bytes),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: palette.ink,
                                                    ),
                                              ),
                                            ],
                                          )
                                        : Icon(
                                            Icons.folder,
                                            color: palette.ink,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
