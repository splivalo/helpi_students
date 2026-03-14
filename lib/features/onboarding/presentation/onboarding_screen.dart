import 'package:flutter/material.dart';

import 'package:helpi_student/app/theme.dart';
import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/models/availability_model.dart';
import 'package:helpi_student/core/utils/availability_helpers.dart';
import 'package:helpi_student/core/widgets/availability_day_row.dart';

/// Onboarding — student mora postaviti dostupnost prije korištenja app-a.
/// Gumb "Završi" je disabled dok nema barem 1 dan s postavljenim vremenom.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.availabilityNotifier,
    required this.onComplete,
  });

  final AvailabilityNotifier availabilityNotifier;
  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<DayAvailability> get _days => widget.availabilityNotifier.value;

  bool get _canFinish => _days.any((d) => d.enabled);

  Future<void> _pickTime({
    required DayAvailability day,
    required bool isFrom,
  }) async {
    final changed = await pickAvailabilityTime(
      context: context,
      day: day,
      isFrom: isFrom,
    );
    if (changed) {
      setState(() {});
      widget.availabilityNotifier.notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: HelpiTheme.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ── Title ──
              Text(
                AppStrings.onboardingTitle,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.onboardingSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: HelpiTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // ── Day list ──
              Expanded(
                child: ListView.builder(
                  itemCount: _days.length,
                  itemBuilder: (context, index) => _buildDayRow(_days[index]),
                ),
              ),

              // ── CTA button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canFinish ? widget.onComplete : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HelpiTheme.coral,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: HelpiTheme.border,
                    disabledForegroundColor: const Color(0xFF9E9E9E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(AppStrings.onboardingFinish),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(DayAvailability day) {
    return AvailabilityDayRow(
      day: day,
      onEnabledChanged: (v) {
        setState(() => day.enabled = v);
        widget.availabilityNotifier.notify();
      },
      onPickFrom: () => _pickTime(day: day, isFrom: true),
      onPickTo: () => _pickTime(day: day, isFrom: false),
    );
  }
}
