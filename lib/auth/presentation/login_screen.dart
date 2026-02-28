import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/l10n/locale_notifier.dart';

/// Login / Register ekran — UI prototype, bez prave autentikacije.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.localeNotifier,
  });

  /// Callback kad korisnik "uspješno" klikne Login ili Register.
  final VoidCallback onLoginSuccess;
  final LocaleNotifier localeNotifier;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _coral = Color(0xFFEF5B5B);
  static const _teal = Color(0xFF009D9D);

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late String _selectedLang = AppStrings.currentLocale.toUpperCase();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F4),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // ── Logo / Branding ──
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: _coral,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/h_logo.svg',
                          width: 50,
                          height: 50,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Title ──
                    Text(
                      AppStrings.loginTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.loginSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Email field ──
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppStrings.loginEmail,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: _teal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Password field ──
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: AppStrings.loginPassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: _teal,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF757575),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Forgot password ──
                    if (!_isRegisterMode)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Prototype — no action
                          },
                          child: Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(color: _teal, fontSize: 14),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // ── Main CTA button ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: widget.onLoginSuccess,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _coral,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          _isRegisterMode
                              ? AppStrings.registerButton
                              : AppStrings.loginButton,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Divider "or continue with" ──
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            AppStrings.orContinueWith,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Social buttons ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButtonSvg('assets/images/google_logo.svg'),
                        const SizedBox(width: 16),
                        _socialButtonSvg('assets/images/apple_logo.svg'),
                        const SizedBox(width: 16),
                        _socialButtonSvg('assets/images/facebook_logo.svg'),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Toggle login / register ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRegisterMode
                              ? AppStrings.hasAccount
                              : AppStrings.noAccount,
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _isRegisterMode = !_isRegisterMode);
                          },
                          child: Text(
                            _isRegisterMode
                                ? AppStrings.loginButton
                                : AppStrings.registerButton,
                            style: const TextStyle(
                              color: _coral,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Language picker ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.language, color: _teal, size: 20),
                        const SizedBox(width: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLang,
                            isDense: true,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 15,
                            ),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedLang = v);
                                widget.localeNotifier.setLocale(v);
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'HR',
                                child: Text('Hrvatski'),
                              ),
                              DropdownMenuItem(
                                value: 'EN',
                                child: Text('English'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _socialButtonSvg(String assetPath) {
    return GestureDetector(
      onTap: widget.onLoginSuccess,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Center(
          child: SvgPicture.asset(assetPath, width: 24, height: 24),
        ),
      ),
    );
  }
}
