import 'package:bai1/models/event.dart';
import 'package:bai1/models/event_registration.dart';
import 'package:bai1/services/event_service.dart';

class EventController {
  final EventService _eventService = EventService();

  Future<List<EventModel>> fetchEvents() async {
    try {
      return await _eventService.getEvents();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<List<EventModel>> fetchAllEvents() async {
    try {
      return await _eventService.getAllEvents();
    } catch (e) {
      print("Error fetching all events: $e");
      return [];
    }
  }

  Future<List<EventModel>> fetchPendingEvents() async {
    try {
      return await _eventService.getPendingEvents();
    } catch (e) {
      print("Error fetching pending events: $e");
      return [];
    }
  }

  Future<bool> proposeEvent(Map<String, dynamic> data) async {
    try {
      return await _eventService.proposeEvent(data);
    } catch (e) {
      print("Error proposing event: $e");
      return false;
    }
  }

  Future<bool> approveEvent(int id) async {
    try {
      return await _eventService.approveEvent(id);
    } catch (e) {
      print("Error approving event: $e");
      return false;
    }
  }

  Future<bool> publishEvent(int id) async {
    try {
      return await _eventService.publishEvent(id);
    } catch (e) {
      print("Error publishing event: $e");
      return false;
    }
  }

  Future<bool> registerForEvent(int eventId, int studentId) async {
    try {
      return await _eventService.registerForEvent(eventId, studentId);
    } catch (e) {
      print("Error registering for event: $e");
      return false;
    }
  }

  Future<bool> checkinStudent(int eventId, int studentId) async {
    try {
      return await _eventService.checkinStudent(eventId, studentId);
    } catch (e) {
      print("Error checking in student: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> completeEvent(int id) async {
    try {
      return await _eventService.completeEvent(id);
    } catch (e) {
      print("Error completing event: $e");
      return {};
    }
  }

  Future<bool> cancelEvent(int id) async {
    try {
      return await _eventService.cancelEvent(id);
    } catch (e) {
      print("Error cancelling event: $e");
      return false;
    }
  }

  Future<List<EventRegistrationModel>> fetchRegistrations(int eventId) async {
    try {
      return await _eventService.getRegistrations(eventId);
    } catch (e) {
      print("Error fetching registrations: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getMyEventStatus(int eventId, int studentId) async {
    try {
      return await _eventService.getMyEventStatus(eventId, studentId);
    } catch (e) {
      print("Error getting event status: $e");
      return {"isRegistered": false, "attendanceStatus": "None"};
    }
  }
}
