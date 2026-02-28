import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:helpi_student/app/main_shell.dart';
import 'package:helpi_student/app/theme.dart';
import 'package:helpi_student/auth/presentation/login_screen.dart';
import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/l10n/locale_notifier.dart';
import 'package:helpi_student/core/models/availability_model.dart';
import 'package:helpi_student/features/onboarding/presentation/onboarding_screen.dart';

/// Root widget — upravlja auth stateom, onboardingom i locale-om.
class HelpiStudentApp extends StatefulWidget {
  const HelpiStudentApp({super.key});

  @override
  State<HelpiStudentApp> createState() => _HelpiStudentAppState();
}

class _HelpiStudentAppState extends State<HelpiStudentApp> {
  final _localeNotifier = LocaleNotifier();
  final _availabilityNotifier = AvailabilityNotifier();

  bool _isLoggedIn = false;
  bool _hasCompletedOnboarding = false;

  void _handleLogin() {
    setState(() => _isLoggedIn = true);
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _hasCompletedOnboarding = false;
      _availabilityNotifier.reset();
    });
  }

  void _handleOnboardingComplete() {
    setState(() => _hasCompletedOnboarding = true);
  }

  @override
  void dispose() {
    _localeNotifier.dispose();
    _availabilityNotifier.dispose();
    super.dispose();
  }

  Widget _buildHome() {
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: _handleLogin,
        localeNotifier: _localeNotifier,
      );
    }
    if (!_hasCompletedOnboarding) {
      return OnboardingScreen(
        availabilityNotifier: _availabilityNotifier,
        onComplete: _handleOnboardingComplete,
      );
    }
    return MainShell(
      onLogout: _handleLogout,
      localeNotifier: _localeNotifier,
      availabilityNotifier: _availabilityNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: _localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: HelpiTheme.light,
          locale: locale,
          supportedLocales: const [Locale('hr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _buildHome(),
        );
      },
    );
  }
}
