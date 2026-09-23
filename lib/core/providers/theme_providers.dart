import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'app_theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_key);
      if (savedStr == 'light') {
        state = ThemeMode.light;
      } else if (savedStr == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'system';
      if (mode == ThemeMode.light) {
        val = 'light';
      } else if (mode == ThemeMode.dark) {
        val = 'dark';
      }
      await prefs.setString(_key, val);
    } catch (_) {}
  }

  Future<void> toggleTheme(BuildContext context) async {
    final currentBrightness = Theme.of(context).brightness;
    if (currentBrightness == Brightness.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class BankPresetNotifier extends StateNotifier<BankThemePreset> {
  static const String _key = 'app_bank_preset';

  BankPresetNotifier() : super(BankThemePreset.defaultBatwa) {
    _loadPreset();
  }

  Future<void> _loadPreset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_key);
      if (id != null) {
        state = BankThemeConfig.fromId(id);
      }
    } catch (_) {}
  }

  Future<void> setPreset(BankThemePreset preset) async {
    state = preset;
    try {
      final prefs = await SharedPreferences.getInstance();
      final config = BankThemeConfig.getConfig(preset);
      await prefs.setString(_key, config.id);
    } catch (_) {}
  }
}

final bankThemePresetProvider =
    StateNotifierProvider<BankPresetNotifier, BankThemePreset>((ref) {
  return BankPresetNotifier();
});

final activeBankConfigProvider = Provider<BankThemeConfig>((ref) {
  final preset = ref.watch(bankThemePresetProvider);
  return BankThemeConfig.getConfig(preset);
});

class CardholderNameNotifier extends StateNotifier<String> {
  static const String _key = 'app_cardholder_name';

  CardholderNameNotifier() : super('Shah Nawaz') {
    _loadName();
  }

  Future<void> _loadName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_key);
      if (name != null && name.trim().isNotEmpty) {
        state = name.trim();
      }
    } catch (_) {}
  }

  Future<void> setName(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    state = clean;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, clean);
    } catch (_) {}
  }
}

final cardholderNameProvider =
    StateNotifierProvider<CardholderNameNotifier, String>((ref) {
  return CardholderNameNotifier();
});

class BalanceHiddenNotifier extends StateNotifier<bool> {
  static const String _key = 'app_is_balance_hidden';

  BalanceHiddenNotifier() : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hidden = prefs.getBool(_key);
      if (hidden != null) {
        state = hidden;
      }
    } catch (_) {}
  }

  Future<void> toggle() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, state);
    } catch (_) {}
  }

  Future<void> setHidden(bool hidden) async {
    state = hidden;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, hidden);
    } catch (_) {}
  }
}

final isBalanceHiddenProvider =
    StateNotifierProvider<BalanceHiddenNotifier, bool>((ref) {
  return BalanceHiddenNotifier();
});
