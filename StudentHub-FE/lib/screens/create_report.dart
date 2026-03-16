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
  int _selectedRequestType = 0;

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
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
    
    // Fetch schedules for the student's class
    final schedules = await _scheduleController.fetchSchedules(classId: _classId);
    
    final now = DateTime.now();
    
    // Filter: Slots in the next 7 days (including today) AND not passed yet
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
        // 1. Within 1 week from now
        // 2. Not passed (start time is after now)
        bool isWithinAWeek = slotDate.isAfter(now.subtract(const Duration(days: 1))) && 
                             slotDate.isBefore(now.add(const Duration(days: 7)));
        bool isNotPassed = slotStartTime.isAfter(now);

        if (isWithinAWeek && isNotPassed) {
          dynamicSlots.add({
            'id': s.slotId, // This is Slot.Id from backend
            'name': 'Slot: ${s.subject}',
            'time': s.time,
            'room': s.room,
            'isSelected': false,
            'date': s.date,
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

    setState(() {
      _slots = dynamicSlots;
      _isLoadingSlots = false;
      
      // If editing, re-apply selection
      if (_editRequest != null) {
        for (var slot in _slots) {
          slot['isSelected'] = _editRequest!.slots.any((s) => s.id == slot['id']);
        }
        _isSelectAll = _slots.isNotEmpty && _slots.every((slot) => slot['isSelected'] == true);
        
        // Also update date if editing
        _fromDate = DateTime.parse(_editRequest!.date);
        _reasonController.text = _editRequest!.reason;
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.lightBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
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
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
      _selectedRequestType = 0;
    });
  }

  Future<void> _submitRequest() async {
    // Validate
    final selectedSlotIds = _slots
        .where((s) => s['isSelected'] == true)
        .map<int>((s) => s['id'] as int)
        .toList();

    if (selectedSlotIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one slot')),
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

    bool success = false;
    if (_editRequest != null) {
       success = await _controller.updateAbsenceRequest(
        id: _editRequest!.id,
        date: _fromDate,
        reason: _reasonController.text.trim(),
        slotIds: selectedSlotIds,
      );
    } else {
      final result = await _controller.submitAbsenceRequest(
        date: _fromDate,
        reason: _reasonController.text.trim(),
        accountId: _accountId ?? 1,
        slotIds: selectedSlotIds,
      );
      success = result != null;
    }

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editRequest != null ? 'Cập nhật thành công!' : 'Đã gửi đơn nghỉ!')),
      );
      Navigator.pop(context, true); // return true to refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editRequest != null ? 'Cập nhật thất bại. Vui lòng thử lại.' : 'Gửi thất bại. Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedFrom =
        "${_fromDate.day}/${_fromDate.month}/${_fromDate.year}";
    String formattedTo = "${_toDate.day}/${_toDate.month}/${_toDate.year}";

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
            // 1. REQUEST TYPE SELECTION
            Row(
              children: [
                Expanded(
                  child: _buildTypeCard(
                    index: 0,
                    icon: Icons.edit_document,
                    label: "Request for Absent",
                    isSelected: _selectedRequestType == 0,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTypeCard(
                    index: 1,
                    icon: Icons.plagiarism_outlined,
                    label: "Request for Long Absent",
                    isSelected: _selectedRequestType == 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 2. DATE PICKERS
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "From",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formattedFrom),
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "To",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formattedTo),
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. LESSON OF THE DAY & SELECT ALL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Future Lessons (1 Week)",
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
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            else if (_slots.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No future lessons found in this week."),
              ))
            else
            // 4. LIST OF SLOTS
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
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                            children: [
                              TextSpan(
                                text: slot['name'].split(':').first + " : ",
                                style: const TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: slot['name'].split(':').last,
                                style: const TextStyle(
                                  color: Colors.lightBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          displayDate,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        slot['time'],
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Row(
                        children: [
                          const Text(
                            "Room : ",
                            style: TextStyle(color: Colors.black87),
                          ),
                          Text(
                            slot['room'],
                            style: const TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
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

            const SizedBox(height: 10),

            // 5. REASON INPUT
            const Text(
              "Reason",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type here",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 6. BUTTONS (SEND & RESET)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _editRequest != null ? "Update" : "Send",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRequestType = index;
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.lightBlue : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: Colors.black87),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.lightBlue : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.lightBlue)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
