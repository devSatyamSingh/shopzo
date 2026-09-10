import 'package:flutter/material.dart';
import 'language_model.dart';

class AppLocales {
  AppLocales._();

  static const Locale english = Locale('en');
  static const Locale hindi = Locale('hi');
  static const Locale marathi = Locale('mr');
  static const Locale gujarati = Locale('gu');
  static const Locale bengali = Locale('bn');
  static const Locale urdu = Locale('ur');

  static const Locale defaultLocale = english;

  static const List<Locale> supported = [
    english,
    hindi,
    marathi,
    gujarati,
    bengali,
    urdu,
  ];

  static const List<LanguageModel> languages = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
    LanguageModel(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    LanguageModel(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    LanguageModel(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    LanguageModel(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
  ];
}