import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/models/job_model.dart';
import 'package:helpi_student/core/models/review_model.dart';

/// Statistika ekran — tjedni/mjesečni pregled sati + prosječna ocjena.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _teal = Color(0xFF009D9D);
  static const _grey = Color(0xFF757575);
  static const _cardBorder = Color(0xFFE0E0E0);
  static const _star = Color(0xFFFFC107);
  static const _offWhite = Color(0xFFF9F7F4);
  static const _barBg = Color(0xFFF0F0F0);

  late DateTime _currentWeekStart;
  late DateTime _currentMonthStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    _currentMonthStart = DateTime(now.year, now.month);
  }

  // Data helpers

  List<Job> get _completedJobs =>
      MockJobs.all.where((j) => j.status == JobStatus.completed).toList();

  double _hoursForJobs(List<Job> jobs) {
    double sum = 0;
    for (final j in jobs) {
      final fromMin = j.from.hour * 60 + j.from.minute;
      final toMin = j.to.hour * 60 + j.to.minute;
      sum += (toMin - fromMin) / 60;
    }
    return sum;
  }

  List<Job> _jobsInRange(DateTime from, DateTime to) {
    return _completedJobs.where((j) {
      final d = DateTime(j.date.year, j.date.month, j.date.day);
      return !d.isBefore(from) && d.isBefore(to);
    }).toList();
  }

  List<double> _weeklyHours(DateTime weekStart) {
    final result = List.filled(7, 0.0);
    final jobs = _jobsInRange(
      weekStart,
      weekStart.add(const Duration(days: 7)),
    );
    for (final j in jobs) {
      final d = DateTime(j.date.year, j.date.month, j.date.day);
      final dayIndex = d.difference(weekStart).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        final fromMin = j.from.hour * 60 + j.from.minute;
        final toMin = j.to.hour * 60 + j.to.minute;
        result[dayIndex] += (toMin - fromMin) / 60;
      }
    }
    return result;
  }

  List<_WeekRange> _monthlyWeeks(DateTime monthStart) {
    final weeks = <_WeekRange>[];
    var weekStart = monthStart.subtract(Duration(days: monthStart.weekday - 1));
    final nextMonth = (monthStart.month == 12)
        ? DateTime(monthStart.year + 1, 1)
        : DateTime(monthStart.year, monthStart.month + 1);

    while (weekStart.isBefore(nextMonth)) {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final jobs = _jobsInRange(weekStart, weekEnd);
      final hours = _hoursForJobs(jobs);
      weeks.add(
        _WeekRange(
          from: weekStart,
          to: weekEnd.subtract(const Duration(days: 1)),
          hours: hours,
        ),
      );
      weekStart = weekEnd;
    }
    return weeks;
  }

  double _averageRating() {
    final reviewed = _completedJobs.where((j) => j.review != null).toList();
    if (reviewed.isEmpty) return 0;
    final sum = reviewed.fold<int>(0, (s, j) => s + j.review!.rating);
    return sum / reviewed.length;
  }

  List<_ReviewEntry> _allReviews() {
    final reviewed = _completedJobs.where((j) => j.review != null).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return reviewed
        .map((j) => _ReviewEntry(seniorName: j.seniorName, review: j.review!))
        .toList();
  }

  // Format helpers

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';

  String _fmtDateFull(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}.';

  static const _dayLabels = ['P', 'U', 'S', 'Č', 'P', 'S', 'N'];

  static const _monthNames = [
    'Siječanj',
    'Veljača',
    'Ožujak',
    'Travanj',
    'Svibanj',
    'Lipanj',
    'Srpanj',
    'Kolovoz',
    'Rujan',
    'Listopad',
    'Studeni',
    'Prosinac',
  ];

  // Navigation

  void _prevWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  void _prevMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      final m = _currentMonthStart.month;
      final y = _currentMonthStart.year;
      _currentMonthStart = m == 1 ? DateTime(y - 1, 12) : DateTime(y, m - 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      final m = _currentMonthStart.month;
      final y = _currentMonthStart.year;
      _currentMonthStart = m == 12 ? DateTime(y + 1, 1) : DateTime(y, m + 1);
    });
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        title: Text(
          AppStrings.statsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          _buildWeeklySection(theme),
          const SizedBox(height: 24),
          _buildMonthlySection(theme),
          const SizedBox(height: 24),
          _buildRatingSection(theme),
          const SizedBox(height: 24),
          _buildReviewsSection(theme),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Weekly section

  Widget _buildWeeklySection(ThemeData theme) {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    final dailyHours = _weeklyHours(_currentWeekStart);
    final totalHours = dailyHours.fold(0.0, (a, b) => a + b);
    final maxH = dailyHours.reduce((a, b) => a > b ? a : b);

    final prevWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    final prevHours = _weeklyHours(prevWeekStart);
    final prevTotal = prevHours.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.statsWeeklyReview,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: _grey),
                onPressed: _prevWeek,
                splashRadius: 20,
              ),
              Text(
                '${_fmtDate(_currentWeekStart)} – ${_fmtDateFull(weekEnd)}',
                style: theme.textTheme.bodyMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: _grey),
                onPressed: _nextWeek,
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final h = dailyHours[i];
                final barRatio = maxH > 0 ? h / maxH : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (h > 0)
                          Text(
                            '${h.toStringAsFixed(0)}h',
                            style: const TextStyle(fontSize: 10, color: _grey),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: maxH > 0 ? 100 * barRatio : 0,
                          constraints: const BoxConstraints(minHeight: 4),
                          decoration: BoxDecoration(
                            color: h > 0 ? _teal : _barBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dayLabels[i],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          _buildComparison(
            theme,
            totalHours,
            prevTotal,
            AppStrings.statsPeriodWeek,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: _barBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppStrings.statsTotalHoursValue(totalHours.toStringAsFixed(1)),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Monthly section

  Widget _buildMonthlySection(ThemeData theme) {
    final weeks = _monthlyWeeks(_currentMonthStart);
    final totalHours = weeks.fold(0.0, (s, w) => s + w.hours);
    final maxH = weeks.isEmpty
        ? 1.0
        : weeks.map((w) => w.hours).reduce((a, b) => a > b ? a : b);

    final prevMonth = _currentMonthStart.month == 1
        ? DateTime(_currentMonthStart.year - 1, 12)
        : DateTime(_currentMonthStart.year, _currentMonthStart.month - 1);
    final prevWeeks = _monthlyWeeks(prevMonth);
    final prevTotal = prevWeeks.fold(0.0, (s, w) => s + w.hours);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.statsMonthlyReview,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: _grey),
                onPressed: _prevMonth,
                splashRadius: 20,
              ),
              Text(
                _monthNames[_currentMonthStart.month - 1],
                style: theme.textTheme.bodyMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: _grey),
                onPressed: _nextMonth,
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeks.asMap().entries.map((entry) {
                final w = entry.value;
                final barRatio = maxH > 0 ? w.hours / maxH : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (w.hours > 0)
                          Flexible(
                            child: Text(
                              '${w.hours.toStringAsFixed(0)}h',
                              style: const TextStyle(
                                fontSize: 10,
                                color: _grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: maxH > 0 ? 100 * barRatio : 0,
                          constraints: const BoxConstraints(minHeight: 4),
                          decoration: BoxDecoration(
                            color: w.hours > 0 ? _teal : _barBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_fmtDate(w.from)}\n${_fmtDate(w.to)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 9, color: _grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _buildComparison(
            theme,
            totalHours,
            prevTotal,
            AppStrings.statsPeriodMonth,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: _barBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppStrings.statsTotalHoursValue(totalHours.toStringAsFixed(1)),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Comparison widget

  Widget _buildComparison(
    ThemeData theme,
    double current,
    double previous,
    String period,
  ) {
    if (previous == 0 && current == 0) {
      return const SizedBox.shrink();
    }

    String text;
    Color color;
    IconData icon;

    if (previous == 0) {
      text = AppStrings.statsCompareMore('100', period);
      color = _teal;
      icon = Icons.trending_up;
    } else if (current == previous) {
      text = AppStrings.statsCompareSame(period);
      color = _grey;
      icon = Icons.trending_flat;
    } else {
      final pct = (((current - previous).abs() / previous) * 100).round();
      if (current > previous) {
        text = AppStrings.statsCompareMore(pct.toString(), period);
        color = _teal;
        icon = Icons.trending_up;
      } else {
        text = AppStrings.statsCompareLess(pct.toString(), period);
        color = const Color(0xFFC62828);
        icon = Icons.trending_down;
      }
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: _grey),
          ),
        ),
      ],
    );
  }

  // Rating section

  Widget _buildRatingSection(ThemeData theme) {
    final avg = _averageRating();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.statsAvgRating,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < avg.round();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  filled ? Icons.star : Icons.star_border,
                  size: 36,
                  color: _star,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            avg > 0 ? avg.toStringAsFixed(1) : '–',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _teal,
            ),
          ),
        ],
      ),
    );
  }

  // Reviews section

  static const _previewCount = 3;

  Widget _buildReviewsSection(ThemeData theme) {
    final allReviews = _allReviews();
    final preview = allReviews.take(_previewCount).toList();
    final hasMore = allReviews.length > _previewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.statsRecentReviews,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (allReviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Center(
              child: Text(
                AppStrings.statsNoReviews,
                style: theme.textTheme.bodyMedium?.copyWith(color: _grey),
              ),
            ),
          )
        else ...[
          ...preview.map((r) => _buildReviewCard(theme, r)),
          if (hasMore)
            Center(
              child: TextButton(
                onPressed: () => _showAllReviews(context, allReviews),
                child: Text(
                  AppStrings.statsShowAllReviews,
                  style: const TextStyle(
                    color: _teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  void _showAllReviews(BuildContext context, List<_ReviewEntry> reviews) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _offWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    AppStrings.statsAllReviews,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: reviews.length,
                      itemBuilder: (ctx, i) =>
                          _buildReviewCard(theme, reviews[i]),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReviewCard(ThemeData theme, _ReviewEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: _teal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.seniorName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  entry.review.date,
                  style: theme.textTheme.bodySmall?.copyWith(color: _grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < entry.review.rating ? Icons.star : Icons.star_border,
                  size: 20,
                  color: _star,
                );
              }),
            ),
            if (entry.review.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(entry.review.comment, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

// Helper classes

class _WeekRange {
  const _WeekRange({required this.from, required this.to, required this.hours});

  final DateTime from;
  final DateTime to;
  final double hours;
}

class _ReviewEntry {
  const _ReviewEntry({required this.seniorName, required this.review});

  final String seniorName;
  final ReviewModel review;
}
