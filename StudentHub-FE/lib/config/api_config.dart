import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _scheme = String.fromEnvironment('API_SCHEME', defaultValue: 'http');
  static const String _host = String.fromEnvironment(
    'API_HOST', 
    defaultValue: kIsWeb ? 'localhost' : '10.0.2.2'
  );
  static const String _port = String.fromEnvironment(
    'API_PORT', 
    defaultValue: _scheme == 'https' ? '7221' : '5047'
  );

  static const String baseUrl = "$_scheme://$_host:$_port/api";

  // Auth endpoints
  static const String login = "$baseUrl/Auth/login";
  // Thử lại với chữ 'Auth' viết hoa cho đồng bộ với login/logout
  static const String changePassword = "$baseUrl/Auth/change-password";

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

  // Event Lifecycle endpoints
  static const String proposeEvent = "$baseUrl/events/propose";
  static const String pendingEvents = "$baseUrl/events/pending";
  static const String allEvents = "$baseUrl/events/all";
}
