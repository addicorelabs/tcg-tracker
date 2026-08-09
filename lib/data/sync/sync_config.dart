/// Supabase credentials, supplied at build time.
///
/// They are compiled in with `--dart-define` rather than read from a file, so
/// the repository never carries a project URL and no runtime fetch has to
/// succeed before the app can open:
///
/// ```
/// flutter build web \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJ...
/// ```
///
/// `SUPABASE_ANON_KEY` takes either of the two keys Supabase has called this
/// over the years — the older `anon` key or the newer publishable one.
///
/// That key is a public key: it is meant to ship inside the client, and
/// row level security is what actually keeps one account out of another's
/// data. Nothing secret belongs here.
///
/// A build without them is a perfectly valid build. The app then runs purely
/// offline and the account screen says so instead of failing at startup, which
/// keeps local-only use — and every test — free of a network dependency.
abstract final class SyncConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
