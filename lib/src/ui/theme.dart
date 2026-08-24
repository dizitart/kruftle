// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/material.dart';

/// Kruftle's visual language: dense, dark-first, and tabular — a tool that
/// sits next to a terminal rather than one that competes with a consumer app.
abstract final class KruftleTheme {
  /// Warm amber. Sawdust, swarf, cruft — the stuff being swept up.
  static const seed = Color(0xFFE0A33C);

  // Semantic colours come in pairs. The dark values are tuned to glow against
  // a near-black surface; on a white one the same green washes out to roughly
  // 1.7:1 contrast, which is a swatch rather than a signal. Reach for these
  // through `context.freed` and friends, never directly, so the right one for
  // the current brightness is always used. A test asserts the contrast of
  // every pair against the surface it will actually sit on.
  static const freed = Color(0xFF4ADE80);
  static const freedLight = Color(0xFF15803D);
  static const warn = Color(0xFFFBBF24);
  static const warnLight = Color(0xFF9A6100);
  static const danger = Color(0xFFF87171);
  static const dangerLight = Color(0xFFC02626);

  static Color freedFor(Brightness b) =>
      b == Brightness.dark ? freed : freedLight;
  static Color warnFor(Brightness b) => b == Brightness.dark ? warn : warnLight;
  static Color dangerFor(Brightness b) =>
      b == Brightness.dark ? danger : dangerLight;

  /// The platform's own code font, so paths and commands look like they do in
  /// the user's editor. No downloaded font: a 200 KB dependency to render
  /// `cargo clean` is not a trade worth making.
  static List<String> get monoFallback => Platform.isMacOS
      ? const ['SF Mono', 'Menlo', 'Monaco', 'monospace']
      : Platform.isWindows
      ? const ['Cascadia Mono', 'Consolas', 'Courier New', 'monospace']
      : const ['Ubuntu Mono', 'DejaVu Sans Mono', 'monospace'];

  static String get monoFamily => monoFallback.first;

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: isDark ? const Color(0xFF16181D) : const Color(0xFFFBFAF8),
    );

    final surfaceRaised = isDark ? const Color(0xFF1D2027) : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.compact,
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),
      cardTheme: CardThemeData(
        color: surfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaised,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: BorderSide(color: border),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: scheme.onSurfaceVariant, width: 1.5),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2E37) : const Color(0xFF2A2E37),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        waitDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

extension KruftleTextStyles on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  Brightness get brightness => Theme.of(this).brightness;

  /// Space reclaimed, a step that succeeded — anything good.
  Color get freed => KruftleTheme.freedFor(brightness);

  /// Something the user should look at before continuing.
  Color get warn => KruftleTheme.warnFor(brightness);

  /// A failure, or a path Kruftle refuses to touch.
  Color get danger => KruftleTheme.dangerFor(brightness);

  /// For anything the user could paste into a shell: paths, commands, digests.
  TextStyle mono({double size = 12, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: KruftleTheme.monoFamily,
        fontFamilyFallback: KruftleTheme.monoFallback,
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.4,
      );
}
