import 'package:flutter/material.dart';

/// Semantic colors for the app, resolved per light/dark theme via a
/// [ThemeExtension]. Access with `Theme.of(context).extension<AppPalette>()!`.
///
/// Concept: green like paper money, gold like gold — a warm, characterful
/// money-tracking look.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color green; // brand / primary — "paper money"
  final Color gold; // accent — "gold"
  final Color positive; // remaining / in-budget
  final Color spent; // amount spent
  final Color warning; // nearing the limit
  final Color danger; // over budget / negative
  final Color cardSurface; // card background
  final Color cardBorder; // card outline
  final Color subtleFill; // faint filled containers
  final Color bannerBg; // days-until-reset banner background
  final Color bannerFg; // days-until-reset banner text

  const AppPalette({
    required this.green,
    required this.gold,
    required this.positive,
    required this.spent,
    required this.warning,
    required this.danger,
    required this.cardSurface,
    required this.cardBorder,
    required this.subtleFill,
    required this.bannerBg,
    required this.bannerFg,
  });

  static const AppPalette light = AppPalette(
    green: Color(0xFF2E7D46),
    gold: Color(0xFFC9A227),
    positive: Color(0xFF2E7D46),
    spent: Color(0xFFC77D28),
    warning: Color(0xFFD9902B),
    danger: Color(0xFFC0392B),
    cardSurface: Color(0xFFFFFFFF),
    cardBorder: Color(0x1A1B5E20),
    subtleFill: Color(0x0F2E7D46),
    bannerBg: Color(0x1FC9A227),
    bannerFg: Color(0xFF8A6D12),
  );

  static const AppPalette dark = AppPalette(
    green: Color(0xFF52C878),
    gold: Color(0xFFE5B84B),
    positive: Color(0xFF5BC47D),
    spent: Color(0xFFE0973A),
    warning: Color(0xFFE0973A),
    danger: Color(0xFFE5675C),
    cardSurface: Color(0xFF19221B),
    cardBorder: Color(0x2652C878),
    subtleFill: Color(0x1452C878),
    bannerBg: Color(0x33E5B84B),
    bannerFg: Color(0xFFE5B84B),
  );

  @override
  AppPalette copyWith({
    Color? green,
    Color? gold,
    Color? positive,
    Color? spent,
    Color? warning,
    Color? danger,
    Color? cardSurface,
    Color? cardBorder,
    Color? subtleFill,
    Color? bannerBg,
    Color? bannerFg,
  }) {
    return AppPalette(
      green: green ?? this.green,
      gold: gold ?? this.gold,
      positive: positive ?? this.positive,
      spent: spent ?? this.spent,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      cardSurface: cardSurface ?? this.cardSurface,
      cardBorder: cardBorder ?? this.cardBorder,
      subtleFill: subtleFill ?? this.subtleFill,
      bannerBg: bannerBg ?? this.bannerBg,
      bannerFg: bannerFg ?? this.bannerFg,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      green: Color.lerp(green, other.green, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      spent: Color.lerp(spent, other.spent, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      subtleFill: Color.lerp(subtleFill, other.subtleFill, t)!,
      bannerBg: Color.lerp(bannerBg, other.bannerBg, t)!,
      bannerFg: Color.lerp(bannerFg, other.bannerFg, t)!,
    );
  }
}

/// Shortcut to read the palette from a [BuildContext].
AppPalette palette(BuildContext context) =>
    Theme.of(context).extension<AppPalette>()!;

/// Parses a "#RRGGBB" hex string into a [Color].
Color hexColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16) ?? 0x999999;
  return Color(0xFF000000 | value);
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppPalette.light.green,
    brightness: Brightness.light,
    primary: AppPalette.light.green,
    secondary: AppPalette.light.gold,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF4F6EF),
    extensions: const [AppPalette.light],
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.light.green,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppPalette.dark.green,
    brightness: Brightness.dark,
    primary: AppPalette.dark.green,
    secondary: AppPalette.dark.gold,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF0F140F),
    extensions: const [AppPalette.dark],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF141C15),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
