import 'package:flutter/material.dart';
import 'package:bai1/models/absence_request.dart';
import 'package:bai1/controllers/absence_request_controller.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final AbsenceRequestController _controller = AbsenceRequestController();
  List<AbsenceRequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  bool _isInitialized = false;

  int? _accountId;
  int? _classId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        if (args is int) {
          _accountId = args;
        } else {
          try {
            _accountId = (args as dynamic).id;
            _classId = (args as dynamic).classId;
          } catch (e) {
            debugPrint("ReportScreen: Error parsing arguments: $e");
          }
        }
      }
      _fetchRequests();
      _isInitialized = true;
    }
  }

  Future<void> _fetchRequests() async {
    final requests = await _controller.fetchAbsenceRequests(accountId: _accountId, classId: _classId);
    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Requests',
          style: TextStyle(color: Colors.white),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(
                  child: Text(
                    'No requests yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final item = _requests[index];
                    return _buildReportCard(item);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/create_report',
            arguments: {
              'accountId': _accountId,
              'classId': _classId,
            },
          );
          if (result == true) {
            // Refresh list after creating a new request
            setState(() => _isLoading = true);
            _fetchRequests();
          }
        },
      ),
    );
  }

  Widget _buildReportCard(AbsenceRequestModel item) {
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

    // Build slot names for duration info
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
                child: const Icon(Icons.description, color: Colors.lightBlue),
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
                            'Absence Request [${item.className}]',
                            style: const TextStyle(
                              fontSize: 15,
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
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/create_report',
                      arguments: {
                        'accountId': _accountId,
                        'editRequest': item,
                      },
                    );
                    if (result == true) {
                      setState(() => _isLoading = true);
                      _fetchRequests();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmation(item.id),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Delete"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
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

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this absence request?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final success = await _controller.deleteAbsenceRequest(id);
              if (success) {
                _fetchRequests();
              } else {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Delete failed")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

}
