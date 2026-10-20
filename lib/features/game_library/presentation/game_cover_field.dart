import 'package:flutter/material.dart';

class GameCoverField extends StatelessWidget {
  const GameCoverField({
    super.key,
    required this.controller,
    required this.enabled,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: TextInputType.url,
    textInputAction: TextInputAction.done,
    autocorrect: false,
    scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
    decoration: const InputDecoration(
      labelText: 'Cover image URL',
      helperText:
          'Optional. Leave empty to use the Steam cover when available.',
      helperMaxLines: 2,
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) return null;
      final uri = Uri.tryParse(value.trim());
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty) {
        return 'Enter a valid HTTPS image URL';
      } else {
        return null;
      }
    },
  );
}
