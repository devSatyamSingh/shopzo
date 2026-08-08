import 'package:flutter/material.dart';
import 'language_model.dart';

class AppLocales {
  AppLocales._();

  static const Locale english = Locale('en');
  static const Locale hindi = Locale('hi');
  static const Locale marathi = Locale('mr');

  static const Locale defaultLocale = english;

  static const List<Locale> supported = [english, hindi, marathi];

  static const List<LanguageModel> languages = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
    LanguageModel(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
  ];
}