import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_storage.dart';
import 'app_locales.dart';
import 'language_model.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = Locale(AppStorage.getLanguageCode());
  Locale get locale => _locale;

  Future<void> changeLanguage(BuildContext context, Locale newLocale) async {
    if (_locale == newLocale) return;

    await context.setLocale(newLocale);
    await AppStorage.saveLanguageCode(newLocale.languageCode);

    _locale = newLocale;
    notifyListeners();
  }

  LanguageModel get currentLanguageModel => AppLocales.languages.firstWhere(
        (l) => l.code == _locale.languageCode,
    orElse: () => AppLocales.languages.first,
  );
}