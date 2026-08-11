import 'package:flutter/material.dart';

import '../shared/layout/bar_insets.dart';

/// Colours that carry meaning in this app and therefore cannot live in the
/// generated [ColorScheme]: the identity of each game and the outcome of a
/// match. Reached from a widget with `Theme.of(context).appColors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.yugioh,
    required this.magic,
    required this.win,
    required this.loss,
    required this.draw,
    required this.heroGradient,
  });

  /// Amber, after the Yu-Gi-Oh! card frame.
  final Color yugioh;

  /// Blue, after the Magic mana symbol.
  final Color magic;

  final Color win;
  final Color loss;
  final Color draw;

  /// Backdrop of the header at the top of the dashboard.
  final List<Color> heroGradient;

  /// Ids of the two shipped games, repeated here rather than imported from the
  /// seed: the theme layer answers "what colour is this game" and has no
  /// business reaching into the database layer to do it.
  static const yugiohId = 'ygo';
  static const magicId = 'mtg';

  /// Accents for games the user adds. Mid-tone on purpose: one list serves
  /// both themes, since a custom game has no identity of its own to honour.
  static const extraAccents = [
    Color(0xFF3DD68C),
    Color(0xFFE86A9A),
    Color(0xFF00B8C4),
    Color(0xFFC98BFF),
    Color(0xFFE8C13D),
  ];

  static const dark = AppColors(
    yugioh: Color(0xFFE8A33D),
    magic: Color(0xFF5B9CFF),
    win: Color(0xFF3DD68C),
    loss: Color(0xFFF2555A),
    draw: Color(0xFF9A9AA8),
    heroGradient: [Color(0xFF2A1F52), Color(0xFF141420)],
  );

  static const light = AppColors(
    yugioh: Color(0xFFB57320),
    magic: Color(0xFF2F6FD0),
    win: Color(0xFF1F9D5F),
    loss: Color(0xFFD32F35),
    draw: Color(0xFF6E6E7A),
    heroGradient: [Color(0xFF6A5AE0), Color(0xFF8C7BF0)],
  );

  @override
  AppColors copyWith({
    Color? yugioh,
    Color? magic,
    Color? win,
    Color? loss,
    Color? draw,
    List<Color>? heroGradient,
  }) {
    return AppColors(
      yugioh: yugioh ?? this.yugioh,
      magic: magic ?? this.magic,
      win: win ?? this.win,
      loss: loss ?? this.loss,
      draw: draw ?? this.draw,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      yugioh: Color.lerp(yugioh, other.yugioh, t)!,
      magic: Color.lerp(magic, other.magic, t)!,
      win: Color.lerp(win, other.win, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      draw: Color.lerp(draw, other.draw, t)!,
      heroGradient: [
        for (var i = 0; i < heroGradient.length; i++)
          Color.lerp(heroGradient[i], other.heroGradient[i], t)!,
      ],
    );
  }
}

extension AppColorsAccess on ThemeData {
  AppColors get appColors => extension<AppColors>() ?? AppColors.dark;

  /// The colour that stands for a game everywhere it appears.
  ///
  /// The two shipped games have one each, chosen after their cards. A game the
  /// user adds gets one from a small palette, picked from its id — which is a
  /// uuid, and never changes — so the same game keeps the same colour on every
  /// screen and across restarts. Deliberately not `hashCode`: Dart makes no
  /// promise that it is the same number in the next run of the app.
  Color gameAccent(String gameId) {
    return switch (gameId) {
      AppColors.yugiohId => appColors.yugioh,
      AppColors.magicId => appColors.magic,
      _ =>
        AppColors.extraAccents[_stableIndex(
          gameId,
          AppColors.extraAccents.length,
        )],
    };
  }

  static int _stableIndex(String value, int slots) {
    var sum = 0;
    for (final unit in value.codeUnits) {
      sum = (sum + unit) % slots;
    }
    return sum;
  }
}

/// Visual identity of the app: dark by default, deep surfaces, a violet accent,
/// and labels set in spaced uppercase so numbers stay the loudest thing on screen.
abstract final class AppTheme {
  static const Color _accent = Color(0xFF8B6BFF);

  /// Web has no guaranteed font, so the stack degrades through the usual
  /// system faces rather than pulling a webfont the PWA would fail to load
  /// while offline.
  static const List<String> _fontFallback = [
    'Inter',
    'Segoe UI Variable',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
  ];

  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _accent,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF101017),
          surfaceContainerLowest: const Color(0xFF0B0B10),
          surfaceContainerLow: const Color(0xFF15151E),
          surfaceContainer: const Color(0xFF1A1A24),
          surfaceContainerHigh: const Color(0xFF20202B),
          surfaceContainerHighest: const Color(0xFF262633),
          outlineVariant: const Color(0xFF2E2E3D),
        );

    return _build(colorScheme, AppColors.dark);
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: _accent);
    return _build(colorScheme, AppColors.light);
  }

  static ThemeData _build(ColorScheme colorScheme, AppColors appColors) {
    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);
    final isDark = colorScheme.brightness == Brightness.dark;

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [appColors],
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: _textTheme(base.textTheme, colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          fontFamilyFallback: _fontFallback,
        ),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        // A shade above the page rather than below it: the bar is a floating
        // pill (see `ShellScaffold`), and it can only read as floating if it is
        // lighter than what it floats over.
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.20),
        elevation: 0,
        // A shorter bar does not shrink its contents, it crops them: at 68 the
        // labels lost their bottom few pixels.
        height: FloatingBar.height,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            // Small and tightly tracked because the pill gives up screen width
            // to its margins, and "Impostazioni" has to fit in a fifth of what
            // is left.
            fontSize: 10,
            letterSpacing: 0.1,
            fontFamilyFallback: _fontFallback,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.20),
        selectedLabelTextStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: colorScheme.onSurface,
          fontFamilyFallback: _fontFallback,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: colorScheme.onSurfaceVariant,
          fontFamilyFallback: _fontFallback,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            fontFamilyFallback: _fontFallback,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            fontFamilyFallback: _fontFallback,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: colorScheme.onSurfaceVariant,
          fontFamilyFallback: _fontFallback,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme colorScheme) {
    TextStyle? apply(
      TextStyle? style, {
      FontWeight? weight,
      double? spacing,
      Color? color,
    }) {
      return style?.copyWith(
        fontWeight: weight,
        letterSpacing: spacing,
        color: color,
        fontFamilyFallback: _fontFallback,
      );
    }

    return base.copyWith(
      // Big numbers: tight and heavy, so a winrate reads as a headline.
      displaySmall: apply(
        base.displaySmall,
        weight: FontWeight.w800,
        spacing: -1,
      ),
      headlineMedium: apply(
        base.headlineMedium,
        weight: FontWeight.w800,
        spacing: -0.8,
      ),
      headlineSmall: apply(
        base.headlineSmall,
        weight: FontWeight.w800,
        spacing: -0.5,
      ),
      titleLarge: apply(base.titleLarge, weight: FontWeight.w700, spacing: 0),
      titleMedium: apply(base.titleMedium, weight: FontWeight.w700, spacing: 0),
      bodyLarge: apply(base.bodyLarge, weight: FontWeight.w400, spacing: 0.1),
      bodyMedium: apply(base.bodyMedium, weight: FontWeight.w400, spacing: 0.1),
      // Small caps labels: the app's recurring accent.
      labelLarge: apply(base.labelLarge, weight: FontWeight.w700, spacing: 0.6),
      labelMedium: apply(
        base.labelMedium,
        weight: FontWeight.w700,
        spacing: 1.2,
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: apply(
        base.labelSmall,
        weight: FontWeight.w700,
        spacing: 1.4,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
