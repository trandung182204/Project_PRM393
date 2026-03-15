import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/event.dart';
import 'package:bai1/models/event_registration.dart';

class EventService {
  Future<List<EventModel>> getEvents() async {
    final response = await http.get(Uri.parse(ApiConfig.getEvents));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => EventModel.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    final response = await http.get(Uri.parse(ApiConfig.allEvents));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => EventModel.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load all events');
    }
  }

  Future<List<EventModel>> getPendingEvents() async {
    final response = await http.get(Uri.parse(ApiConfig.pendingEvents));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => EventModel.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load pending events');
    }
  }

  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    final response = await http.post(
      Uri.parse(ApiConfig.getEvents),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(eventData),
    );
    return response.statusCode == 200;
  }

  Future<bool> proposeEvent(Map<String, dynamic> eventData) async {
    final response = await http.post(
      Uri.parse(ApiConfig.proposeEvent),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(eventData),
    );
    return response.statusCode == 200;
  }

  Future<bool> approveEvent(int id) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getEvents}/$id/approve"),
    );
    return response.statusCode == 200;
  }

  Future<bool> publishEvent(int id) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getEvents}/$id/publish"),
    );
    return response.statusCode == 200;
  }

  Future<bool> registerForEvent(int eventId, int studentId) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.getEvents}/$eventId/register?studentId=$studentId"),
    );
    return response.statusCode == 200;
  }

  Future<bool> checkinStudent(int eventId, int studentId) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getEvents}/$eventId/checkin/$studentId"),
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> completeEvent(int id) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getEvents}/$id/complete"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to complete event');
    }
  }

  Future<bool> cancelEvent(int id) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getEvents}/$id/cancel"),
    );
    return response.statusCode == 200;
  }

  Future<List<EventRegistrationModel>> getRegistrations(int eventId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.getEvents}/$eventId/registrations"),
    );

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((m) => EventRegistrationModel.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load registrations');
    }
  }

  Future<Map<String, dynamic>> getMyEventStatus(int eventId, int studentId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.getEvents}/$eventId/my-status?studentId=$studentId"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get event status');
    }
  }

  Future<bool> updateEvent(int id, Map<String, dynamic> eventData) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.getEvents}/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(eventData),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteEvent(int id) async {
    final response = await http.delete(Uri.parse("${ApiConfig.getEvents}/$id"));
    return response.statusCode == 200;
  }
}
