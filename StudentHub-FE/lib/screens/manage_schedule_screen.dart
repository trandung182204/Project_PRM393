import 'package:flutter/material.dart';
import '../services/schedule_service.dart';
import '../services/class_service.dart';
import '../services/subject_service.dart';
import '../services/room_service.dart';
import '../services/staff_service.dart';
import '../services/slot_service.dart';
import '../models/schedule.dart' as model;
import 'package:intl/intl.dart';

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({super.key});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final ClassService _classService = ClassService();
  final SubjectService _subjectService = SubjectService();
  final RoomService _roomService = RoomService();
  final StaffService _staffService = StaffService();
  final SlotService _slotService = SlotService();

  List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic>? _selectedClass;
  List<model.Schedule> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final classes = await _classService.getClasses();
      setState(() {
        _classes = List<Map<String, dynamic>>.from(classes);
        _isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSchedules() async {
    if (_selectedClass == null) return;
    setState(() => _isLoading = true);
    try {
      final schedules = await _scheduleService.getSchedules(classId: _selectedClass!['id']);
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildClassSelector(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedClass == null
                    ? const Center(child: Text("Please select a class to view schedule"))
                    : _buildScheduleList(),
          ),
        ],
      ),
      floatingActionButton: _selectedClass != null
          ? FloatingActionButton.extended(
              onPressed: _showBatchScheduleDialog,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Batch Schedule"),
              backgroundColor: Colors.lightBlue,
            )
          : null,
    );
  }

  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedClass,
        decoration: InputDecoration(
          labelText: "Select class",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.class_outlined),
        ),
        items: _classes.map((c) {
          return DropdownMenuItem(
            value: c,
            child: Text(c['className']),
          );
        }).toList(),
        onChanged: (val) {
          setState(() => _selectedClass = val);
          _loadSchedules();
        },
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_schedules.isEmpty) {
      return const Center(child: Text("No schedules found for this class."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final s = _schedules[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd/MM').format(DateTime.parse(s.date)),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  DateFormat('EEE').format(DateTime.parse(s.date)),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            title: Text(s.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(s.time),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.room_outlined, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(s.room),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.lightBlue),
                    const SizedBox(width: 4),
                    Text(s.teacher),
                  ],
                ),
              ],
            ),
    trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDeleteSchedule(s),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteSchedule(model.Schedule s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Delete lesson for subject ${s.subject} on ${DateFormat('dd/MM').format(DateTime.parse(s.date))}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && s.id != null) {
      setState(() => _isLoading = true);
      try {
        await _scheduleService.deleteSchedule(s.id!);
        _loadSchedules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lesson deleted")));
        }
      } catch (e) {
        _showError(e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  void _showBatchScheduleDialog() async {
    final subjects = await _subjectService.getSubjects();
    final rooms = await _roomService.getRooms();
    final staffs = await _staffService.getStaffs();
    final slots = await _slotService.getSlots();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BatchScheduleWizard(
        subjects: subjects,
        rooms: rooms,
        staffs: staffs,
        slots: slots,
        classId: _selectedClass!['id'],
        existingSchedules: _schedules,
        onSuccess: () {
          Navigator.pop(context);
          _loadSchedules();
        },
      ),
    );
  }
}

class _BatchScheduleWizard extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> rooms;
  final List<Map<String, dynamic>> staffs;
  final List<Map<String, dynamic>> slots;
  final int classId;
  final List<model.Schedule> existingSchedules;
  final VoidCallback onSuccess;

  const _BatchScheduleWizard({
    required this.subjects,
    required this.rooms,
    required this.staffs,
    required this.slots,
    required this.classId,
    required this.existingSchedules,
    required this.onSuccess,
  });

  @override
  State<_BatchScheduleWizard> createState() => _BatchScheduleWizardState();
}

class _BatchScheduleWizardState extends State<_BatchScheduleWizard> {
  int? _selectedSubject;
  int? _selectedRoom;
  int? _selectedStaff;
  List<int> _selectedSlots = [];
  List<int> _selectedDays = [1, 3, 5]; // Mon, Wed, Fri by default
  DateTime _startDate = DateTime.now();
  final _sessionsController = TextEditingController(text: "30");
  bool _isLoading = false;

  final Map<int, String> _dayNames = {
    1: "Mon",
    2: "Tue",
    3: "Wed",
    4: "Thu",
    5: "Fri",
    6: "Sat",
    0: "Sun",
  };

  // Map<DayOfWeek, Set<SlotId>>
  final Map<int, Set<int>> _occupiedMap = {};

  @override
  void initState() {
    super.initState();
    _processExistingSchedules();
  }

  void _processExistingSchedules() {
    for (var s in widget.existingSchedules) {
      if (s.slotId == null) continue;
      final date = DateTime.parse(s.date);
      final day = date.weekday % 7; // Map 7 (Sunday) to 0
      _occupiedMap.putIfAbsent(day, () => {}).add(s.slotId!);
    }
  }

  bool _isSlotOccupied(int slotId) {
    // A slot is considered occupied if it's already scheduled in ANY of the selected days
    for (var day in _selectedDays) {
      if (_occupiedMap[day]?.contains(slotId) ?? false) return true;
    }
    return false;
  }

  bool _isDayOccupied(int day) {
    // A day is considered occupied if it already has ANY of the selected slots scheduled
    for (var slotId in _selectedSlots) {
      if (_occupiedMap[day]?.contains(slotId) ?? false) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Batch Schedule", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown("Subject", widget.subjects, "id", "subjectName", (val) => _selectedSubject = val),
                  const SizedBox(height: 12),
                  _buildDropdown("Room", widget.rooms, "id", "roomName", (val) => _selectedRoom = val),
                  const SizedBox(height: 12),
                  _buildDropdown("Teacher", widget.staffs, "id", "fullName", (val) => _selectedStaff = val),
                  const SizedBox(height: 20),
                  const Text("Select days of week", style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: _dayNames.entries.map((e) {
                        final isSelected = _selectedDays.contains(e.key);
                        final isOccupied = _isDayOccupied(e.key);
                        return FilterChip(
                          label: Text(e.value),
                          selected: isSelected,
                          onSelected: isOccupied
                              ? null
                              : (val) {
                                  setState(() {
                                    if (val)
                                      _selectedDays.add(e.key);
                                    else
                                      _selectedDays.remove(e.key);
                                  });
                                },
                          backgroundColor: isOccupied ? Colors.grey[200] : null,
                          disabledColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text("Select Slots", style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: widget.slots.map((s) {
                        final isSelected = _selectedSlots.contains(s['id']);
                        final isOccupied = _isSlotOccupied(s['id']);
                        return FilterChip(
                          label: Text(s['slotName']),
                          selected: isSelected,
                          onSelected: isOccupied
                              ? null
                              : (val) {
                                  setState(() {
                                    if (val)
                                      _selectedSlots.add(s['id']);
                                    else
                                      _selectedSlots.remove(s['id']);
                                  });
                                },
                          backgroundColor: isOccupied ? Colors.grey[200] : null,
                          disabledColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Start Date", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: () async {
                                final res = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (res != null) setState(() => _startDate = res);
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _sessionsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Total Sessions",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleBatchSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Create Schedule", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<Map<String, dynamic>> items, String valueKey, String textKey, Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((i) => DropdownMenuItem(value: i[valueKey] as int, child: Text(i[textKey]))).toList(),
      onChanged: (val) => setState(() => onChanged(val)),
    );
  }

  Future<void> _handleBatchSchedule() async {
    if (_selectedSubject == null || _selectedRoom == null || _selectedStaff == null || _selectedSlots.isEmpty || _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter all information")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ScheduleService().batchSchedule({
        "classId": widget.classId,
        "subjectId": _selectedSubject,
        "roomId": _selectedRoom,
        "staffId": _selectedStaff,
        "slotIds": _selectedSlots,
        "daysOfWeek": _selectedDays,
        "startDate": _startDate.toIso8601String(),
        "totalSessions": int.parse(_sessionsController.text),
        "skipHolidays": true,
        "skipSundays": !_selectedDays.contains(0),
      });
      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
