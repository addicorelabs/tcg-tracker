import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'data/sync/supabase_sync_backend.dart';
import 'data/sync/sync_backend.dart';
import 'data/sync/sync_config.dart';
import 'data/sync/sync_controller.dart';
import 'features/settings/providers/app_settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preferences are loaded before the first frame so the app opens straight
  // into the chosen theme and language, with no flash of the defaults.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        syncBackendProvider.overrideWithValue(await _openSyncBackend()),
      ],
      child: const TcgTrackerApp(),
    ),
  );
}

/// Connects to Supabase, or returns null and lets the app run local-only.
///
/// A build without credentials is a normal build, and a Supabase that refuses
/// to start is not a reason to show a blank screen: everything except the sync
/// works offline, and the account screen is where the absence gets explained.
Future<SyncBackend?> _openSyncBackend() async {
  if (!SyncConfig.isConfigured) return null;

  try {
    await Supabase.initialize(
      url: SyncConfig.url,
      publishableKey: SyncConfig.anonKey,
    );
    return SupabaseSyncBackend.instance();
  } catch (error) {
    debugPrint('Supabase unavailable, running local-only: $error');
    return null;
  }
}
