import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/models/job_model.dart';
import 'package:helpi_student/core/models/review_model.dart';

/// Detalji jednog posla — prikazuje sve info + sekcija za ocjenu seniora.
class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({
    super.key,
    required this.job,
    required this.onJobUpdated,
  });

  final Job job;
  final ValueChanged<Job> onJobUpdated;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Job _job;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';
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
        return Icons.elderly_woman_outlined;
      case ServiceType.escort:
        return Icons.assist_walker_outlined;
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

  void _showReviewSheet() {
    int selectedRating = 0;
    final commentCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final theme = Theme.of(ctx);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${AppStrings.rateSenior}: ${_job.seniorName}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() => selectedRating = i + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            i < selectedRating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFC107),
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: AppStrings.reviewHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedRating > 0
                          ? () {
                              final now = DateTime.now();
                              final dateStr =
                                  '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
                              final review = ReviewModel(
                                rating: selectedRating,
                                comment: commentCtrl.text.trim(),
                                date: dateStr,
                              );
                              Navigator.pop(ctx);
                              _onReviewSubmitted(review);
                            }
                          : null,
                      child: Text(AppStrings.sendReview),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onReviewSubmitted(ReviewModel review) {
    if (!mounted) return;
    final updatedJob = Job(
      id: _job.id,
      date: _job.date,
      from: _job.from,
      to: _job.to,
      serviceTypes: _job.serviceTypes,
      seniorName: _job.seniorName,
      address: _job.address,
      status: _job.status,
      notes: _job.notes,
      review: review,
    );
    setState(() => _job = updatedJob);
    widget.onJobUpdated(updatedJob);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.reviewSent),
        backgroundColor: const Color(0xFF009D9D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teal = theme.colorScheme.secondary;
    final sColor = _statusColor(_job.status);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.jobDetailTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ CARD 1: Detalji posla (isti layout kao _JobCard) ═══
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Datum + status chip ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: teal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(_job.date),
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
                            _statusLabel(_job.status),
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

                  // ── Vrijeme ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 20,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatTime(_job.from)} – ${_formatTime(_job.to)}',
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
                            _job.address,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Usluge (chipovi) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _job.serviceTypes.map((type) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _serviceIcon(type),
                                size: 16,
                                color: const Color(0xFF757575),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _serviceLabel(type),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ── Napomene ──
                  if (_job.notes != null) ...[
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
                              _job.notes!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ═══ CARD 2: Korisnik (Senior) + Review ═══
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.jobSenior,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Ime seniora + Ocijeni gumb ──
                  Row(
                    children: [
                      // Circle avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: teal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _job.seniorName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Ocijeni gumb — samo za completed bez reviewova
                      if (_job.status == JobStatus.completed &&
                          _job.review == null)
                        SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: _showReviewSheet,
                            icon: const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(AppStrings.rateSenior),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF5B5B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              minimumSize: Size.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ── Prikaz recenzije (ako postoji) ──
                  if (_job.review != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.yourReview,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F7F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < _job.review!.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: const Color(0xFFFFC107),
                                  size: 16,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _job.review!.date,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (_job.review!.comment.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _job.review!.comment,
                                style: theme.textTheme.bodySmall,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Ne mogu gumb (za assigned, >24h) ──
            if (_job.canDecline) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeclineFromDetail(),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(AppStrings.jobDecline),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF5B5B),
                    side: const BorderSide(color: Color(0xFFEF5B5B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showDeclineFromDetail() async {
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
      final updatedJob = Job(
        id: _job.id,
        date: _job.date,
        from: _job.from,
        to: _job.to,
        serviceTypes: _job.serviceTypes,
        seniorName: _job.seniorName,
        address: _job.address,
        status: JobStatus.cancelled,
        notes: _job.notes,
      );
      setState(() => _job = updatedJob);
      widget.onJobUpdated(updatedJob);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.jobDeclineSuccess),
          backgroundColor: const Color(0xFF009D9D),
        ),
      );
    }
  }
}
