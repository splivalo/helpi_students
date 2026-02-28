import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/l10n/locale_notifier.dart';
import 'package:helpi_student/core/models/availability_model.dart';
import 'package:helpi_student/features/chat/presentation/chat_list_screen.dart';
import 'package:helpi_student/features/profile/presentation/profile_screen.dart';

/// Glavni shell s BottomNavigationBar — 4 studentska taba.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.onLogout,
    required this.localeNotifier,
    required this.availabilityNotifier,
  });

  final VoidCallback onLogout;
  final LocaleNotifier localeNotifier;
  final AvailabilityNotifier availabilityNotifier;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _PlaceholderScreen(title: AppStrings.navDashboard),
      _PlaceholderScreen(title: AppStrings.navSchedule),
      const ChatScreen(),
      ProfileScreen(
        localeNotifier: widget.localeNotifier,
        onLogout: widget.onLogout,
        availabilityNotifier: widget.availabilityNotifier,
      ),
    ];
  }

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          iconSize: 28,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: AppStrings.navDashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
              label: AppStrings.navSchedule,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              activeIcon: const Icon(Icons.chat_bubble),
              label: AppStrings.navMessages,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

/// Privremeni placeholder ekran za svaki tab dok se ne implementira
/// stvarni sadržaj.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 80,
              color: theme.colorScheme.secondary.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              AppStrings.loading,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
