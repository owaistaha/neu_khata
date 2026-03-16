import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, urdu }

const _languagePrefKey = 'appLanguage';

final appLanguageProvider =
    AsyncNotifierProvider<AppLanguageNotifier, AppLanguage>(
      AppLanguageNotifier.new,
    );

class AppLanguageNotifier extends AsyncNotifier<AppLanguage> {
  @override
  Future<AppLanguage> build() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(_languagePrefKey);
    return storedValue == AppLanguage.urdu.name
        ? AppLanguage.urdu
        : AppLanguage.english;
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = AsyncData(language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePrefKey, language.name);
  }
}

Locale localeFromLanguage(AppLanguage language) {
  switch (language) {
    case AppLanguage.urdu:
      return const Locale('ur', 'PK');
    case AppLanguage.english:
      return const Locale('en');
  }
}
