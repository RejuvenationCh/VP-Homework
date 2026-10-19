import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

class GameDatabase extends GeneratedDatabase {
  GameDatabase()
    : super(
        driftDatabase(
          name: 'game_backlog',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo> get allTables => const <TableInfo>[];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await customStatement(
        'CREATE TABLE games (id TEXT PRIMARY KEY, position INTEGER NOT NULL, payload TEXT NOT NULL)',
      );
      await customStatement(
        'CREATE TABLE achievements (game_id TEXT NOT NULL, achievement_id TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY (game_id, achievement_id))',
      );
      await customStatement(
        'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      );
      await customStatement(
        'CREATE TABLE hidden_steam_games (app_id TEXT PRIMARY KEY)',
      );
    },
  );
}
