import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('id') {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('selected_locale');
    if (savedLocale != null) {
      state = savedLocale;
    }
  }

  Future<void> setLocale(String locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', locale);
  }
}
