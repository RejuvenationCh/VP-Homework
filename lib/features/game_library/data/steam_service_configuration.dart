import 'package:flutter/foundation.dart';

import 'game_library_storage.dart';
import 'steam_api_parser.dart';

const _buildUrl = String.fromEnvironment('STEAM_GUIDE_API_BASE_URL');

String validateSteamServiceUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      (uri.path.isNotEmpty && uri.path != '/')) {
    throw const SteamApiException(
      'Enter the Steam service URL without a path.',
    );
  }
  final local =
      uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '::1';
  if (uri.scheme != 'https' && !(kDebugMode && local && uri.scheme == 'http')) {
    throw const SteamApiException('Use an HTTPS Steam service URL.');
  }
  return uri.replace(path: '').toString().replaceFirst(RegExp(r'/$'), '');
}

Future<String> resolveSteamServiceUrl(GameLibraryStorage? storage) async {
  if (storage != null) {
    final saved = await storage.loadSteamServiceUrl();
    if (saved != null && saved.isNotEmpty) {
      return validateSteamServiceUrl(saved);
    }
  }
  if (_buildUrl.isNotEmpty) return validateSteamServiceUrl(_buildUrl);
  if (kDebugMode) return 'http://127.0.0.1:8787';
  throw const SteamApiException('Set an HTTPS Steam service URL in Settings.');
}
