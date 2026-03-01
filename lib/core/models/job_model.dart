import 'package:flutter/material.dart';

import 'package:helpi_student/core/models/review_model.dart';

/// Tip usluge koju student obavlja.
enum ServiceType { shopping, houseHelp, socializing, walking, escort, other }

/// Status dodijeljenog posla.
enum JobStatus { assigned, completed, cancelled }

/// Model jednog dodijeljenog posla za studenta.
class Job {
  const Job({
    required this.id,
    required this.date,
    required this.from,
    required this.to,
    required this.serviceTypes,
    required this.seniorName,
    required this.address,
    this.status = JobStatus.assigned,
    this.notes,
    this.review,
  });

  final String id;
  final DateTime date;
  final TimeOfDay from;
  final TimeOfDay to;
  final List<ServiceType> serviceTypes;
  final String seniorName;
  final String address;
  final JobStatus status;
  final String? notes;
  final ReviewModel? review;

  /// Može li student otkazati ovaj posao (>24h do početka i status assigned)?
  bool get canDecline {
    if (status != JobStatus.assigned) return false;
    final jobStart = DateTime(
      date.year,
      date.month,
      date.day,
      from.hour,
      from.minute,
    );
    return jobStart.difference(DateTime.now()).inHours > 24;
  }
}

/// Mock podaci za raspored.
class MockJobs {
  MockJobs._();

  static final List<Job> all = _generateMockJobs();

  static List<Job> _generateMockJobs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      // Danas — 4 posla (sva 3 statusa za pregled)
      Job(
        id: '1',
        date: today,
        from: const TimeOfDay(hour: 9, minute: 0),
        to: const TimeOfDay(hour: 11, minute: 0),
        serviceTypes: [ServiceType.shopping],
        seniorName: 'Marija Horvat',
        address: 'Ilica 42, Zagreb',
        status: JobStatus.completed,
        notes:
            'Kupiti lijekove u ljekarni Zdravlje na uglu, zatim namirnice po popisu koji je na hladnjaku - mlijeko, kruh, jaja, maslac, sir, jogurt i voće.',
      ),
      Job(
        id: '2',
        date: today,
        from: const TimeOfDay(hour: 12, minute: 0),
        to: const TimeOfDay(hour: 13, minute: 30),
        serviceTypes: [
          ServiceType.socializing,
          ServiceType.shopping,
          ServiceType.walking,
          ServiceType.houseHelp,
          ServiceType.escort,
          ServiceType.other,
        ],
        seniorName: 'Ivan Kovačević',
        address: 'Vukovarska 78, Zagreb',
        status: JobStatus.assigned,
      ),
      Job(
        id: '2b',
        date: today,
        from: const TimeOfDay(hour: 14, minute: 0),
        to: const TimeOfDay(hour: 15, minute: 0),
        serviceTypes: [ServiceType.escort],
        seniorName: 'Stjepan Novak',
        address: 'Vlaška 90, Zagreb',
        status: JobStatus.cancelled,
        notes: 'Otkazano zbog bolesti.',
      ),
      Job(
        id: '2c',
        date: today,
        from: const TimeOfDay(hour: 16, minute: 0),
        to: const TimeOfDay(hour: 18, minute: 0),
        serviceTypes: [ServiceType.walking],
        seniorName: 'Dragica Perić',
        address: 'Trg bana Jelačića 5, Zagreb',
        status: JobStatus.assigned,
      ),
      Job(
        id: '2d',
        date: today,
        from: const TimeOfDay(hour: 18, minute: 30),
        to: const TimeOfDay(hour: 20, minute: 0),
        serviceTypes: [ServiceType.houseHelp],
        seniorName: 'Božena Šimunić',
        address: 'Ozaljska 22, Zagreb',
        status: JobStatus.assigned,
        notes:
            'Usisati stan, oprati suđe i obrisati prašinu u dnevnom boravku.',
      ),
      Job(
        id: '2e',
        date: today,
        from: const TimeOfDay(hour: 20, minute: 30),
        to: const TimeOfDay(hour: 21, minute: 30),
        serviceTypes: [ServiceType.other],
        seniorName: 'Franjo Kolar',
        address: 'Dubrava 150, Zagreb',
        status: JobStatus.assigned,
        notes: 'Pomoć s instalacijom TV aplikacija i podešavanjem mobitela.',
      ),

      // Sutra — 1 posao
      Job(
        id: '3',
        date: today.add(const Duration(days: 1)),
        from: const TimeOfDay(hour: 10, minute: 0),
        to: const TimeOfDay(hour: 12, minute: 0),
        serviceTypes: [ServiceType.escort],
        seniorName: 'Ana Babić',
        address: 'Heinzelova 15, Zagreb',
        status: JobStatus.assigned,
        notes: 'Pratnja do liječnika i natrag.',
      ),

      // Prekosutra — 1 posao
      Job(
        id: '4',
        date: today.add(const Duration(days: 2)),
        from: const TimeOfDay(hour: 8, minute: 0),
        to: const TimeOfDay(hour: 10, minute: 0),
        serviceTypes: [ServiceType.houseHelp],
        seniorName: 'Josip Matić',
        address: 'Savska 101, Zagreb',
        status: JobStatus.assigned,
      ),

      // Za 4 dana — 1 posao
      Job(
        id: '5',
        date: today.add(const Duration(days: 4)),
        from: const TimeOfDay(hour: 15, minute: 0),
        to: const TimeOfDay(hour: 17, minute: 0),
        serviceTypes: [ServiceType.walking],
        seniorName: 'Kata Jurić',
        address: 'Maksimirska 33, Zagreb',
        status: JobStatus.assigned,
        notes: 'Šetnja do parka i natrag, polako.',
      ),

      // Za 5 dana — 1 posao
      Job(
        id: '6',
        date: today.add(const Duration(days: 5)),
        from: const TimeOfDay(hour: 11, minute: 0),
        to: const TimeOfDay(hour: 13, minute: 0),
        serviceTypes: [ServiceType.other],
        seniorName: 'Mirko Tomić',
        address: 'Držićeva 12, Zagreb',
        status: JobStatus.assigned,
        notes: 'Pomoć s preslagivanjem stvari u ormaru.',
      ),

      // ── Prošli poslovi (završeni, za statistiku) ──
      Job(
        id: '7',
        date: today.subtract(const Duration(days: 2)),
        from: const TimeOfDay(hour: 9, minute: 0),
        to: const TimeOfDay(hour: 11, minute: 0),
        serviceTypes: [ServiceType.shopping],
        seniorName: 'Ivka Mandić',
        address: 'Savska 55, Zagreb',
        status: JobStatus.completed,
        review: ReviewModel(
          rating: 5,
          comment: 'Vrlo ljubazan i točan. Preporučujem!',
          date: '27.02.2026.',
        ),
      ),
      Job(
        id: '8',
        date: today.subtract(const Duration(days: 3)),
        from: const TimeOfDay(hour: 14, minute: 0),
        to: const TimeOfDay(hour: 16, minute: 30),
        serviceTypes: [ServiceType.walking, ServiceType.socializing],
        seniorName: 'Slavko Barić',
        address: 'Šubićeva 10, Zagreb',
        status: JobStatus.completed,
        review: ReviewModel(
          rating: 4,
          comment: 'Ugodna šetnja, mali je kasnio 5 minuta.',
          date: '26.02.2026.',
        ),
      ),
      Job(
        id: '9',
        date: today.subtract(const Duration(days: 5)),
        from: const TimeOfDay(hour: 10, minute: 0),
        to: const TimeOfDay(hour: 12, minute: 0),
        serviceTypes: [ServiceType.houseHelp],
        seniorName: 'Barica Špoljar',
        address: 'Klaićeva 3, Zagreb',
        status: JobStatus.completed,
        review: ReviewModel(
          rating: 5,
          comment: 'Odlično pospremljeno, sve čisto!',
          date: '24.02.2026.',
        ),
      ),
      Job(
        id: '10',
        date: today.subtract(const Duration(days: 7)),
        from: const TimeOfDay(hour: 8, minute: 0),
        to: const TimeOfDay(hour: 10, minute: 0),
        serviceTypes: [ServiceType.escort],
        seniorName: 'Marija Horvat',
        address: 'Ilica 42, Zagreb',
        status: JobStatus.completed,
        review: ReviewModel(
          rating: 5,
          comment: 'Strpljiv i pažljiv. Hvala!',
          date: '22.02.2026.',
        ),
      ),
      Job(
        id: '11',
        date: today.subtract(const Duration(days: 10)),
        from: const TimeOfDay(hour: 15, minute: 0),
        to: const TimeOfDay(hour: 17, minute: 0),
        serviceTypes: [ServiceType.socializing],
        seniorName: 'Anka Vuković',
        address: 'Palmotićeva 18, Zagreb',
        status: JobStatus.completed,
        review: ReviewModel(
          rating: 4,
          comment: 'Lijepo smo popričali, dolazi opet!',
          date: '19.02.2026.',
        ),
      ),
      Job(
        id: '12',
        date: today.subtract(const Duration(days: 14)),
        from: const TimeOfDay(hour: 9, minute: 0),
        to: const TimeOfDay(hour: 11, minute: 30),
        serviceTypes: [ServiceType.shopping, ServiceType.houseHelp],
        seniorName: 'Josip Matić',
        address: 'Savska 101, Zagreb',
        status: JobStatus.completed,
      ),

      // ── Prošli tjedan (prije 8-13 dana) — za tjedni chart ──
      Job(
        id: '13',
        date: today.subtract(const Duration(days: 8)),
        from: const TimeOfDay(hour: 10, minute: 0),
        to: const TimeOfDay(hour: 12, minute: 0),
        serviceTypes: [ServiceType.walking],
        seniorName: 'Kata Jurić',
        address: 'Maksimirska 33, Zagreb',
        status: JobStatus.completed,
      ),
      Job(
        id: '14',
        date: today.subtract(const Duration(days: 9)),
        from: const TimeOfDay(hour: 14, minute: 0),
        to: const TimeOfDay(hour: 16, minute: 0),
        serviceTypes: [ServiceType.socializing],
        seniorName: 'Anka Vuković',
        address: 'Palmotićeva 18, Zagreb',
        status: JobStatus.completed,
      ),
      Job(
        id: '15',
        date: today.subtract(const Duration(days: 11)),
        from: const TimeOfDay(hour: 8, minute: 0),
        to: const TimeOfDay(hour: 11, minute: 0),
        serviceTypes: [ServiceType.houseHelp],
        seniorName: 'Barica Špoljar',
        address: 'Klaićeva 3, Zagreb',
        status: JobStatus.completed,
      ),

      // ── Prije 3 tjedna ──
      Job(
        id: '16',
        date: today.subtract(const Duration(days: 17)),
        from: const TimeOfDay(hour: 9, minute: 0),
        to: const TimeOfDay(hour: 12, minute: 0),
        serviceTypes: [ServiceType.shopping],
        seniorName: 'Ivka Mandić',
        address: 'Savska 55, Zagreb',
        status: JobStatus.completed,
      ),
      Job(
        id: '17',
        date: today.subtract(const Duration(days: 19)),
        from: const TimeOfDay(hour: 13, minute: 0),
        to: const TimeOfDay(hour: 15, minute: 0),
        serviceTypes: [ServiceType.escort],
        seniorName: 'Ana Babić',
        address: 'Heinzelova 15, Zagreb',
        status: JobStatus.completed,
      ),

      // ── Prije 4 tjedna ──
      Job(
        id: '18',
        date: today.subtract(const Duration(days: 25)),
        from: const TimeOfDay(hour: 10, minute: 0),
        to: const TimeOfDay(hour: 13, minute: 0),
        serviceTypes: [ServiceType.houseHelp, ServiceType.shopping],
        seniorName: 'Marija Horvat',
        address: 'Ilica 42, Zagreb',
        status: JobStatus.completed,
      ),

      // ── Prošli mjesec ──
      Job(
        id: '19',
        date: today.subtract(const Duration(days: 35)),
        from: const TimeOfDay(hour: 9, minute: 0),
        to: const TimeOfDay(hour: 11, minute: 0),
        serviceTypes: [ServiceType.walking],
        seniorName: 'Dragica Perić',
        address: 'Trg bana Jelačića 5, Zagreb',
        status: JobStatus.completed,
      ),
      Job(
        id: '20',
        date: today.subtract(const Duration(days: 40)),
        from: const TimeOfDay(hour: 14, minute: 0),
        to: const TimeOfDay(hour: 17, minute: 0),
        serviceTypes: [ServiceType.socializing],
        seniorName: 'Slavko Barić',
        address: 'Šubićeva 10, Zagreb',
        status: JobStatus.completed,
      ),
      Job(
        id: '21',
        date: today.subtract(const Duration(days: 45)),
        from: const TimeOfDay(hour: 8, minute: 0),
        to: const TimeOfDay(hour: 10, minute: 30),
        serviceTypes: [ServiceType.escort],
        seniorName: 'Stjepan Novak',
        address: 'Vlaška 90, Zagreb',
        status: JobStatus.completed,
      ),
    ];
  }

  /// Vrati poslove za određeni datum.
  static List<Job> forDate(DateTime date) {
    return all
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

  /// Datumi koji imaju barem 1 posao (za tjedni strip marker).
  static Set<DateTime> get datesWithJobs {
    return all
        .map((j) => DateTime(j.date.year, j.date.month, j.date.day))
        .toSet();
  }
}
