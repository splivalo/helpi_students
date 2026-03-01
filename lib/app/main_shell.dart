import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/l10n/locale_notifier.dart';
import 'package:helpi_student/core/models/availability_model.dart';
import 'package:helpi_student/features/chat/presentation/chat_list_screen.dart';
import 'package:helpi_student/features/profile/presentation/profile_screen.dart';
import 'package:helpi_student/features/schedule/presentation/schedule_screen.dart';
import 'package:helpi_student/features/statistics/presentation/statistics_screen.dart';

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
      const ScheduleScreen(),
      const ChatScreen(),
      const StatisticsScreen(),
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
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.bar_chart),
              label: AppStrings.navStatistics,
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
