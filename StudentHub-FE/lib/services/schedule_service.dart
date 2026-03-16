import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/schedule.dart';

class ScheduleService {
  /// Lấy lịch theo khoảng ngày [fromDate, toDate]
  /// API trả về { fromDate, toDate, schedules: [...] }
  Future<Map<String, dynamic>> getSchedulesByDateRange({
    int? classId,
    int? staffId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    String url = ApiConfig.getSchedules;
    List<String> params = [];

    params.add('fromDate=${_formatDate(fromDate)}');
    params.add('toDate=${_formatDate(toDate)}');
    if (classId != null) params.add('classId=$classId');
    if (staffId != null) params.add('staffId=$staffId');

    url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> schedulesJson = body['schedules'] ?? [];
      final schedules = schedulesJson.map((m) => Schedule.fromJson(m)).toList();

      return {
        'fromDate': body['fromDate'],
        'toDate': body['toDate'],
        'schedules': schedules,
      };
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  /// Lấy lịch (backward-compatible, dùng cho các chỗ cũ nếu cần)
  Future<List<Schedule>> getSchedules({int? classId, int? staffId}) async {
    // Mặc định lấy tuần hiện tại
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final result = await getSchedulesByDateRange(
      classId: classId,
      staffId: staffId,
      fromDate: monday,
      toDate: sunday,
    );
    return result['schedules'] as List<Schedule>;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> batchSchedule(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Schedules/batch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to batch schedule');
    }
  }

  Future<void> createSchedule(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Schedules'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create schedule');
    }
  }

  Future<void> updateSchedule(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/Schedules/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update schedule');
    }
  }

  Future<void> deleteSchedule(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/Schedules/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete schedule');
    }
  }
}
