import 'package:flutter/material.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/models/availability_model.dart';
import 'package:helpi_student/core/widgets/time_slot_picker.dart';

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
  static const _coral = Color(0xFFEF5B5B);

  List<DayAvailability> get _days => widget.availabilityNotifier.value;

  String _dayName(String key) {
    switch (key) {
      case 'dayMonFull':
        return AppStrings.dayMonFull;
      case 'dayTueFull':
        return AppStrings.dayTueFull;
      case 'dayWedFull':
        return AppStrings.dayWedFull;
      case 'dayThuFull':
        return AppStrings.dayThuFull;
      case 'dayFriFull':
        return AppStrings.dayFriFull;
      case 'daySatFull':
        return AppStrings.daySatFull;
      case 'daySunFull':
        return AppStrings.daySunFull;
      default:
        return key;
    }
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  bool get _canFinish => _days.any((d) => d.enabled);

  Future<void> _pickTime({
    required DayAvailability day,
    required bool isFrom,
  }) async {
    final initial = isFrom ? day.from : day.to;
    final picked = await showTimeSlotPicker(
      context: context,
      initialTime: initial,
      minTime: isFrom
          ? null
          : TimeOfDay(
              hour: (day.from.hour * 60 + day.from.minute + 45) ~/ 60,
              minute: (day.from.hour * 60 + day.from.minute + 45) % 60,
            ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isFrom) {
          day.from = picked;
          // Ako je novo "Od" + 1h > "Do", snap "Do" na Od + 1h.
          final fromMin = picked.hour * 60 + picked.minute;
          final toMin = day.to.hour * 60 + day.to.minute;
          if (toMin < fromMin + 60) {
            final next = fromMin + 60;
            day.to = TimeOfDay(hour: next ~/ 60, minute: next % 60);
          }
        } else {
          day.to = picked;
        }
      });
      widget.availabilityNotifier.notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F4),
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
                  color: const Color(0xFF757575),
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
                    backgroundColor: _coral,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Checkbox(
                value: day.enabled,
                onChanged: (v) {
                  setState(() => day.enabled = v ?? false);
                  widget.availabilityNotifier.notify();
                },
                activeColor: theme.colorScheme.secondary,
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                _dayName(day.dayKey),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: day.enabled ? FontWeight.w600 : FontWeight.w400,
                  color: day.enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withAlpha(120),
                ),
              ),
            ),
            const Spacer(),
            if (day.enabled) ...[
              _timeChip(
                label: AppStrings.fromTime,
                time: day.from,
                onTap: () => _pickTime(day: day, isFrom: true),
              ),
              const SizedBox(width: 8),
              _timeChip(
                label: AppStrings.toTime,
                time: day.to,
                onTap: () => _pickTime(day: day, isFrom: false),
              ),
            ] else
              Text(
                AppStrings.notSet,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _timeChip({
    required String label,
    required TimeOfDay time,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$label ${_formatTime(time)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
