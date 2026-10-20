import 'package:flutter/material.dart';

import '../data/game_library_storage.dart';
import '../data/steam_api_client.dart';
import '../data/steam_api_parser.dart';
import '../data/steam_service_configuration.dart';

class SteamProfileSettingsCard extends StatefulWidget {
  const SteamProfileSettingsCard({
    super.key,
    required this.storage,
    this.onImported,
  });

  final GameLibraryStorage storage;
  final VoidCallback? onImported;

  @override
  State<SteamProfileSettingsCard> createState() =>
      _SteamProfileSettingsCardState();
}

class _SteamProfileSettingsCardState extends State<SteamProfileSettingsCard> {
  final _controller = TextEditingController();
  String? _profileUrl;
  String? _message;
  bool _isLoading = true;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await widget.storage.loadSteamProfile();
      if (mounted && profile != null) {
        setState(() {
          _controller.text = profile.input;
          _profileUrl = profile.profileUrl;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _message = 'Could not load the saved Steam profile.';
        });
      }
    }
  }

  Future<void> _importGames() async {
    final input = _controller.text.trim();
    if (input.isEmpty || _isImporting) return;
    setState(() {
      _isImporting = true;
      _message = 'Reading public Steam profile…';
    });
    try {
      final client = SteamApiClient(
        baseUrl: await resolveSteamServiceUrl(widget.storage),
      );
      final profile = await client.resolveProfile(input);
      await widget.storage.saveSteamProfile(profile);
      if (mounted) {
        setState(() => _profileUrl = profile.profileUrl);
      }
      final result = await client.readGames(profile.steamId);
      if (result.status == 'private') {
        _showMessage('Profile saved. Its game details are private.');
      } else if (result.status == 'empty') {
        _showMessage('No visible games returned. Your Library was kept.');
      } else {
        await widget.storage.importSteamGames(result.games);
        final onImported = widget.onImported;
        if (onImported != null) onImported();
        _showMessage('Imported ${result.games.length} games from Steam.');
      }
    } on SteamApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Could not import Steam data. Your Library was kept.');
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showMessage(String value) {
    if (mounted) setState(() => _message = value);
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
              'Steam profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Import public games and read achievements when you open a game.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Changing the target keeps Library games. Achievement data uses the selected profile.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              enabled: !_isImporting && !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Profile URL, vanity name, or SteamID64',
                border: OutlineInputBorder(),
              ),
              maxLength: 256,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _importGames(),
            ),
            if (_profileUrl != null) ...[
              const SizedBox(height: 12),
              Text('Target: $_profileUrl'),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isImporting || _isLoading ? null : _importGames,
              icon: _isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _isImporting ? 'Importing…' : 'Import / refresh games',
              ),
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
