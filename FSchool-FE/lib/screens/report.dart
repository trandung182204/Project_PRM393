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
    _fetchRequests();
  }

  int? _accountId;
  int? _classId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        backgroundColor: Colors.orange,
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
        backgroundColor: Colors.orange,
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
    Color statusColor = Colors.orange;
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
    String slotInfo = item.slots.isNotEmpty
        ? item.slots.map((s) => s.slotName).join(', ')
        : 'N/A';

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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Request for Absent',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Slots", slotInfo),
              _buildInfoColumn("Date", displayDate),
            ],
          ),
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
                  label: const Text("Sửa"),
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
                  label: const Text("Xóa"),
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
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa đơn nghỉ này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
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
                  const SnackBar(content: Text("Xóa thất bại")),
                );
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
