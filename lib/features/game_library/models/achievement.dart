enum AchievementProgress {
  unknown('Progress unknown'),
  locked('Locked'),
  unlocked('Unlocked');

  const AchievementProgress(this.label);

  final String label;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    this.description = '',
    this.artworkUrl,
    this.currentProgress,
    this.totalProgress,
    required this.progress,
  });

  final String id;
  final String name;
  final String description;
  final String? artworkUrl;
  final int? currentProgress;
  final int? totalProgress;
  final AchievementProgress progress;
}
