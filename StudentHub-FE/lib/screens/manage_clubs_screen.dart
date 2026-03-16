import 'package:flutter/material.dart';
import 'package:bai1/models/club.dart';
import 'package:bai1/models/student_club_member.dart';
import 'package:bai1/services/club_service.dart';

class ManageClubsScreen extends StatefulWidget {
  const ManageClubsScreen({super.key});

  @override
  State<ManageClubsScreen> createState() => _ManageClubsScreenState();
}

class _ManageClubsScreenState extends State<ManageClubsScreen> with SingleTickerProviderStateMixin {
  final ClubService _clubService = ClubService();
  List<Club> _activeClubs = [];
  List<Club> _pendingClubs = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final all = await _clubService.getAllClubs();
      setState(() {
        _activeClubs = all.where((c) => c.status == 'Active').toList();
        _pendingClubs = all.where((c) => c.status == 'PendingApproval').toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showClubDialog([Club? club]) {
    final nameController = TextEditingController(text: club?.name);
    final categoryController = TextEditingController(text: club?.category);
    final descController = TextEditingController(text: club?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(club == null ? "Create Club" : "Edit Club"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final data = {
                "name": nameController.text,
                "category": categoryController.text,
                "description": descController.text,
              };

              bool success;
              if (club == null) {
                success = await _clubService.createClub(data);
              } else {
                success = await _clubService.updateClub(int.parse(club.id), data);
              }

              if (success) {
                Navigator.pop(context);
                _fetchData();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _approveClub(Club club) async {
    final success = await _clubService.approveClub(int.parse(club.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '${club.name} has been approved!' : 'Error approving club'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
    _fetchData();
  }

  void _showMembersDialog(Club club) async {
    final clubId = int.parse(club.id);
    List<StudentClubMember> members = [];
    List<StudentClubMember> pendingMembers = [];

    try {
      members = await _clubService.getMembers(clubId);
      pendingMembers = await _clubService.getPendingMembers(clubId);
    } catch (e) {
      // ignore
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${club.name} - Members'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.lightBlue,
                    tabs: [
                      Tab(text: "Active"),
                      Tab(text: "Pending"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Active members
                        ListView.builder(
                          itemCount: members.where((m) => m.status == 'Active').length,
                          itemBuilder: (context, index) {
                            final member = members.where((m) => m.status == 'Active').toList()[index];
                            return ListTile(
                              title: Text(member.fullName),
                              subtitle: Text('${member.rollNumber} - ${member.clubRole}'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (role) async {
                                  await _clubService.assignRole(clubId, member.studentId, role);
                                  // Refresh
                                  members = await _clubService.getMembers(clubId);
                                  setDialogState(() {});
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'President', child: Text('President')),
                                  const PopupMenuItem(value: 'VicePresident', child: Text('Vice President')),
                                  const PopupMenuItem(value: 'Secretary', child: Text('Secretary')),
                                  const PopupMenuItem(value: 'Treasurer', child: Text('Treasurer')),
                                  const PopupMenuItem(value: 'Member', child: Text('Member')),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(member.clubRole, style: const TextStyle(fontSize: 12)),
                                      const Icon(Icons.arrow_drop_down, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Pending members
                        ListView.builder(
                          itemCount: pendingMembers.length,
                          itemBuilder: (context, index) {
                            final member = pendingMembers[index];
                            return ListTile(
                              title: Text(member.fullName),
                              subtitle: Text(member.rollNumber),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                    onPressed: () async {
                                      await _clubService.approveMember(clubId, member.studentId);
                                      members = await _clubService.getMembers(clubId);
                                      pendingMembers = await _clubService.getPendingMembers(clubId);
                                      setDialogState(() {});
                                      _fetchData();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () async {
                                      await _clubService.rejectMember(clubId, member.studentId);
                                      pendingMembers = await _clubService.getPendingMembers(clubId);
                                      setDialogState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Clubs", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.refresh)),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "Active (${_activeClubs.length})"),
            Tab(text: "Pending (${_pendingClubs.length})"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Active clubs
                ListView.builder(
                  itemCount: _activeClubs.length,
                  itemBuilder: (context, index) {
                    final club = _activeClubs[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.lightBlue.shade100,
                        child: Text(club.name.isNotEmpty ? club.name[0] : '?',
                            style: const TextStyle(color: Colors.lightBlue)),
                      ),
                      title: Text(club.name),
                      subtitle: Text("${club.category} - ${club.members} members"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.people, color: Colors.lightBlue),
                            tooltip: "Manage Members",
                            onPressed: () => _showMembersDialog(club),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showClubDialog(club),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Club"),
                                  content: const Text("Are you sure?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _clubService.deleteClub(int.parse(club.id));
                                _fetchData();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Pending clubs
                ListView.builder(
                  itemCount: _pendingClubs.length,
                  itemBuilder: (context, index) {
                    final club = _pendingClubs[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.lightBlue.shade200,
                        child: const Icon(Icons.hourglass_top, color: Colors.white),
                      ),
                      title: Text(club.name),
                      subtitle: Text("${club.category} - Pending Approval"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                            tooltip: "Approve",
                            onPressed: () => _approveClub(club),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Reject",
                            onPressed: () async {
                              await _clubService.deleteClub(int.parse(club.id));
                              _fetchData();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClubDialog(),
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
