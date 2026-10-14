import '../features/media_cleaner/data/mock_media.dart';
import '../features/media_cleaner/models/media_item.dart';

// Separate from the normal app's data; used by the Week 4 harness and tests.
enum DemoData {
  normal('Normal'),
  longName('200-char name'),
  empty('Zero items'),
  big('500 items');

  const DemoData(this.label);
  final String label;

  List<MediaItem> get items => switch (this) {
    DemoData.normal => List.of(mockMedia),
    DemoData.empty => [],
    DemoData.longName => [
      MediaItem(
        id: mockMedia.first.id,
        name: List.filled(200, 'W').join(),
        category: mockMedia.first.category,
        sizeBytes: mockMedia.first.sizeBytes,
        date: mockMedia.first.date,
      ),
      ...mockMedia.skip(1),
    ],
    DemoData.big => List.generate(
      500,
      (i) => MediaItem(
        id: 'demo-$i',
        name: 'Media_${i.toString().padLeft(3, '0')}.jpg',
        category: MediaCategory.values[i % MediaCategory.values.length],
        sizeBytes: (500 - i) * 1024,
        date: DateTime(2026, 1, 1).add(Duration(days: i)),
      ),
    ),
  };
}
