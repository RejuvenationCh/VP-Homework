import 'package:flutter/material.dart';

import 'constraint_scenario.dart';
import 'demo_device.dart';
import 'harness_control_group.dart';

class HarnessScenarioControls extends StatelessWidget {
  const HarnessScenarioControls({
    super.key,
    required this.page,
    required this.constraint,
    required this.showFix,
    required this.onScreen,
    required this.onConstraint,
    required this.onFix,
  });

  final DemoScreen page;
  final ConstraintCase? constraint;
  final bool showFix;
  final ValueChanged<DemoScreen> onScreen;
  final ValueChanged<ConstraintCase?> onConstraint;
  final ValueChanged<bool> onFix;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      HarnessControlGroup('Screen', [
        for (final screen in DemoScreen.values)
          ChoiceChip(
            label: Text(screen.label),
            selected: page == screen,
            onSelected: (_) => onScreen(screen),
          ),
      ]),
      HarnessControlGroup('H2 errors on the file manager', [
        ChoiceChip(
          label: const Text('Off'),
          selected: constraint == null,
          onSelected: (_) => onConstraint(null),
        ),
        for (final fault in ConstraintCase.values)
          ChoiceChip(
            label: Text(fault.label),
            selected: constraint == fault,
            onSelected: (_) => onConstraint(fault),
          ),
      ]),
      if (constraint != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show fix'),
          value: showFix,
          onChanged: onFix,
        ),
    ],
  );
}
