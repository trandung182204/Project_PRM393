import 'package:flutter/material.dart';
import '../services/subject_service.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final SubjectService _subjectService = SubjectService();
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    try {
      final subjects = await _subjectService.getSubjects();
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showSubjectDialog([Map<String, dynamic>? subject]) {
    final isEditing = subject != null;
    final codeController = TextEditingController(text: subject?['subjectCode'] ?? '');
    final nameController = TextEditingController(text: subject?['subjectName'] ?? '');
    final creditsController = TextEditingController(text: subject?['credits']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Edit Subject" : "Add Subject"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: "Subject Code (e.g., PRN211)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Subject Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditsController,
                decoration: const InputDecoration(labelText: "Credits"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final data = {
                "subjectCode": codeController.text,
                "subjectName": nameController.text,
                "credits": int.tryParse(creditsController.text) ?? 0,
              };

              try {
                if (isEditing) {
                  await _subjectService.updateSubject(subject['id'], data);
                  _showSuccess("Updated successfully");
                } else {
                  await _subjectService.addSubject(data);
                  _showSuccess("Added successfully");
                }
                Navigator.pop(context);
                _loadSubjects();
              } catch (e) {
                _showError(e.toString());
              }
            },
            child: Text(isEditing ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubject(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete subject '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _subjectService.deleteSubject(id);
        _showSuccess("Deleted successfully");
        _loadSubjects();
      } catch (e) {
        String errorMsg = e.toString();
        // Clean up exception string if needed
        if (errorMsg.startsWith("Exception: ")) {
          errorMsg = errorMsg.substring(11);
        }
        _showError(errorMsg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subject Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? const Center(child: Text("Chưa có môn học nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final s = _subjects[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          "${s['subjectCode']} - ${s['subjectName']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Credits: ${s['credits']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showSubjectDialog(s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSubject(s['id'], s['subjectName']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(),
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
