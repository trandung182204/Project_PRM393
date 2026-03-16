import 'package:flutter/material.dart';
import 'package:bai1/widgets/custom_bottom_nav_bar.dart';
import 'package:bai1/models/schedule.dart';
import 'package:bai1/controllers/schedule_controller.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Ngày đang chọn (Mặc định là hôm nay)
  DateTime _selectedDate = DateTime.now();

  // Tuần hiện tại đang hiển thị
  late DateTime _weekStart; // Monday
  late List<DateTime> _weekDays;

  final ScheduleController _controller = ScheduleController();
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  int? _classId;
  int? _staffId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is int) {
      _classId = args;
    } else if (args != null) {
      try {
        _classId = (args as dynamic).classId;
        _staffId = (args as dynamic).staffId;
      } catch (e) {
        debugPrint("ScheduleScreen: Error parsing arguments: $e");
      }
    }

    _fetchSchedulesForWeek();
  }

  @override
  void initState() {
    super.initState();
    _setWeek(DateTime.now());
  }

  /// Tính Monday của tuần chứa [date]
  void _setWeek(DateTime date) {
    // weekday: Monday=1, Sunday=7
    _weekStart = date.subtract(Duration(days: date.weekday - 1));
    _weekDays = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
  }

  /// Chuyển sang tuần trước
  void _goToPreviousWeek() {
    setState(() {
      _setWeek(_weekStart.subtract(const Duration(days: 7)));
      _selectedDate = _weekDays[0];
    });
    _fetchSchedulesForWeek();
  }

  /// Chuyển sang tuần sau
  void _goToNextWeek() {
    setState(() {
      _setWeek(_weekStart.add(const Duration(days: 7)));
      _selectedDate = _weekDays[0];
    });
    _fetchSchedulesForWeek();
  }

  /// Về tuần hiện tại
  void _goToCurrentWeek() {
    setState(() {
      final now = DateTime.now();
      _setWeek(now);
      _selectedDate = now;
    });
    _fetchSchedulesForWeek();
  }

  /// Gọi API với fromDate/toDate của tuần đang hiển thị
  Future<void> _fetchSchedulesForWeek() async {
    setState(() => _isLoading = true);

    final fromDate = _weekDays.first;
    final toDate = _weekDays.last;

    final schedules = await _controller.fetchSchedulesByWeek(
      classId: _classId,
      staffId: _staffId,
      fromDate: fromDate,
      toDate: toDate,
    );

    setState(() {
      _schedules = schedules;
      _isLoading = false;
    });
  }

  // Filter schedules for selected day
  List<Schedule> _getClassesForDay(DateTime date) {
    return _schedules.where((schedule) {
      if (schedule.date.isEmpty) return false;
      try {
        DateTime parsedDate = DateTime.parse(schedule.date);
        return parsedDate.year == date.year &&
               parsedDate.month == date.month &&
               parsedDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Format header hiển thị tuần: "09 Mar - 15 Mar 2026"
  String _weekHeader() {
    final from = _weekDays.first;
    final to = _weekDays.last;
    final f = DateFormat('dd MMM');
    final fFull = DateFormat('dd MMM yyyy');

    if (from.year == to.year && from.month == to.month) {
      return '${from.day} - ${fFull.format(to)}';
    } else if (from.year == to.year) {
      return '${f.format(from)} - ${fFull.format(to)}';
    } else {
      return '${fFull.format(from)} - ${fFull.format(to)}';
    }
  }

  /// Kiểm tra xem tuần đang xem có phải tuần hiện tại
  bool _isCurrentWeek() {
    final now = DateTime.now();
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    return _weekStart.year == currentMonday.year &&
           _weekStart.month == currentMonday.month &&
           _weekStart.day == currentMonday.day;
  }

  @override
  Widget build(BuildContext context) {
    List<Schedule> classes = _getClassesForDay(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Timetable',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
          },
        ),
        actions: [
          if (!_isCurrentWeek())
            IconButton(
              icon: const Icon(Icons.today, color: Colors.white),
              tooltip: 'Go to this week',
              onPressed: _goToCurrentWeek,
            ),
        ],
      ),
      body: Column(
        children: [
          // ===== WEEK NAVIGATION HEADER =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.lightBlue, size: 30),
                  onPressed: _goToPreviousWeek,
                  tooltip: 'Previous week',
                ),
                Column(
                  children: [
                    Text(
                      _weekHeader(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (_isCurrentWeek())
                      const Text(
                        'This week',
                        style: TextStyle(fontSize: 12, color: Colors.lightBlue, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.lightBlue, size: 30),
                  onPressed: _goToNextWeek,
                  tooltip: 'Next week',
                ),
              ],
            ),
          ),

          // ===== WEEKLY CALENDAR STRIP =====
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _weekDays.length,
                itemBuilder: (context, index) {
                  DateTime date = _weekDays[index];
                  bool isSelected =
                      date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;
                  bool isToday =
                      date.day == DateTime.now().day &&
                      date.month == DateTime.now().month &&
                      date.year == DateTime.now().year;

                  List<String> days = [
                    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
                  ];

                  // Đếm số tiết trong ngày này
                  int classCount = _getClassesForDay(date).length;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.lightBlue : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? Colors.lightBlue
                              : isToday
                                  ? Colors.lightBlue.shade300
                                  : Colors.grey.shade200,
                          width: isToday && !isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.lightBlue.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            days[date.weekday - 1],
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white70 : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          // Dot indicator cho ngày có lịch
                          if (classCount > 0 && !isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.lightBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== CLASS LIST =====
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : classes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No classes on this day",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      return _buildClassCard(classes[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: -1,
        args: ModalRoute.of(context)?.settings.arguments,
      ),
    );
  }

  // Widget hiển thị từng tiết học
  Widget _buildClassCard(Schedule classInfo) {
    Color statusColor = Colors.grey;
    Color cardBg = Colors.white;

    if (classInfo.status == 'Happening') {
      statusColor = Colors.green;
    } else if (classInfo.status == 'Upcoming') {
      statusColor = Colors.lightBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột giờ bên trái
          Column(
            children: [
              Text(
                classInfo.time.split(' - ').first,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                classInfo.time.split(' - ').length > 1 ? classInfo.time.split(' - ')[1] : '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(width: 15),

          // Đường kẻ dọc (Timeline)
          Container(
            width: 2,
            height: 100,
            color: Colors.lightBlue.withOpacity(0.3),
            margin: const EdgeInsets.only(top: 5),
          ),

          const SizedBox(width: 15),

          // Thẻ thông tin bên phải
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: classInfo.status == 'Happening'
                    ? Border.all(color: Colors.green, width: 1.5)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          classInfo.subject,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          classInfo.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.room, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "Room: ${classInfo.room}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        classInfo.teacher,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
