import 'package:flutter/material.dart';
import 'package:bai1/services/club_service.dart';
import 'package:bai1/models/student_club_member.dart';

class ClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  final ClubService _clubService = ClubService();
  List<StudentClubMember> _members = [];
  bool _isLoadingMembers = false;
  bool _hasJoined = false;
  String _membershipStatus = 'None';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final clubId = int.tryParse(widget.club['id']?.toString() ?? '0') ?? 0;
      final members = await _clubService.getMembers(clubId);
      setState(() {
        _members = members.where((m) => m.status == 'Active').toList();
      });
    } catch (e) {
      // Silently fail
    } finally {
      setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _joinClub() async {
    final clubId = int.tryParse(widget.club['id']?.toString() ?? '0') ?? 0;
    // Sử dụng studentId = 1 mặc định (trong thực tế lấy từ auth)
    final success = await _clubService.joinClub(clubId, 1);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Join request sent to ${widget.club['name']}!'
                : 'Failed to send request. You might already be a member.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        setState(() {
          _hasJoined = true;
          _membershipStatus = 'Pending';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.club['name'], style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.lightBlue.shade100,
              backgroundImage: NetworkImage(widget.club['image']),
            ),
            const SizedBox(height: 20),
            Text(
              widget.club['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.club['category'],
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            // Status badge
            if (widget.club['status'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.club['status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.club['status'],
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Thống kê thành viên
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat("Members", "${widget.club['members']}"),
                Container(height: 30, width: 1, color: Colors.grey[300]),
                _buildStat("Status", widget.club['status'] ?? 'Active'),
              ],
            ),

            const SizedBox(height: 30),

            // About Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About Us",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.club['description'],
                    style: const TextStyle(color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // Members Section
                  const Text(
                    "Members",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _isLoadingMembers
                      ? const Center(child: CircularProgressIndicator())
                      : _members.isEmpty
                          ? const Text("No members yet.", style: TextStyle(color: Colors.grey))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _members.length,
                              itemBuilder: (context, index) {
                                final member = _members[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.lightBlue.shade100,
                                    child: Text(
                                      member.fullName.isNotEmpty ? member.fullName[0] : '?',
                                      style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(member.fullName),
                                  subtitle: Text(member.rollNumber),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: member.clubRole == 'President'
                                          ? Colors.lightBlue
                                          : member.clubRole == 'VicePresident'
                                              ? Colors.blue
                                              : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      member.clubRole,
                                      style: TextStyle(
                                        color: member.clubRole != 'Member' ? Colors.white : Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                  const SizedBox(height: 30),

                  // Nút Join
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasJoined ? Colors.grey : Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _hasJoined ? null : _joinClub,
                      child: Text(
                        _hasJoined
                            ? (_membershipStatus == 'Pending' ? "Pending Approval..." : "Already a Member")
                            : "Join Club",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'PendingApproval':
        return Colors.lightBlue;
      case 'Inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
