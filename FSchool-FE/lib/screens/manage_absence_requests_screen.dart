import 'package:flutter/material.dart';
import 'package:bai1/models/absence_request.dart';
import 'package:bai1/controllers/absence_request_controller.dart';
import 'package:intl/intl.dart';

class ManageAbsenceRequestsScreen extends StatefulWidget {
  const ManageAbsenceRequestsScreen({super.key});

  @override
  State<ManageAbsenceRequestsScreen> createState() => _ManageAbsenceRequestsScreenState();
}

class _ManageAbsenceRequestsScreenState extends State<ManageAbsenceRequestsScreen> {
  final AbsenceRequestController _controller = AbsenceRequestController();
  List<AbsenceRequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    final requests = await _controller.fetchAbsenceRequests();
    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    setState(() => _isLoading = true);
    final success = await _controller.updateStatus(id, status);
    if (success) {
      _fetchRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $status successfully")),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Action failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Manage Absences", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _fetchRequests, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text("No absence requests found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return _buildRequestCard(request);
                  },
                ),
    );
  }

  Widget _buildRequestCard(AbsenceRequestModel request) {
    Color statusColor = Colors.orange;
    if (request.status == 'Approved') statusColor = Colors.green;
    if (request.status == 'Rejected') statusColor = Colors.red;

    String displayDate = "";
    try {
      DateTime dt = DateTime.parse(request.date);
      displayDate = DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      displayDate = request.date;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Date: $displayDate", style: TextStyle(color: Colors.grey[700])),
            Text("Slots: ${request.slots.map((s) => s.slotName).join(', ')}", style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text("Reason: ${request.reason}", style: const TextStyle(fontStyle: FontStyle.italic)),
            if (request.status == 'Pending') ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _updateStatus(request.id, 'Rejected'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Reject"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _updateStatus(request.id, 'Approved'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Approve", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
