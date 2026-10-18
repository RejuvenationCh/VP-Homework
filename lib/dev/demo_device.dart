import 'package:flutter/material.dart';

enum DemoDevice {
  small('Small phone', Size(320, 568)),
  large('Large phone', Size(430, 932)),
  tablet('Tablet', Size(800, 1280));

  const DemoDevice(this.label, this.size);
  final String label;
  final Size size;
}

enum DemoScreen {
  library('Library'),
  retry('Retry demo'),
  overview('Storage overview'),
  files('File manager');

  const DemoScreen(this.label);
  final String label;
}
