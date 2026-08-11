import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sync/sync_controller.dart';
import '../features/settings/providers/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../shared/layout/status_bar_inset.dart';
import 'router.dart';
import 'theme.dart';

class TcgTrackerApp extends ConsumerWidget {
  const TcgTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final router = ref.watch(routerProvider);

    // Starts the sync controller — and with it the session listener and the
    // watch on local writes — without rebuilding the whole app every time the
    // status changes. Nothing up here draws it; the account screen does.
    ref.listen(syncControllerProvider, (_, _) {});

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,

      // The one place the status bar inset is handed to the framework. From
      // here on it is an ordinary padding: `Scaffold` makes room for it above
      // the app bar, `AppBar` pushes its title below it, and `SafeArea` keeps
      // anything else clear of it — none of which happens on its own, because
      // Flutter Web reports no insets at all for an installed web app.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            padding: media.padding.copyWith(top: statusBarInset),
            viewPadding: media.viewPadding.copyWith(top: statusBarInset),
          ),
          child: child!,
        );
      },
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,

      // Null keeps the device language, with English as the fallback declared
      // by localizationsDelegates.
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
