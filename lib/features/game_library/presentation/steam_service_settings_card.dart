import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import '../data/steam_api_parser.dart';
import '../data/steam_service_configuration.dart';

class SteamServiceSettingsCard extends StatefulWidget {
  const SteamServiceSettingsCard({super.key, required this.storage});

  final GameLibraryStorage storage;

  @override
  State<SteamServiceSettingsCard> createState() =>
      _SteamServiceSettingsCardState();
}

class _SteamServiceSettingsCardState extends State<SteamServiceSettingsCard> {
  final _controller = TextEditingController();
  bool _busy = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final saved = await widget.storage.loadSteamServiceUrl();
      if (!mounted) return;
      if (saved != null) _controller.text = saved;
    } catch (_) {
      if (mounted) _message = 'Could not load the Steam service URL.';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save({bool reset = false}) async {
    setState(() => _busy = true);
    try {
      String? value;
      if (!reset) value = validateSteamServiceUrl(_controller.text);
      await widget.storage.saveSteamServiceUrl(value);
      if (!mounted) return;
      if (reset) _controller.clear();
      setState(() {
        if (reset) {
          _message = 'Using the build default, if one is configured.';
        } else {
          _message = 'Steam service saved.';
        }
      });
    } on SteamApiException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (_) {
      if (mounted) setState(() => _message = 'Could not save the service URL.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Steam service',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the HTTPS address of your Steam service. Keep the Steam API key on the service.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              enabled: !_busy,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Service URL',
                hintText: 'https://your-worker.workers.dev',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: const Text('Save URL'),
                ),
                TextButton(
                  onPressed: _busy ? null : () => _save(reset: true),
                  child: const Text('Reset URL'),
                ),
              ],
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!),
            ],
          ],
        ),
      ),
    );
  }
}
