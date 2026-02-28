import 'package:flutter/material.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/l10n/locale_notifier.dart';
import 'package:helpi_student/core/models/availability_model.dart';
import 'package:helpi_student/core/widgets/time_slot_picker.dart';

/// Profil ekran — pristupni podaci, dostupnost, jezik, uvjeti, odjava.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.localeNotifier,
    required this.onLogout,
    required this.availabilityNotifier,
  });

  final LocaleNotifier localeNotifier;
  final VoidCallback onLogout;
  final AvailabilityNotifier availabilityNotifier;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Pristupni podaci ──────────────────────────
  final _emailCtrl = TextEditingController(text: 'ana.student@email.com');

  // ── Osobni podaci studenta ─────────────────────
  final _firstNameCtrl = TextEditingController(text: 'Ana');
  final _lastNameCtrl = TextEditingController(text: 'Horvat');
  final _phoneCtrl = TextEditingController(text: '+385 91 555 1234');
  final _addressCtrl = TextEditingController(text: 'Savska 25, Zagreb');
  String _gender = 'F';
  DateTime _dob = DateTime(2002, 5, 10);

  // ── Ostalo ────────────────────────────────────
  late String _selectedLang = AppStrings.currentLocale.toUpperCase();
  bool _isEditing = false;
  bool _agreedToTerms = true;

  // ── Dostupnost — čita/piše iz dijeljenog notifiera ─────
  List<DayAvailability> get _availability => widget.availabilityNotifier.value;

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime({
    required DayAvailability day,
    required bool isFrom,
  }) async {
    final initial = isFrom ? day.from : day.to;
    final picked = await showTimeSlotPicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null && context.mounted) {
      setState(() {
        if (isFrom) {
          day.from = picked;
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
      appBar: AppBar(title: Text(AppStrings.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── PRISTUPNI PODACI ────────────────────────
          _sectionHeader(AppStrings.accessData),
          const SizedBox(height: 12),
          _buildField(
            AppStrings.email,
            _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.lock_outline, size: 20),
            label: Text(AppStrings.changePassword),
          ),
          const SizedBox(height: 32),

          // ── OSOBNI PODACI ───────────────────────────
          _sectionHeader(AppStrings.studentData),
          const SizedBox(height: 12),
          _buildField(AppStrings.firstName, _firstNameCtrl),
          const SizedBox(height: 12),
          _buildField(AppStrings.lastName, _lastNameCtrl),
          const SizedBox(height: 12),
          _buildGenderPicker(_gender, (v) => setState(() => _gender = v)),
          const SizedBox(height: 12),
          _buildDatePicker(
            AppStrings.dateOfBirth,
            _dob,
            (d) => setState(() => _dob = d),
          ),
          const SizedBox(height: 12),
          _buildField(
            AppStrings.phone,
            _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildField(AppStrings.address, _addressCtrl),
          const SizedBox(height: 32),

          // ── DOSTUPNOST ──────────────────────────────
          _sectionHeader(AppStrings.availabilitySection),
          const SizedBox(height: 4),
          Text(
            AppStrings.availabilityDescription,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ..._availability.map((day) => _buildDayRow(day)),
          const SizedBox(height: 8),

          // ── UVJETI ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: _isEditing
                    ? (v) => setState(() => _agreedToTerms = v ?? false)
                    : null,
                activeColor: theme.colorScheme.secondary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: otvori uvjete korištenja
                  },
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(text: AppStrings.agreeToTerms),
                        TextSpan(
                          text: AppStrings.termsOfUse,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                            decorationColor: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── UREDI / SPREMI ──────────────────────────
          SizedBox(
            width: double.infinity,
            child: _isEditing
                ? Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => _isEditing = false),
                        child: Text(AppStrings.save),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() => _isEditing = false),
                        child: Text(AppStrings.cancel),
                      ),
                    ],
                  )
                : OutlinedButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit, size: 20),
                    label: Text(AppStrings.editProfile),
                  ),
          ),
          const SizedBox(height: 32),

          // ── JEZIK ───────────────────────────────────
          InputDecorator(
            decoration: InputDecoration(
              labelText: AppStrings.language,
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha(180),
              ),
              prefixIcon: Icon(
                Icons.language,
                color: theme.colorScheme.secondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLang,
                isDense: true,
                isExpanded: true,
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedLang = v);
                    widget.localeNotifier.setLocale(v);
                  }
                },
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
                items: const [
                  DropdownMenuItem(value: 'HR', child: Text('Hrvatski')),
                  DropdownMenuItem(value: 'EN', child: Text('English')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── ODJAVA ──────────────────────────────────
          OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            label: Text(AppStrings.logout),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF5B5B),
              side: const BorderSide(color: Color(0xFFEF5B5B), width: 2),
            ),
          ),
          const SizedBox(height: 32),

          // ── Verzija ─────────────────────────────────
          Center(child: Text('Helpi v1.0.0', style: theme.textTheme.bodySmall)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────

  Widget _sectionHeader(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: _isEditing,
      style: TextStyle(
        color: _isEditing
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface.withAlpha(153),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withAlpha(_isEditing ? 180 : 153),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        filled: true,
        fillColor: Colors.white,
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
            // Checkbox za dan
            SizedBox(
              width: 32,
              child: Checkbox(
                value: day.enabled,
                onChanged: _isEditing
                    ? (v) {
                        setState(() => day.enabled = v ?? false);
                        widget.availabilityNotifier.notify();
                      }
                    : null,
                activeColor: theme.colorScheme.secondary,
              ),
            ),
            // Naziv dana
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
            // Od - Do
            if (day.enabled) ...[
              _timeChip(
                label: AppStrings.fromTime,
                time: day.from,
                onTap: _isEditing
                    ? () => _pickTime(day: day, isFrom: true)
                    : null,
              ),
              const SizedBox(width: 8),
              _timeChip(
                label: AppStrings.toTime,
                time: day.to,
                onTap: _isEditing
                    ? () => _pickTime(day: day, isFrom: false)
                    : null,
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

  Widget _buildGenderPicker(String value, ValueChanged<String> onChanged) {
    final theme = Theme.of(context);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: AppStrings.gender,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withAlpha(_isEditing ? 180 : 153),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabled: _isEditing,
        filled: true,
        fillColor: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          onChanged: _isEditing
              ? (v) {
                  if (v != null) onChanged(v);
                }
              : null,
          style: TextStyle(
            color: _isEditing
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withAlpha(153),
            fontSize: 16,
          ),
          items: [
            DropdownMenuItem(value: 'M', child: Text(AppStrings.genderMale)),
            DropdownMenuItem(value: 'F', child: Text(AppStrings.genderFemale)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    ValueChanged<DateTime> onChanged,
  ) {
    final theme = Theme.of(context);
    final formatted =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';

    return GestureDetector(
      onTap: _isEditing
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (picked != null && context.mounted) {
                onChanged(picked);
              }
            }
          : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withAlpha(
              _isEditing ? 180 : 153,
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _isEditing
                  ? theme.colorScheme.onSurface.withAlpha(100)
                  : const Color(0xFFE0E0E0),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: _isEditing
              ? Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: theme.colorScheme.secondary,
                )
              : null,
        ),
        child: Text(
          formatted,
          style: TextStyle(
            color: _isEditing
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withAlpha(153),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
