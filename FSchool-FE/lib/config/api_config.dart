class ApiConfig {
  static const String baseUrl = "http://localhost:5047/api";

  // Auth endpoints
  static const String login = "$baseUrl/Auth/login";

  // User endpoints
  static const String getProfile = "$baseUrl/users/profile";

  // App endpoints
  static const String getClubs = "$baseUrl/clubs";
  static const String getEvents = "$baseUrl/events";
  static const String getNews = "$baseUrl/news";
  static const String getSubjects = "$baseUrl/Subjects";
  static const String getSchedules = "$baseUrl/schedules";
  static const String absenceRequests = "$baseUrl/absencerequests";
  static const String getGrades = "$baseUrl/Grades/student";
  static const String updateGrade = "$baseUrl/Grades";
  static const String getClassesByStaff = "$baseUrl/Grades/staff";
  static const String getSubjectsByStaff = "$baseUrl/Grades/staff";
  static const String getSemesterFilters = "$baseUrl/Semesters/filters";
  static const String getSemesters = "$baseUrl/Semesters";
  static const String getClasses = "$baseUrl/Classes";
  static const String logout = "$baseUrl/Auth/logout";

  // Club Lifecycle endpoints
  static const String proposeClub = "$baseUrl/clubs/propose";
  static const String pendingClubs = "$baseUrl/clubs/pending";
  static const String allClubs = "$baseUrl/clubs/all";
  // Usage: "$getClubs/$id/approve", "$getClubs/$id/join?studentId=$sid"
  // "$getClubs/$id/members", "$getClubs/$id/members/$sid/approve"
  // "$getClubs/$id/members/$sid/role", "$getClubs/$id/members/$sid/leave"
  // "$getClubs/$id/my-status?studentId=$sid"

  // Event Lifecycle endpoints
  static const String proposeEvent = "$baseUrl/events/propose";
  static const String pendingEvents = "$baseUrl/events/pending";
  static const String allEvents = "$baseUrl/events/all";
  // Usage: "$getEvents/$id/approve", "$getEvents/$id/publish"
  // "$getEvents/$id/register?studentId=$sid", "$getEvents/$id/checkin/$sid"
  // "$getEvents/$id/complete", "$getEvents/$id/registrations"
  // "$getEvents/$id/my-status?studentId=$sid", "$getEvents/$id/cancel"
}
