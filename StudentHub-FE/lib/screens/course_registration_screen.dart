import 'package:flutter/material.dart';
import '../controllers/registration_controller.dart';
import '../services/subject_service.dart';

class CourseRegistrationScreen extends StatefulWidget {
  final int studentId;
  const CourseRegistrationScreen({super.key, required this.studentId});

  @override
  State<CourseRegistrationScreen> createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  final _registrationController = RegistrationController();
  final _subjectService = SubjectService();

  List<Map<String, dynamic>> _subjects = [];
  
  int? _selectedSubjectId;
  bool _isLoading = true;
  bool _isModifying = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _subjectService.getSubjects(),
      ]);
      
      setState(() {
        _subjects = results[0];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleRegister() async {
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a subject')));
      return;
    }

    setState(() => _isModifying = true);
    try {
      await _registrationController.registerSubject(
        studentId: widget.studentId,
        subjectId: _selectedSubjectId!,
        semesterId: 1, // Default or placeholder
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isModifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Registration')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Select Subject'),
                  items: _subjects.map((s) => DropdownMenuItem<int>(
                    value: s['id'],
                    child: Text(s['subjectName']),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedSubjectId = v),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isModifying ? null : _handleRegister,
                  child: _isModifying ? const CircularProgressIndicator() : const Text('REGISTER'),
                )
              ],
            ),
          ),
    );
  }
}
