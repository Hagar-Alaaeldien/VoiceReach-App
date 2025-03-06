import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocalizationHelper {
  // Initialize localization
  static Future<void> init() async {
    await EasyLocalization.ensureInitialized();
  }

  // List of supported locales
  static List<Locale> getSupportedLocales() {
    return const [
      Locale('en'), // English
      Locale('ar'), // Arabic
    ];
  }

  // Default fallback locale
  static Locale getFallbackLocale() {
    return const Locale('en'); // English as fallback
  }

  // Get the current locale
  static Locale getCurrentLocale(BuildContext context) {
    return context.locale;
  }

  // Switch locale dynamically
  static void switchLocale(BuildContext context, Locale locale) {
    context.setLocale(locale);
  }

  // Get translated string by key
  static String translate(BuildContext context, String key) {
    return key.tr();
  }
}
