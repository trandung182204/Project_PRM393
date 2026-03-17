import 'package:flutter/material.dart';
import 'package:bai1/controllers/absence_request_controller.dart';
import 'package:bai1/controllers/schedule_controller.dart';
import 'package:bai1/models/absence_request.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController _reasonController = TextEditingController();

  bool _isSelectAll = false;
  bool _isSubmitting = false;
  bool _isLoadingSlots = false;
  int? _accountId;
  int? _classId;
  AbsenceRequestModel? _editRequest;

  final AbsenceRequestController _controller = AbsenceRequestController();
  final ScheduleController _scheduleController = ScheduleController();
  
  List<Map<String, dynamic>> _slots = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      if (args is int) {
        _accountId = args;
      } else if (args is Map<String, dynamic>) {
        _accountId = args['accountId'];
        _classId = args['classId'];
        _editRequest = args['editRequest'];
      }

      if (_slots.isEmpty && !_isLoadingSlots) {
        _fetchScheduleSlots();
      }
    }
  }

  Future<void> _fetchScheduleSlots() async {
    setState(() => _isLoadingSlots = true);
    
    final now = DateTime.now();
    
    // Calculate current week range (Monday to Sunday)
    int daysUntilMonday = now.weekday - DateTime.monday;
    DateTime mondayOfThisWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysUntilMonday));
    DateTime sundayOfThisWeek = mondayOfThisWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // Determine fetch range
    DateTime fromDate = mondayOfThisWeek;
    DateTime toDate = sundayOfThisWeek;

    // "ít nhất phải đến chủ nhật của tuần này thì mới hiển thị cho tuần sau để xin absent"
    if (now.weekday == DateTime.sunday) {
      toDate = sundayOfThisWeek.add(const Duration(days: 7));
    }

    // Fetch schedules
    final schedules = await _scheduleController.fetchSchedulesByWeek(
      classId: _classId,
      fromDate: fromDate,
      toDate: toDate,
    );
    
    final List<Map<String, dynamic>> dynamicSlots = [];
    
    for (var s in schedules) {
      try {
        DateTime slotDate = DateTime.parse(s.date);
        
        // Split time "07:30 - 09:30"
        String startTimeStr = s.time.split(' - ').first;
        int hour = int.parse(startTimeStr.split(':').first);
        int minute = int.parse(startTimeStr.split(':').last);
        
        DateTime slotStartTime = DateTime(
          slotDate.year, 
          slotDate.month, 
          slotDate.day,
          hour,
          minute
        );

        // Conditions: 
        // 1. Not passed (start time is after now)
        bool isNotPassed = slotStartTime.isAfter(now);

        if (isNotPassed) {
          dynamicSlots.add({
            'id': s.slotId,
            'name': 'Slot: ${s.subject}',
            'time': s.time,
            'room': s.room,
            'className': s.className,
            'isSelected': false,
            'date': s.date,
            'subject': s.subject,
          });
        }
      } catch (e) {
        debugPrint("Error parsing slot: $e");
      }
    }

    // Sort by date and then by time
    dynamicSlots.sort((a, b) {
      int dateComp = a['date'].compareTo(b['date']);
      if (dateComp != 0) return dateComp;
      return a['time'].compareTo(b['time']);
    });

    if (mounted) {
      setState(() {
        _slots = dynamicSlots;
        _isLoadingSlots = false;
        
        if (_editRequest != null) {
          for (var slot in _slots) {
            slot['isSelected'] = _editRequest!.slots.any((s) => s.id == slot['id']);
          }
          _isSelectAll = _slots.isNotEmpty && _slots.every((slot) => slot['isSelected'] == true);
          _reasonController.text = _editRequest!.reason;
        }
      });
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _isSelectAll = value ?? false;
      for (var slot in _slots) {
        slot['isSelected'] = _isSelectAll;
      }
    });
  }

  void _toggleSlot(int index, bool? value) {
    setState(() {
      _slots[index]['isSelected'] = value ?? false;
      _isSelectAll = _slots.every((slot) => slot['isSelected'] == true);
    });
  }

  void _resetForm() {
    setState(() {
      _reasonController.clear();
      _isSelectAll = false;
      for (var slot in _slots) {
        slot['isSelected'] = false;
      }
    });
  }

  Future<void> _submitRequest() async {
    final selectedSlots = _slots.where((s) => s['isSelected'] == true).toList();

    if (selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one lesson')),
      );
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Group selected slots by date
    Map<String, List<int>> groupedByDate = {};
    for (var slot in selectedSlots) {
      String dateKey = slot['date'];
      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add(slot['id'] as int);
    }

    bool allSuccess = true;
    
    // Submit for each date
    for (var entry in groupedByDate.entries) {
      DateTime date = DateTime.parse(entry.key);
      List<int> slotIds = entry.value;

      bool success = false;
      if (_editRequest != null && groupedByDate.length == 1 && date.isAtSameMomentAs(DateTime.parse(_editRequest!.date))) {
         // Update existing if only one day selected and it's the same day
         success = await _controller.updateAbsenceRequest(
          id: _editRequest!.id,
          date: date,
          reason: _reasonController.text.trim(),
          slotIds: slotIds,
        );
      } else {
        if (_accountId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Account information not found. Please log in again.')),
          );
          return;
        }

        final result = await _controller.submitAbsenceRequest(
          date: date,
          reason: _reasonController.text.trim(),
          accountId: _accountId!,
          slotIds: slotIds,
        );
        success = result != null;
      }
      if (!success) allSuccess = false;
    }

    setState(() => _isSubmitting = false);

    if (allSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editRequest != null ? 'Update successful!' : 'Absence request submitted successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit some requests. Please check again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _editRequest != null ? 'Edit Report' : 'Create Report',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removed Long Absent button as requested
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Please select specific lessons to request absence.",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Future Lessons (Current Week)",
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (!_isLoadingSlots && _slots.isNotEmpty)
                  Row(
                    children: [
                      Checkbox(
                        value: _isSelectAll,
                        activeColor: Colors.lightBlue,
                        onChanged: _toggleSelectAll,
                      ),
                      const Text("Select All"),
                    ],
                  ),
              ],
            ),

            if (_isLoadingSlots)
              const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ))
            else if (_slots.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        "No available lessons found this week.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
            ..._slots.asMap().entries.map((entry) {
              int idx = entry.key;
              Map slot = entry.value;
              String displayDate = "";
              try {
                DateTime dt = DateTime.parse(slot['date']);
                displayDate = "${dt.day}/${dt.month}/${dt.year}";
              } catch (_) {
                displayDate = slot['date'];
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          slot['subject'],
                          style: const TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          displayDate,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        "Slot: ${idx + 1} (${slot['time']}) [${slot['className']}]",
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text("Room: ", style: TextStyle(fontSize: 13)),
                          Text(
                            slot['room'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.lightBlue),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: slot['isSelected'],
                    activeColor: Colors.lightBlue,
                    onChanged: (val) => _toggleSlot(idx, val),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            const Text(
              "Reason",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter reason for absence...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.lightBlue,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Submit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.lightBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Reset", style: TextStyle(fontSize: 16, color: Colors.lightBlue)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
