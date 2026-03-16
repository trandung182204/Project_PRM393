import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/absence_request.dart';

class AbsenceRequestService {
  Future<List<AbsenceRequestModel>> getAbsenceRequests({int? accountId, int? classId, int? staffId}) async {
    String url = ApiConfig.absenceRequests;
    List<String> params = [];
    if (accountId != null) params.add('accountId=$accountId');
    if (classId != null) params.add('classId=$classId');
    if (staffId != null) params.add('staffId=$staffId');

    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => AbsenceRequestModel.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load absence requests');
    }
  }

  Future<AbsenceRequestModel> createAbsenceRequest({
    required DateTime date,
    required String reason,
    required int accountId,
    required List<int> slotIds,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.absenceRequests),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'date': date.toIso8601String(),
        'reason': reason,
        'accountId': accountId,
        'slotIds': slotIds,
      }),
    );

    if (response.statusCode == 201) {
      return AbsenceRequestModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create absence request');
    }
  }

  Future<void> updateAbsenceRequest({
    required int id,
    required DateTime date,
    required String reason,
    required List<int> slotIds,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.absenceRequests}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'date': date.toIso8601String(),
        'reason': reason,
        'slotIds': slotIds,
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update absence request');
    }
  }

  Future<void> deleteAbsenceRequest(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.absenceRequests}/$id'),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to delete absence request');
    }
  }

  Future<void> updateStatus(int id, String status) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.absenceRequests}/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update status');
    }
  }
}
