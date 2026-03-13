/// Centralna klasa sa svim backend URL-ovima za Student app.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base ──────────────────────────────────────
  static const String baseUrl = 'http://localhost:5142';

  // ── Auth ──────────────────────────────────────
  static const String login = '/api/auth/login';
  static const String registerStudent = '/api/auth/register/student';
  static const String changePassword = '/api/auth/change-password';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password-code';

  // ── Students ──────────────────────────────────
  static const String students = '/api/students';
  static String student(int id) => '/api/students/$id';

  // ── Job Instances (sessions) ──────────────────
  static const String jobInstances = '/api/jobinstances';
  static String jobInstance(int id) => '/api/jobinstances/$id';

  // ── Schedule Assignments ──────────────────────
  static const String scheduleAssignments = '/api/scheduleassignments';
  static String scheduleAssignment(int id) => '/api/scheduleassignments/$id';

  // ── Reviews ───────────────────────────────────
  static const String reviews = '/api/reviews';
  static String review(int id) => '/api/reviews/$id';

  // ── Notifications ─────────────────────────────
  static const String notifications = '/api/hnotifications';

  // ── Chat ──────────────────────────────────────
  static const String chat = '/api/chat';

  // ── Cities ────────────────────────────────────
  static const String cities = '/api/cities';

  // ── Services ──────────────────────────────────
  static const String serviceTypes = '/api/servicetypes';

  // ── Faculties ─────────────────────────────────
  static const String faculties = '/api/faculties';

  // ── Contracts ─────────────────────────────────
  static const String contracts = '/api/studentcontracts';
}
