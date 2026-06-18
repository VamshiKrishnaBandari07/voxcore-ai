import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_init.dart';
/// Local SQLite access for VoiceCode. All speech data stays on device.
class DbHelper {
  DbHelper({DatabaseFactory? databaseFactory})
      : _databaseFactory = databaseFactory;

  static const String dbName = 'voicecode.db';
  static const int dbVersion = 5;

  Database? _database;
  final DatabaseFactory? _databaseFactory;

  /// Opens the database and creates tables on first launch.
  Future<Database> initialize() async {
    if (_database != null) {
      return _database!;
    }

    if (_databaseFactory != null) {
      databaseFactory = _databaseFactory;
    }
    final dbPath = await resolveDatabaseDirectory();
    final path = join(dbPath, dbName);
    _database = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        duration_ms INTEGER,
        audio_path TEXT,
        overall_score REAL,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE metrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL UNIQUE,
        wpm REAL NOT NULL DEFAULT 0,
        fluency_ratio REAL NOT NULL DEFAULT 0,
        filler_density REAL NOT NULL DEFAULT 0,
        pacing_stability REAL NOT NULL DEFAULT 0,
        total_word_count INTEGER NOT NULL DEFAULT 0,
        filler_count INTEGER NOT NULL DEFAULT 0,
        total_file_duration_ms INTEGER NOT NULL DEFAULT 0,
        total_silence_ms INTEGER NOT NULL DEFAULT 0,
        speaking_duration_ms INTEGER NOT NULL DEFAULT 0,
        clarity REAL,
        pronunciation REAL,
        fluency REAL,
        articulation REAL,
        pace REAL,
        breath REAL,
        overall_score REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE transcripts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        raw_text TEXT,
        enriched_text TEXT,
        word_timestamps_json TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_metrics_session_id ON metrics (session_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transcripts_session_id ON transcripts (session_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
    if (oldVersion < 4) {
      await _migrateToV4(db);
    }
    if (oldVersion < 5) {
      await _migrateToV5(db);
    }
  }

  /// Adds Module D analytics columns to the metrics table.
  static Future<void> _migrateToV2(Database db) async {
    const columns = <String>[
      'fluency_ratio REAL NOT NULL DEFAULT 0',
      'filler_density REAL NOT NULL DEFAULT 0',
      'pacing_stability REAL NOT NULL DEFAULT 0',
      'total_word_count INTEGER NOT NULL DEFAULT 0',
      'filler_count INTEGER NOT NULL DEFAULT 0',
      'total_file_duration_ms INTEGER NOT NULL DEFAULT 0',
      'total_silence_ms INTEGER NOT NULL DEFAULT 0',
      'speaking_duration_ms INTEGER NOT NULL DEFAULT 0',
    ];

    for (final column in columns) {
      await db.execute('ALTER TABLE metrics ADD COLUMN $column');
    }

    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_metrics_session_unique '
      'ON metrics (session_id)',
    );
  }

  static Future<void> _migrateToV3(Database db) async {
    await db.execute(
      'ALTER TABLE transcripts ADD COLUMN word_timestamps_json TEXT',
    );
  }

  static Future<void> _migrateToV4(Database db) async {
    await db.execute(
      'ALTER TABLE metrics ADD COLUMN overall_score REAL NOT NULL DEFAULT 0',
    );
  }

  static Future<void> _migrateToV5(Database db) async {
    const columns = <String>[
      'clarity REAL',
      'pronunciation REAL',
      'fluency REAL',
      'articulation REAL',
      'pace REAL',
      'breath REAL',
    ];

    for (final column in columns) {
      try {
        await db.execute('ALTER TABLE metrics ADD COLUMN $column');
      } catch (_) {
        // Column may already exist on fresh v4+ installs.
      }
    }
  }
}
