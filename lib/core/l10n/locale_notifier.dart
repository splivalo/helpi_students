import 'package:flutter/material.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';

/// Obavještava widget stablo o promjeni jezika.
class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier() : super(const Locale('hr'));

  void setLocale(String languageCode) {
    final code = languageCode.toLowerCase();
    AppStrings.setLocale(code);
    value = Locale(code);
  }
}
