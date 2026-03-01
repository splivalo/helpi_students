import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/models/job_model.dart';
import 'package:helpi_student/features/schedule/presentation/job_detail_screen.dart';

/// Raspored ekran — tjedni strip + lista poslova za odabrani dan.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  late DateTime _weekStart;
  late List<Job> _jobs;
  late Set<DateTime> _datesWithJobs;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _weekStart = _getWeekStart(_selectedDate);
    _jobs = List.of(MockJobs.all);
    _datesWithJobs = MockJobs.datesWithJobs;
  }

  DateTime _getWeekStart(DateTime date) {
    // Ponedjeljak = 1
    final diff = date.weekday - 1;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: diff));
  }

  List<Job> _jobsForDate(DateTime date) {
    return _jobs
        .where(
          (j) =>
              j.date.year == date.year &&
              j.date.month == date.month &&
              j.date.day == date.day,
        )
        .toList()
      ..sort(
        (a, b) => (a.from.hour * 60 + a.from.minute).compareTo(
          b.from.hour * 60 + b.from.minute,
        ),
      );
  }

  bool _hasJobs(DateTime date) {
    return _datesWithJobs.contains(DateTime(date.year, date.month, date.day));
  }

  void _selectDate(DateTime date) {
    HapticFeedback.selectionClick();
    setState(() => _selectedDate = date);
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDate = _weekStart;
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDate = _weekStart;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}.';
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) return AppStrings.scheduleToday;
    if (date == tomorrow) return AppStrings.scheduleTomorrow;

    final dayNames = [
      AppStrings.dayMonShort,
      AppStrings.dayTueShort,
      AppStrings.dayWedShort,
      AppStrings.dayThuShort,
      AppStrings.dayFriShort,
      AppStrings.daySatShort,
      AppStrings.daySunShort,
    ];
    return '${dayNames[date.weekday - 1]}, ${_formatDate(date)}';
  }

  String _statusLabel(JobStatus status) {
    switch (status) {
      case JobStatus.assigned:
        return AppStrings.jobStatusAssigned;
      case JobStatus.completed:
        return AppStrings.jobStatusCompleted;
      case JobStatus.cancelled:
        return AppStrings.jobStatusCancelled;
    }
  }

  Color _statusColor(JobStatus status) {
    switch (status) {
      case JobStatus.assigned:
        return const Color(0xFF009D9D);
      case JobStatus.completed:
        return const Color(0xFF757575);
      case JobStatus.cancelled:
        return const Color(0xFFC62828);
    }
  }

  void _openJobDetail(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => JobDetailScreen(
          job: job,
          onJobUpdated: (updated) {
            setState(() {
              final idx = _jobs.indexWhere((j) => j.id == updated.id);
              if (idx != -1) {
                _jobs[idx] = updated;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teal = theme.colorScheme.secondary;
    final todayJobs = _jobsForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.scheduleTitle)),
      body: Column(
        children: [
          // ── Tjedni strip ──
          _WeekStrip(
            weekStart: _weekStart,
            selectedDate: _selectedDate,
            hasJobs: _hasJobs,
            onDateSelected: _selectDate,
            onPreviousWeek: _previousWeek,
            onNextWeek: _nextWeek,
            teal: teal,
          ),

          // ── Odabrani dan label ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _dayLabel(_selectedDate),
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ),

          // ── Lista poslova ──
          Expanded(
            child: todayJobs.isEmpty
                ? _EmptyDayState(theme: theme, teal: teal)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: todayJobs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = todayJobs[index];
                      return _JobCard(
                        job: job,
                        theme: theme,
                        teal: teal,
                        formatTime: _formatTime,
                        statusLabel: _statusLabel,
                        statusColor: _statusColor,
                        onTap: () => _openJobDetail(job),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  WEEKLY STRIP — horizontalni tjedan s navigacijom
// ═══════════════════════════════════════════════════════════════

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.weekStart,
    required this.selectedDate,
    required this.hasJobs,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.teal,
  });

  final DateTime weekStart;
  final DateTime selectedDate;
  final bool Function(DateTime) hasJobs;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final Color teal;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dayLabels = [
      AppStrings.dayMonShort,
      AppStrings.dayTueShort,
      AppStrings.dayWedShort,
      AppStrings.dayThuShort,
      AppStrings.dayFriShort,
      AppStrings.daySatShort,
      AppStrings.daySunShort,
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // ── Month + arrows ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28),
                  onPressed: onPreviousWeek,
                  color: teal,
                ),
                Text(
                  _monthLabel(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 28),
                  onPressed: onNextWeek,
                  color: teal,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ── Days row ──
          Row(
            children: List.generate(7, (i) {
              final date = weekStart.add(Duration(days: i));
              final isSelected =
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isToday =
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final hasDot = hasJobs(date);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? teal : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayLabels[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isToday && !isSelected
                                ? Border.all(color: teal, width: 2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                  ? teal
                                  : const Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Dot indicator za dane s poslom
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasDot
                                ? (isSelected
                                      ? Colors.white
                                      : const Color(0xFFEF5B5B))
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _monthLabel(BuildContext context) {
    // Prikaži mjesec + godinu sredine tjedna
    final mid = weekStart.add(const Duration(days: 3));
    return '${AppStrings.monthName(mid.month)} ${mid.year}';
  }
}

// ═══════════════════════════════════════════════════════════════
//  EMPTY STATE — kada nema poslova za odabrani dan
// ═══════════════════════════════════════════════════════════════

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState({required this.theme, required this.teal});

  final ThemeData theme;
  final Color teal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 80,
              color: teal.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.scheduleNoJobs,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.scheduleNoJobsSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  JOB CARD — kartica jednog posla
// ═══════════════════════════════════════════════════════════════

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.theme,
    required this.teal,
    required this.formatTime,
    required this.statusLabel,
    required this.statusColor,
    this.onTap,
  });

  final Job job;
  final ThemeData theme;
  final Color teal;
  final String Function(TimeOfDay) formatTime;
  final String Function(JobStatus) statusLabel;
  final Color Function(JobStatus) statusColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sColor = statusColor(job.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Gornji dio: vrijeme + status chip ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: teal),
                    const SizedBox(width: 8),
                    Text(
                      '${formatTime(job.from)} – ${formatTime(job.to)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: sColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel(job.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 20, thickness: 0.5),

              // ── Korisnik ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: teal),
                    const SizedBox(width: 8),
                    Text(
                      job.seniorName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 20, thickness: 0.5),

              // ── Adresa ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 20,
                      color: Color(0xFF757575),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.address,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 20, thickness: 0.5),

              // ── Prikaži više ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.showMore,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: teal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 20, color: teal),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
