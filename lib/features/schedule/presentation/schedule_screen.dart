import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/models/job_model.dart';

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

  String _serviceLabel(ServiceType type) {
    switch (type) {
      case ServiceType.shopping:
        return AppStrings.serviceShopping2;
      case ServiceType.houseHelp:
        return AppStrings.serviceHouseHelp2;
      case ServiceType.socializing:
        return AppStrings.serviceSocializing2;
      case ServiceType.walking:
        return AppStrings.serviceWalking2;
      case ServiceType.escort:
        return AppStrings.serviceEscort2;
      case ServiceType.other:
        return AppStrings.serviceOther2;
    }
  }

  IconData _serviceIcon(ServiceType type) {
    switch (type) {
      case ServiceType.shopping:
        return Icons.shopping_bag_outlined;
      case ServiceType.houseHelp:
        return Icons.cleaning_services_outlined;
      case ServiceType.socializing:
        return Icons.people_outline;
      case ServiceType.walking:
        return Icons.directions_walk_outlined;
      case ServiceType.escort:
        return Icons.accessible_forward_outlined;
      case ServiceType.other:
        return Icons.more_horiz_outlined;
    }
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

  Future<void> _showDeclineDialog(Job job) async {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.jobDeclineTitle,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: AppStrings.jobDeclineHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(AppStrings.jobDeclineConfirm),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(AppStrings.cancel),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      // Mock: makni posao iz liste
      setState(() {
        final index = _jobs.indexWhere((j) => j.id == job.id);
        if (index >= 0) {
          _jobs[index] = Job(
            id: job.id,
            date: job.date,
            from: job.from,
            to: job.to,
            serviceType: job.serviceType,
            seniorName: job.seniorName,
            address: job.address,
            status: JobStatus.cancelled,
            notes: job.notes,
          );
          _datesWithJobs = _jobs
              .where((j) => j.status != JobStatus.cancelled)
              .map((j) => DateTime(j.date.year, j.date.month, j.date.day))
              .toSet();
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.jobDeclineSuccess),
          backgroundColor: const Color(0xFF009D9D),
        ),
      );
    }
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: todayJobs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = todayJobs[index];
                      return _JobCard(
                        job: job,
                        theme: theme,
                        teal: teal,
                        formatTime: _formatTime,
                        serviceLabel: _serviceLabel,
                        serviceIcon: _serviceIcon,
                        statusLabel: _statusLabel,
                        statusColor: _statusColor,
                        onDecline: job.canDecline
                            ? () => _showDeclineDialog(job)
                            : null,
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
    required this.serviceLabel,
    required this.serviceIcon,
    required this.statusLabel,
    required this.statusColor,
    this.onDecline,
  });

  final Job job;
  final ThemeData theme;
  final Color teal;
  final String Function(TimeOfDay) formatTime;
  final String Function(ServiceType) serviceLabel;
  final IconData Function(ServiceType) serviceIcon;
  final String Function(JobStatus) statusLabel;
  final Color Function(JobStatus) statusColor;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final sColor = statusColor(job.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                Icon(Icons.access_time, size: 18, color: teal),
                const SizedBox(width: 6),
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

          const SizedBox(height: 12),

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

          const SizedBox(height: 8),

          // ── Usluga ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  serviceIcon(job.serviceType),
                  size: 20,
                  color: const Color(0xFF757575),
                ),
                const SizedBox(width: 8),
                Text(
                  serviceLabel(job.serviceType),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Adresa ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
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

          // ── Napomene (ako postoje) ──
          if (job.notes != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_outlined,
                    size: 20,
                    color: Color(0xFF757575),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.notes!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Ne mogu gumb ──
          if (onDecline != null) ...[
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDecline,
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(AppStrings.jobDecline),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF5B5B),
                    side: const BorderSide(color: Color(0xFFEF5B5B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}
