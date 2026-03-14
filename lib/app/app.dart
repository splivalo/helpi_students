import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:helpi_student/app/main_shell.dart';
import 'package:helpi_student/app/theme.dart';
import 'package:helpi_student/auth/presentation/login_screen.dart';
import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/l10n/locale_notifier.dart';
import 'package:helpi_student/core/models/availability_model.dart';
import 'package:helpi_student/core/services/auth_service.dart';
import 'package:helpi_student/features/onboarding/presentation/onboarding_screen.dart';
import 'package:helpi_student/features/onboarding/presentation/registration_data_screen.dart';

/// Root widget — upravlja auth stateom, onboardingom i locale-om.
class HelpiStudentApp extends StatefulWidget {
  const HelpiStudentApp({super.key});

  @override
  State<HelpiStudentApp> createState() => _HelpiStudentAppState();
}

class _HelpiStudentAppState extends State<HelpiStudentApp> {
  final _localeNotifier = LocaleNotifier();
  final _availabilityNotifier = AvailabilityNotifier();
  final _authService = AuthService();

  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;
  bool _hasCompletedRegistration = false;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    final loggedIn = await _authService.isLoggedIn();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = loggedIn;
      if (loggedIn) {
        _hasCompletedRegistration = true;
        _hasCompletedOnboarding = true;
      }
      _isCheckingAuth = false;
    });
  }

  /// Login — preskače registraciju i onboarding, ide direktno u app.
  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
      _hasCompletedRegistration = true;
      _hasCompletedOnboarding = true;
    });
  }

  /// Register — prolazi kroz osobne podatke → dostupnost → app.
  void _handleRegister() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _handleLogout() {
    _authService.logout().then((_) {
      if (!mounted) return;
      setState(() {
        _isLoggedIn = false;
        _hasCompletedRegistration = false;
        _hasCompletedOnboarding = false;
        _availabilityNotifier.reset();
      });
    });
  }

  void _handleRegistrationComplete() {
    setState(() => _hasCompletedRegistration = true);
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
    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: _handleLogin,
        onRegisterSuccess: _handleRegister,
        localeNotifier: _localeNotifier,
      );
    }
    if (!_hasCompletedRegistration) {
      return RegistrationDataScreen(onComplete: _handleRegistrationComplete);
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
