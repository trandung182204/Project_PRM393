import 'package:flutter/material.dart';
import 'package:bai1/services/event_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  bool _isRegistered = false;
  String _attendanceStatus = 'None';

  Future<void> _registerForEvent() async {
    final eventId = int.tryParse(widget.event['id']?.toString() ?? '0') ?? 0;
    // Sử dụng studentId = 1 mặc định (trong thực tế lấy từ auth)
    final success = await _eventService.registerForEvent(eventId, 1);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Registration successful!'
                : 'Registration failed. You might already be registered or the event is full.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        setState(() {
          _isRegistered = true;
          _attendanceStatus = 'Registered';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = widget.event['status']?.toString() ?? '';
    final int registrationCount = (widget.event['registrationCount'] as num?)?.toInt() ?? 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.lightBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.event['title'],
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                  fontSize: 16,
                ),
              ),
              background: Image.network(
                widget.event['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.lightBlue.shade200),
              ),
            ),
          ),

          // Nội dung chi tiết
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  if (status.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$registrationCount registered',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Ngày và Địa điểm
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.lightBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.event['date'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.lightBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.event['location'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // Budget info
                  if (widget.event['budget'] != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 16, color: Colors.lightBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Budget: ${widget.event['budget']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],

                  // Max Participants info
                  if (widget.event['maxParticipants'] != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.group, size: 16, color: Colors.lightBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Max: ${widget.event['maxParticipants']} participants',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.event['description'],
                    style: const TextStyle(height: 1.5, color: Colors.black87),
                  ),

                  const SizedBox(height: 30),

                  // Nút đăng ký tham gia
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRegistered ? Colors.green : Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isRegistered ? null : _registerForEvent,
                      child: Text(
                        _isRegistered
                            ? (_attendanceStatus == 'Attended' ? "✓ Attended" : "✓ Registered")
                            : "Register Now",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
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
}
