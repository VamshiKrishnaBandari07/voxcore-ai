import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../platform/app_paths.dart';

/// Initializes SQLite for mobile and desktop (Windows/macOS/Linux).
Future<void> initializeDatabaseFactory() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

/// Returns a stable database directory across platforms.
Future<String> resolveDatabaseDirectory() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final supportPath = await resolveAppSupportDirectory();
    final dbDir = Directory(p.join(supportPath, 'database'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    return dbDir.path;
  }

  return getDatabasesPath();
}
