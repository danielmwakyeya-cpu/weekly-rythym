import 'dart:math';
import 'package:flutter/material.dart';

class AppColors {
  final Color ink;
  final Color plum;
  final Color plumLight;
  final Color gold;
  final Color goldSoft;
  final Color terracotta;
  final Color sage;
  final Color rose;
  final Color cream;
  final Color creamDim;
  final Color muted;

  Color get bg => ink;

  const AppColors({
    required this.ink,
    required this.plum,
    required this.plumLight,
    required this.gold,
    required this.goldSoft,
    required this.terracotta,
    required this.sage,
    required this.rose,
    required this.cream,
    required this.creamDim,
    required this.muted,
  });

  static Color fromHex(String hex) {
    String cleanHex = hex.replaceAll('#', '').trim();
    if (cleanHex.length == 3) {
      cleanHex = cleanHex.split('').map((c) => '$c$c').join();
    }
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return Color(int.parse(cleanHex, radix: 16));
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  // Predefined Blush palette
  static const blush = AppColors(
    ink: Color(0xFF2B1620),
    plum: Color(0xFF3A1F2C),
    plumLight: Color(0xFF4A2838),
    gold: Color(0xFFE8A4BD),
    goldSoft: Color(0xFFF4C9D9),
    terracotta: Color(0xFFD2698A),
    sage: Color(0xFF8FA377),
    rose: Color(0xFFF0B8C8),
    cream: Color(0xFFFBF0F3),
    creamDim: Color(0xFFE9D8DE),
    muted: Color(0xFFB58FA0),
  );

  static const bubblegum = AppColors(
    ink: Color(0xFF2E1328),
    plum: Color(0xFF421D3A),
    plumLight: Color(0xFF56274D),
    gold: Color(0xFFFF69B4),
    goldSoft: Color(0xFFFFB6C1),
    terracotta: Color(0xFFE05297),
    sage: Color(0xFF7CB9E8),
    rose: Color(0xFFFF94C2),
    cream: Color(0xFFFFF0F5),
    creamDim: Color(0xFFF2D6E6),
    muted: Color(0xFFC48BAE),
  );

  static const dustyRose = AppColors(
    ink: Color(0xFF241A1E),
    plum: Color(0xFF35262C),
    plumLight: Color(0xFF47333B),
    gold: Color(0xFFC9A098),
    goldSoft: Color(0xFFDEC4BD),
    terracotta: Color(0xFFB37D74),
    sage: Color(0xFF9EABA2),
    rose: Color(0xFFD4AEA7),
    cream: Color(0xFFF7F2F0),
    creamDim: Color(0xFFE3D6D2),
    muted: Color(0xFFA89490),
  );

  static const peach = AppColors(
    ink: Color(0xFF2A1B14),
    plum: Color(0xFF3D281F),
    plumLight: Color(0xFF52362A),
    gold: Color(0xFFF4A261),
    goldSoft: Color(0xFFF9C59B),
    terracotta: Color(0xFFE76F51),
    sage: Color(0xFF8AB17D),
    rose: Color(0xFFF28E2B),
    cream: Color(0xFFFFF6F0),
    creamDim: Color(0xFFF4DEC9),
    muted: Color(0xFFBF9B84),
  );

  static const original = AppColors(
    ink: Color(0xFF1E152A),
    plum: Color(0xFF2B1D3D),
    plumLight: Color(0xFF3B2854),
    gold: Color(0xFFE0A96D),
    goldSoft: Color(0xFFECCE9C),
    terracotta: Color(0xFFC86D51),
    sage: Color(0xFF73937E),
    rose: Color(0xFFDDA7A5),
    cream: Color(0xFFFBF8F3),
    creamDim: Color(0xFFE5DECE),
    muted: Color(0xFF9F92B3),
  );

  static const moss = AppColors(
    ink: Color(0xFF142018),
    plum: Color(0xFF1E2F24),
    plumLight: Color(0xFF2A4032),
    gold: Color(0xFF8FBE6E),
    goldSoft: Color(0xFFBCE0A4),
    terracotta: Color(0xFFD4A373),
    sage: Color(0xFFCCD5AE),
    rose: Color(0xFFA3B18A),
    cream: Color(0xFFF4F7F2),
    creamDim: Color(0xFFD5DDD0),
    muted: Color(0xFF879E8C),
  );

  static const twilight = AppColors(
    ink: Color(0xFF111428),
    plum: Color(0xFF1A1F3D),
    plumLight: Color(0xFF262C54),
    gold: Color(0xFF8E9AAF),
    goldSoft: Color(0xFFCBC0D3),
    terracotta: Color(0xFFDEAAFF),
    sage: Color(0xFF90DBF4),
    rose: Color(0xFFEFD3D7),
    cream: Color(0xFFF3F4F8),
    creamDim: Color(0xFFD2D6E2),
    muted: Color(0xFF8289A6),
  );

  static Color _hslToColor(double h, double s, double l) {
    return HSLColor.fromAHSL(1.0, (h % 360 + 360) % 360, (s / 100).clamp(0.0, 1.0), (l / 100).clamp(0.0, 1.0)).toColor();
  }

  static AppColors generateCustom(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    final h = hsl.hue;
    final s = max(hsl.saturation * 100, 45.0);

    return AppColors(
      ink: _hslToColor(h, min(s, 40.0) * 0.6, 10),
      plum: _hslToColor(h, min(s, 40.0) * 0.55, 15),
      plumLight: _hslToColor(h, min(s, 40.0) * 0.5, 20),
      gold: accent,
      goldSoft: _hslToColor(h, s * 0.75, 80),
      terracotta: _hslToColor(h + 18, min(s + 10, 85.0), 55),
      sage: _hslToColor(h + 130, min(s * 0.55, 45.0), 55),
      rose: _hslToColor(h + 18, min(s + 5, 80.0), 75),
      cream: _hslToColor(h, min(s * 0.18, 15.0), 96),
      creamDim: _hslToColor(h, min(s * 0.2, 18.0), 86),
      muted: _hslToColor(h, min(s * 0.35, 35.0), 62),
    );
  }
}

class AppThemeItem {
  final String id;
  final String name;
  final String description;
  final AppColors colors;

  const AppThemeItem({
    required this.id,
    required this.name,
    this.description = '',
    required this.colors,
  });
}

class AppThemes {
  static const List<AppThemeItem> presets = [
    AppThemeItem(id: 'blush', name: 'Blush', description: 'Deep plum, rose gold, and soft pink', colors: AppColors.blush),
    AppThemeItem(id: 'bubblegum', name: 'Bubblegum', description: 'Vibrant punchy magenta and soft cyan', colors: AppColors.bubblegum),
    AppThemeItem(id: 'dustyrose', name: 'Dusty Rose', description: 'Earthy terracotta, warm clay, and muted sage', colors: AppColors.dustyRose),
    AppThemeItem(id: 'peach', name: 'Peach Blossom', description: 'Sun-drenched apricot, terracotta, and warm ochre', colors: AppColors.peach),
    AppThemeItem(id: 'original', name: 'Original', description: 'Classic gold, deep berry, and sage', colors: AppColors.original),
    AppThemeItem(id: 'moss', name: 'Moss', description: 'Forest botanical tones, sage, and warm wood', colors: AppColors.moss),
    AppThemeItem(id: 'twilight', name: 'Twilight', description: 'Midnight indigo, lavender, and celestial silver', colors: AppColors.twilight),
  ];

  static List<AppThemeItem> get allThemes => [
        ...presets,
        const AppThemeItem(id: 'custom', name: 'Custom', description: 'Tailored accent color palette', colors: AppColors.blush),
      ];

  static AppThemeItem getTheme(String id, {Color? customAccent}) {
    if (id == 'custom') {
      final accent = customAccent ?? const Color(0xFFE8A4BD);
      return AppThemeItem(id: 'custom', name: 'Custom', description: 'Tailored accent color palette', colors: AppColors.generateCustom(accent));
    }
    return presets.firstWhere((t) => t.id == id, orElse: () => presets[0]);
  }
}
