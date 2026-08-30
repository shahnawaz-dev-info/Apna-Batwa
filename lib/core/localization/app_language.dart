import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english,
  romanUrdu,
}

class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  static const String _key = 'app_language';

  AppLanguageNotifier() : super(AppLanguage.english) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_key);
      if (savedStr == 'roman_urdu') {
        state = AppLanguage.romanUrdu;
      } else {
        state = AppLanguage.english;
      }
    } catch (_) {
      state = AppLanguage.english;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = language == AppLanguage.romanUrdu ? 'roman_urdu' : 'english';
      await prefs.setString(_key, val);
    } catch (_) {}
  }
}

final appLanguageProvider = StateNotifierProvider<AppLanguageNotifier, AppLanguage>((ref) {
  return AppLanguageNotifier();
});
