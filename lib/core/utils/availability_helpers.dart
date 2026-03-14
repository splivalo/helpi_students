import 'package:flutter/material.dart';

import 'package:helpi_student/core/models/availability_model.dart';
import 'package:helpi_student/core/widgets/time_slot_picker.dart';

/// Pick and update availability time for a day slot.
///
/// Mutates [day.from] or [day.to] in place. Returns `true` if a time
/// was selected and the day object was updated, `false` otherwise.
/// Caller is responsible for calling `setState()` and notifying listeners.
Future<bool> pickAvailabilityTime({
  required BuildContext context,
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
  if (picked == null || !context.mounted) return false;

  if (isFrom) {
    day.from = picked;
    final fromMin = picked.hour * 60 + picked.minute;
    final toMin = day.to.hour * 60 + day.to.minute;
    if (toMin < fromMin + 60) {
      final next = fromMin + 60;
      day.to = TimeOfDay(hour: next ~/ 60, minute: next % 60);
    }
  } else {
    day.to = picked;
  }
  return true;
}
