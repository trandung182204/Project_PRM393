import 'package:bai1/screens/club_details.dart';
import 'package:bai1/screens/clubs.dart';
import 'package:bai1/screens/create_report.dart';
import 'package:bai1/screens/event_details.dart';
import 'package:bai1/screens/events.dart';
import 'package:bai1/screens/forgot_password.dart';
import 'package:bai1/screens/home.dart';
import 'package:bai1/screens/login.dart';
import 'package:bai1/screens/mark_report.dart';
import 'package:bai1/screens/report.dart';
import 'package:bai1/screens/schedule.dart';
import 'package:bai1/screens/settings.dart';
import 'package:bai1/screens/table_app.dart';
import 'package:bai1/screens/admin_account_screen.dart';
import 'package:bai1/screens/course_registration_screen.dart';
import 'package:bai1/screens/class_assignment_screen.dart';
import 'package:bai1/screens/manage_grades_screen.dart';
import 'package:bai1/screens/manage_events_screen.dart';
import 'package:bai1/screens/manage_absence_requests_screen.dart';
import 'package:bai1/screens/manage_clubs_screen.dart';
import 'package:bai1/screens/manage_schedule_screen.dart';
import 'package:bai1/screens/manage_subjects_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudentHub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          primary: Colors.lightBlue,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.lightBlue, width: 2),
          ),
        ),
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => LoginScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/home': (context) => Home(),
        "/mark_report": (context) => MarkReportScreen(),
        "/manage_grades": (context) => ManageGradesScreen(),
        "/schedule": (context) => ScheduleScreen(),
        "/report": (context) => ReportScreen(),
        "/create_report": (context) => CreateReportScreen(),
        "/events": (context) => EventsScreen(),
        "/event_details": (context) => EventDetailScreen(
          event: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {},
        ),
        "/clubs": (context) => ClubsScreen(),
        "/club_details": (context) => ClubDetailScreen(
          club: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {},
        ),
        "/schedule_table": (context) => TableApp(),
        "/settings": (context) => const SettingsScreen(),
        "/admin_account": (context) => const AdminAccountScreen(),
        "/course_registration": (context) => CourseRegistrationScreen(
          studentId: (ModalRoute.of(context)?.settings.arguments as int?) ?? 0,
        ),
        "/class_assignment": (context) => const ClassAssignmentScreen(),
        "/manage_events": (context) => const ManageEventsScreen(),
        "/manage_clubs": (context) => const ManageClubsScreen(),
        "/manage_absences": (context) => const ManageAbsenceRequestsScreen(),
        "/manage_schedule": (context) => const ManageScheduleScreen(),
        "/manage_subjects": (context) => const ManageSubjectsScreen(),
      },
    );
  }
}
