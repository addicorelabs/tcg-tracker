import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// The single database instance for the running app.
///
/// Opening it twice on web would mean two workers fighting over the same
/// storage, so nothing else may construct an [AppDatabase] at runtime.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
