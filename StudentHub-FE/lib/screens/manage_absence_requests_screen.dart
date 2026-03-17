import 'package:flutter/material.dart';
import 'package:bai1/models/absence_request.dart';
import 'package:bai1/controllers/absence_request_controller.dart';

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
    // Use addPostFrameCallback to ensure context is available for ModalRoute args
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRequests();
    });
  }

  Future<void> _fetchRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final args = ModalRoute.of(context)?.settings.arguments as dynamic;
    final int? staffId = args?.staffId;
    
    final requests = await _controller.fetchAbsenceRequests(staffId: staffId);
    if (mounted) {
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    setState(() => _isLoading = true);
    final success = await _controller.updateStatus(id, status);
    if (success) {
      _fetchRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request $status successfully")),
        );
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Action failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Manage Absences", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
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

  Widget _buildRequestCard(AbsenceRequestModel item) {
    Color statusColor = Colors.lightBlue;
    IconData statusIcon = Icons.access_time_filled;

    if (item.status == 'Approved') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (item.status == 'Rejected') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    // Parse date for display
    String displayDate = '';
    try {
      DateTime parsedDate = DateTime.parse(item.date);
      displayDate =
          '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    } catch (_) {
      displayDate = item.date;
    }

    List<Widget> slotWidgets = item.slots.map((s) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.label_important_outline, size: 14, color: Colors.lightBlue),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              "${s.slotName} (${s.startTime} - ${s.endTime}): ${s.subjectName}",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    )).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Colors.lightBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.studentName} [${item.className}]',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                item.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Date: $displayDate",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),
          const Text(
            "Lesson Details:",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...slotWidgets,
          if (item.reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Reason: ${item.reason}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ),
          ],
          if (item.status == 'Pending') ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _updateStatus(item.id, 'Rejected'),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text("Reject"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _updateStatus(item.id, 'Approved'),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text("Approve"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
