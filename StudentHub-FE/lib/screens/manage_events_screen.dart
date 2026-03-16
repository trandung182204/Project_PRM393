import 'package:flutter/material.dart';
import 'package:bai1/models/event.dart';
import 'package:bai1/models/event_registration.dart';
import 'package:bai1/services/event_service.dart';
import 'package:intl/intl.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> with SingleTickerProviderStateMixin {
  final EventService _eventService = EventService();
  List<EventModel> _allEvents = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _eventService.getAllEvents();
      setState(() => _allEvents = events);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<EventModel> _getByStatus(List<String> statuses) {
    return _allEvents.where((e) => statuses.contains(e.status)).toList();
  }

  void _showEventDialog([EventModel? event]) {
    final titleController = TextEditingController(text: event?.title);
    final locationController = TextEditingController(text: event?.location);
    final descController = TextEditingController(text: event?.description);
    final budgetController = TextEditingController(text: event?.budget?.toString() ?? '');
    final maxPartController = TextEditingController(text: event?.maxParticipants?.toString() ?? '');
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(event == null ? "Create Event" : "Edit Event"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
                TextField(controller: budgetController, decoration: const InputDecoration(labelText: "Budget"), keyboardType: TextInputType.number),
                TextField(controller: maxPartController, decoration: const InputDecoration(labelText: "Max Participants"), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text("Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}"),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() => selectedDate = date);
                        }
                      },
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  "title": titleController.text,
                  "location": locationController.text,
                  "description": descController.text,
                  "eventDate": selectedDate.toIso8601String(),
                  "isNews": false,
                  "budget": double.tryParse(budgetController.text),
                  "maxParticipants": int.tryParse(maxPartController.text),
                };

                bool success;
                if (event == null) {
                  success = await _eventService.createEvent(data);
                } else {
                  success = await _eventService.updateEvent(int.parse(event.id), data);
                }

                if (success) {
                  Navigator.pop(context);
                  _fetchEvents();
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveEvent(EventModel event) async {
    final success = await _eventService.approveEvent(int.parse(event.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '${event.title} has been approved!' : 'Error!'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
    _fetchEvents();
  }

  Future<void> _publishEvent(EventModel event) async {
    final success = await _eventService.publishEvent(int.parse(event.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '${event.title} has been published!' : 'Error!'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
    _fetchEvents();
  }

  Future<void> _completeEvent(EventModel event) async {
    try {
      final result = await _eventService.completeEvent(int.parse(event.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Completed! Attended: ${result['totalAttended']}, Absent: ${result['totalAbsent']}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
    _fetchEvents();
  }

  void _showRegistrationsDialog(EventModel event) async {
    final eventId = int.parse(event.id);
    List<EventRegistrationModel> registrations = [];

    try {
      registrations = await _eventService.getRegistrations(eventId);
    } catch (e) {
      // ignore
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${event.title} - Registrations'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: registrations.isEmpty
                ? const Center(child: Text("No registrations yet."))
                : ListView.builder(
                    itemCount: registrations.length,
                    itemBuilder: (context, index) {
                      final reg = registrations[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: reg.attendanceStatus == 'Attended'
                              ? Colors.green.shade100
                              : reg.attendanceStatus == 'Absent'
                                  ? Colors.red.shade100
                                  : Colors.lightBlue.shade100,
                          child: Icon(
                            reg.attendanceStatus == 'Attended'
                                ? Icons.check
                                : reg.attendanceStatus == 'Absent'
                                    ? Icons.close
                                    : Icons.person,
                            color: reg.attendanceStatus == 'Attended'
                                ? Colors.green
                                : reg.attendanceStatus == 'Absent'
                                    ? Colors.red
                                    : Colors.lightBlue,
                          ),
                        ),
                        title: Text(reg.fullName),
                        subtitle: Text('${reg.rollNumber} - ${reg.attendanceStatus}'),
                        trailing: reg.attendanceStatus == 'Registered'
                            ? IconButton(
                                icon: const Icon(Icons.qr_code_scanner, color: Colors.green),
                                tooltip: "Check-in",
                                onPressed: () async {
                                  final success = await _eventService.checkinStudent(eventId, reg.studentId);
                                  if (success) {
                                    registrations = await _eventService.getRegistrations(eventId);
                                    setDialogState(() {});
                                  }
                                },
                              )
                            : null,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
      return const Center(child: Text("No events", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${event.date} - ${event.location}"),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(event.status ?? ''),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.status ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${event.registrationCount} registered', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'approve':
                    _approveEvent(event);
                    break;
                  case 'publish':
                    _publishEvent(event);
                    break;
                  case 'registrations':
                    _showRegistrationsDialog(event);
                    break;
                  case 'complete':
                    _completeEvent(event);
                    break;
                  case 'edit':
                    _showEventDialog(event);
                    break;
                  case 'delete':
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Event"),
                        content: const Text("Are you sure?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _eventService.deleteEvent(int.parse(event.id));
                      _fetchEvents();
                    }
                    break;
                  case 'cancel':
                    await _eventService.cancelEvent(int.parse(event.id));
                    _fetchEvents();
                    break;
                }
              },
              itemBuilder: (context) {
                final items = <PopupMenuItem<String>>[];
                if (event.status == 'Pending') {
                  items.add(const PopupMenuItem(value: 'approve', child: Text('✅ Approve')));
                }
                if (event.status == 'Approved') {
                  items.add(const PopupMenuItem(value: 'publish', child: Text('📢 Publish')));
                }
                if (event.status == 'Published' || event.status == 'Ongoing') {
                  items.add(const PopupMenuItem(value: 'registrations', child: Text('👥 Registrations & Check-in')));
                  items.add(const PopupMenuItem(value: 'complete', child: Text('✓ Complete')));
                }
                items.add(const PopupMenuItem(value: 'edit', child: Text('✏️ Edit')));
                if (event.status != 'Completed') {
                  items.add(const PopupMenuItem(value: 'cancel', child: Text('❌ Cancel')));
                }
                items.add(const PopupMenuItem(value: 'delete', child: Text('🗑️ Delete')));
                return items;
              },
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Published':
        return Colors.green;
      case 'Approved':
        return Colors.blue;
      case 'Pending':
        return Colors.lightBlue;
      case 'Ongoing':
        return Colors.teal;
      case 'Completed':
        return Colors.grey;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Events", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _fetchEvents, icon: const Icon(Icons.refresh)),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            Tab(text: "Pending (${_getByStatus(['Pending']).length})"),
            Tab(text: "Approved (${_getByStatus(['Approved']).length})"),
            Tab(text: "Published (${_getByStatus(['Published', 'Ongoing']).length})"),
            Tab(text: "Completed (${_getByStatus(['Completed', 'Cancelled']).length})"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEventList(_getByStatus(['Pending'])),
                _buildEventList(_getByStatus(['Approved'])),
                _buildEventList(_getByStatus(['Published', 'Ongoing'])),
                _buildEventList(_getByStatus(['Completed', 'Cancelled'])),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
