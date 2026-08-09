import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the [SharedPreferences] instance loaded during app startup.
///
/// Overridden in `main()`, so preferences are available synchronously and no
/// screen has to deal with a loading state just to know the current theme.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

/// User preferences that affect the whole app.
///
/// A null [locale] means "follow the device language". The theme defaults to
/// dark rather than to the system setting: the app is designed dark first, and
/// that is the look it should open on at a tournament venue.
@immutable
class AppSettings {
  const AppSettings({this.locale, this.themeMode = ThemeMode.dark});

  final Locale? locale;
  final ThemeMode themeMode;

  AppSettings copyWith({
    Locale? locale,
    bool clearLocale = false,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      locale: clearLocale ? null : (locale ?? this.locale),
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _localeKey = 'settings.locale';
  static const _themeModeKey = 'settings.themeMode';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final languageCode = prefs.getString(_localeKey);
    final themeModeName = prefs.getString(_themeModeKey);

    return AppSettings(
      locale: languageCode == null ? null : Locale(languageCode),
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == themeModeName,
        orElse: () => ThemeMode.dark,
      ),
    );
  }

  /// Pass null to follow the device language.
  Future<void> setLocale(Locale? locale) async {
    state = locale == null
        ? state.copyWith(clearLocale: true)
        : state.copyWith(locale: locale);

    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_themeModeKey, mode.name);
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
