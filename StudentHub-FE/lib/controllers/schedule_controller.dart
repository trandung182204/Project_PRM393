import 'package:bai1/models/schedule.dart';
import 'package:bai1/services/schedule_service.dart';

class ScheduleController {
  final ScheduleService _scheduleService = ScheduleService();

  Future<List<Schedule>> fetchSchedules({int? classId, int? staffId}) async {
    try {
      return await _scheduleService.getSchedules(classId: classId, staffId: staffId);
    } catch (e) {
      print("Error fetching schedules: $e");
      return [];
    }
  }

  /// Fetch schedule for a specific week (fromDate -> toDate)
  Future<List<Schedule>> fetchSchedulesByWeek({
    int? classId,
    int? staffId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final result = await _scheduleService.getSchedulesByDateRange(
        classId: classId,
        staffId: staffId,
        fromDate: fromDate,
        toDate: toDate,
      );
      return result['schedules'] as List<Schedule>;
    } catch (e) {
      print("Error fetching schedules by week: $e");
      return [];
    }
  }
}
