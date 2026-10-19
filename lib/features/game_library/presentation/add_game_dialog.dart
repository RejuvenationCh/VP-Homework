import 'package:flutter/material.dart';

class AddGameDialog extends StatefulWidget {
  const AddGameDialog({super.key});

  @override
  State<AddGameDialog> createState() => _AddGameDialogState();
}

class _AddGameDialogState extends State<AddGameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitted || !_formKey.currentState!.validate()) {
      return;
    }
    _submitted = true;
    Navigator.of(context).pop(_title.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add game'),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _title,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Game title'),
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter a game title';
            } else {
              return null;
            }
          },
          onFieldSubmitted: (value) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
