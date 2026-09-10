import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale = const Locale('ar', 'YE');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  String get currentLanguage => isArabic ? 'ar' : 'en';

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString(_localeKey) ?? 'ar';
      _locale = langCode == 'en' ? const Locale('en') : const Locale('ar', 'YE');
    } catch (e) {
      _locale = const Locale('ar', 'YE');
    }
    notifyListeners();
  }

  Future<void> setArabic() async {
    _locale = const Locale('ar', 'YE');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, 'ar');
    } catch (e) {
      // ignore
    }
    notifyListeners();
  }

  Future<void> setEnglish() async {
    _locale = const Locale('en');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, 'en');
    } catch (e) {
      // ignore
    }
    notifyListeners();
  }
}