import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:helpi_student/core/l10n/app_strings.dart';

/// Dozvoljeni sati za radno vrijeme studenta.
const _minHour = 8;
const _maxHour = 20;

/// Svi dozvoljeni sati: 8, 9, 10 … 20.
final _hours = List.generate(_maxHour - _minHour + 1, (i) => _minHour + i);

/// Dozvoljene minute: 00, 30.
const _minutes = [0, 30];

/// Prikazuje bottom-sheet picker s dva wheela (sati 8–20, minute 00/30).
///
/// Vraća [TimeOfDay] ako korisnik potvrdi, `null` ako odustane.
Future<TimeOfDay?> showTimeSlotPicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  // Snap initial time na najbliži valjani slot.
  var hourIndex = _hours.indexOf(initialTime.hour);
  if (hourIndex < 0) {
    // Ako je sat izvan raspona, snap na granice.
    hourIndex = initialTime.hour < _minHour ? 0 : _hours.length - 1;
  }
  var minuteIndex = _minutes.indexOf(initialTime.minute);
  if (minuteIndex < 0) {
    minuteIndex = initialTime.minute < 30 ? 0 : 1;
  }

  final theme = Theme.of(context);
  final teal = theme.colorScheme.secondary;

  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      var selectedHour = _hours[hourIndex];
      var selectedMinute = _minutes[minuteIndex];

      return SafeArea(
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        AppStrings.cancel,
                        style: TextStyle(color: teal, fontSize: 16),
                      ),
                    ),
                    Text(
                      AppStrings.selectTime,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(
                        ctx,
                        TimeOfDay(hour: selectedHour, minute: selectedMinute),
                      ),
                      child: Text(
                        AppStrings.confirm,
                        style: TextStyle(
                          color: teal,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Wheels ──
              Expanded(
                child: Row(
                  children: [
                    // Sati wheel
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: hourIndex,
                        ),
                        itemExtent: 42,
                        onSelectedItemChanged: (i) => selectedHour = _hours[i],
                        children: _hours
                            .map(
                              (h) => Center(
                                child: Text(
                                  h.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // Separator
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // Minute wheel
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: minuteIndex,
                        ),
                        itemExtent: 42,
                        onSelectedItemChanged: (i) =>
                            selectedMinute = _minutes[i],
                        children: _minutes
                            .map(
                              (m) => Center(
                                child: Text(
                                  m.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
