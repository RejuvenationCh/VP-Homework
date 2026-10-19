class SteamProfileTarget {
  const SteamProfileTarget({
    required this.steamId,
    required this.profileUrl,
    required this.input,
  });

  final String steamId;
  final String profileUrl;
  final String input;
}

class SteamLibraryGame {
  const SteamLibraryGame({
    required this.appId,
    required this.name,
    required this.playtimeMinutes,
  });

  final String appId;
  final String name;
  final int? playtimeMinutes;
}

class SteamLibraryResult {
  const SteamLibraryResult({required this.status, required this.games});

  final String status;
  final List<SteamLibraryGame> games;
}

class SteamAchievementsResult {
  const SteamAchievementsResult({required this.status, required this.items});

  final String status;
  final List<SteamAchievementItem> items;
}

class SteamAchievementItem {
  const SteamAchievementItem({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.isUnlocked,
  });

  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final bool? isUnlocked;
}
