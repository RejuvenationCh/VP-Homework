import 'package:flutter/material.dart';

import '../../../game_status_theme.dart';
import '../models/game.dart';

Color gameStatusColor(GameStatus status, ThemeData theme) {
  final configured = theme.extension<GameStatusTheme>();
  final GameStatusTheme colors;
  if (configured != null) {
    colors = configured;
  } else {
    colors = GameStatusTheme.forBrightness(theme.brightness);
  }
  if (status == GameStatus.backlog) {
    return colors.toPlay;
  } else if (status == GameStatus.playing) {
    return colors.playing;
  } else if (status == GameStatus.finished) {
    return colors.finished;
  } else {
    return colors.dropped;
  }
}
