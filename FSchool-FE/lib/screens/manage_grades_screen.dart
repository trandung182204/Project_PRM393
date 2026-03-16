import 'package:flutter/material.dart';
import 'package:bai1/controllers/grade_controller.dart';
import 'package:bai1/models/auth_response.dart';
import 'package:bai1/models/grade.dart';

class ManageGradesScreen extends StatefulWidget {
  const ManageGradesScreen({super.key});

  @override
  State<ManageGradesScreen> createState() => _ManageGradesScreenState();
}

class _ManageGradesScreenState extends State<ManageGradesScreen> {
  final GradeController _gradeController = GradeController();

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];

  Map<String, dynamic>? _selectedClass;
  Map<String, dynamic>? _selectedSemester;
  Map<String, dynamic>? _selectedSubject;

  bool _isLoading = true;
  bool _isStudentsLoading = false;
  bool _hasLoadedInitialData = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedInitialData) {
      _hasLoadedInitialData = true;
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((s) {
        final name = (s['fullName'] ?? s['FullName'] ?? '').toString().toLowerCase();
        final roll = (s['rollNumber'] ?? s['RollNumber'] ?? '').toString().toLowerCase();
        return name.contains(query) || roll.contains(query);
      }).toList();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      int? staffId;
      
      if (arguments is AuthResponse) {
        staffId = arguments.staffId;
        debugPrint("ManageGrades: Logging in as Staff. StaffId: $staffId");
      } else {
        debugPrint("ManageGrades: No AuthResponse found in arguments. Falling back to Admin view.");
      }

      List<Map<String, dynamic>> classes = [];
      List<Map<String, dynamic>> subjects = [];
      List<Map<String, dynamic>> semesters = [];
      
      if (staffId != null && staffId > 0) {
        classes = await _gradeController.fetchClassesByStaff(staffId);
        subjects = await _gradeController.fetchSubjectsByStaff(staffId);
        debugPrint("ManageGrades: Fetched ${classes.length} classes and ${subjects.length} subjects for staff $staffId");
      } else {
        classes = await _gradeController.fetchClasses();
        subjects = await _gradeController.fetchSubjects();
        debugPrint("ManageGrades: Fetched ${classes.length} total classes and ${subjects.length} total subjects (Admin/Fallback)");
      }
      
      semesters = await _gradeController.fetchSemesters();

      setState(() {
        _classes = classes;
        _subjects = subjects;
        _semesters = semesters;
        if (_classes.isEmpty && staffId != null) {
          _errorMessage = "No classes found for this teacher in the schedule.";
        }
      });
    } catch (e) {
      debugPrint("ManageGrades Error: $e");
      setState(() => _errorMessage = "Error loading data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudents() async {
    final classId = _selectedClass?['id'] ?? _selectedClass?['Id'];
    if (classId == null) return;
    
    setState(() {
      _isStudentsLoading = true;
      _filteredStudents = [];
    });
    
    try {
      final students = await _gradeController.fetchStudentsByClass(classId);
      setState(() {
        _students = students;
        _filterStudents();
      });
    } catch (e) {
      debugPrint("LoadStudents Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading students: $e")));
    } finally {
      setState(() => _isStudentsLoading = false);
    }
  }

  void _showSearchSelection({
    required String title,
    required List<Map<String, dynamic>> items,
    required String labelField,
    required Function(Map<String, dynamic>) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _SearchableListSheet(
          title: title,
          items: items,
          labelField: labelField,
          onSelected: (item) {
            onSelected(item);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showGradeDialog(Map<String, dynamic> student) async {
    final semesterId = _selectedSemester?['id'] ?? _selectedSemester?['Id'];
    final subjectId = _selectedSubject?['id'] ?? _selectedSubject?['Id'];
    
    if (semesterId == null || subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a semester and subject first")));
      return;
    }

    final int studentId = student['id'] ?? student['Id'];
    
    // Attempt to fetch existing grade for this specific subject/semester
    GradeModel? existingGrade;
    try {
      final grades = await _gradeController.fetchGrades(studentId, semester: _selectedSemester?['name'] ?? _selectedSemester?['Name']);
      existingGrade = grades.where((g) => g.subjectName == (_selectedSubject?['subjectName'] ?? _selectedSubject?['SubjectName'])).firstOrNull;
    } catch (e) {
      debugPrint("Error fetching existing grade: $e");
    }

    final TextEditingController oralController = TextEditingController(text: existingGrade?.oralScore.toString() ?? "");
    final TextEditingController smallController = TextEditingController(text: existingGrade?.smallTestScore.toString() ?? "");
    final TextEditingController middleController = TextEditingController(text: existingGrade?.middleTestScore.toString() ?? "");
    final TextEditingController finalController = TextEditingController(text: existingGrade?.finalTestScore.toString() ?? "");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double? calcAvg() {
            try {
              double o = double.tryParse(oralController.text) ?? 0;
              double s = double.tryParse(smallController.text) ?? 0;
              double m = double.tryParse(middleController.text) ?? 0;
              double f = double.tryParse(finalController.text) ?? 0;
              return double.parse(((o + s + m * 2 + f * 3) / 7).toStringAsFixed(1));
            } catch (_) { return null; }
          }

          final avg = calcAvg();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['fullName'] ?? student['FullName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${_selectedSubject?['subjectName'] ?? _selectedSubject?['SubjectName']} - ${_selectedSemester?['name'] ?? _selectedSemester?['Name']}", 
                   style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGradeInput("Oral Score (x1)", oralController, (val) => setDialogState(() {})),
                  const SizedBox(height: 12),
                  _buildGradeInput("15m Test (x1)", smallController, (val) => setDialogState(() {})),
                  const SizedBox(height: 12),
                  _buildGradeInput("45m Test (x2)", middleController, (val) => setDialogState(() {})),
                  const SizedBox(height: 12),
                  _buildGradeInput("Semester Final (x3)", finalController, (val) => setDialogState(() {})),
                  const Divider(height: 32),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Projected Average:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(avg?.toString() ?? "0.0", 
                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: (avg ?? 0) >= 5 ? Colors.green : Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  final oral = double.tryParse(oralController.text) ?? 0;
                  final small = double.tryParse(smallController.text) ?? 0;
                  final middle = double.tryParse(middleController.text) ?? 0;
                  final finalScore = double.tryParse(finalController.text) ?? 0;

                  if ([oral, small, middle, finalScore].any((s) => s < 0 || s > 10)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All scores must be between 0 and 10")));
                    return;
                  }

                  final success = await _gradeController.updateGrade({
                    "id": existingGrade?.id,
                    "oralScore": oral,
                    "smallTestScore": small,
                    "middleTestScore": middle,
                    "finalTestScore": finalScore,
                    "studentId": studentId,
                    "subjectId": subjectId,
                    "semesterId": semesterId,
                  });

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Grades successfully updated!")));
                    // Refresh student list (or just grades in local state if we had them)
                  }
                },
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildGradeInput(String label, TextEditingController controller, Function(String) onChanged) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: "0.0 - 10.0",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Grade Management", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(onPressed: _loadInitialData, icon: const Icon(Icons.refresh, color: Colors.white)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadInitialData, child: const Text("Retry")),
                    ],
                  ),
                ))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildSelector(
                            label: "Class",
                            value: (_selectedClass?['className'] ?? _selectedClass?['ClassName']) ?? "Select Class",
                            onTap: () => _showSearchSelection(
                              title: "Select Class",
                              items: _classes,
                              labelField: 'className',
                              onSelected: (item) {
                                setState(() => _selectedClass = item);
                                _loadStudents();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSelector(
                                  label: "Semester",
                                  value: (_selectedSemester?['name'] ?? _selectedSemester?['Name']) ?? "Select Semester",
                                  onTap: () => _showSearchSelection(
                                    title: "Select Semester",
                                    items: _semesters,
                                    labelField: 'name',
                                    onSelected: (item) => setState(() => _selectedSemester = item),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSelector(
                                  label: "Subject",
                                  value: (_selectedSubject?['subjectName'] ?? _selectedSubject?['SubjectName']) ?? "Select Subject",
                                  onTap: () => _showSearchSelection(
                                    title: "Select Subject",
                                    items: _subjects,
                                    labelField: 'subjectName',
                                    onSelected: (item) => setState(() => _selectedSubject = item),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search student by name or roll number...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isStudentsLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredStudents.isEmpty && _selectedClass != null
                              ? const Center(child: Text("No students found."))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _filteredStudents.length,
                                  itemBuilder: (context, index) {
                                    final student = _filteredStudents[index];
                                    return Card(
                                      elevation: 0,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.lightBlue[50],
                                          child: const Icon(Icons.person, color: Colors.lightBlue),
                                        ),
                                        title: Text(student['fullName'] ?? student['FullName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text("Roll: ${student['rollNumber'] ?? student['RollNumber'] ?? 'N/A'}"),
                                        trailing: const Icon(Icons.edit_note, color: Colors.lightBlue),
                                        onTap: () => _showGradeDialog(student),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSelector({required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(value, 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.lightBlue),
          ],
        ),
      ),
    );
  }
}

class _SearchableListSheet extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String labelField;
  final Function(Map<String, dynamic>) onSelected;

  const _SearchableListSheet({
    required this.title,
    required this.items,
    required this.labelField,
    required this.onSelected,
  });

  @override
  State<_SearchableListSheet> createState() => _SearchableListSheetState();
}

class _SearchableListSheetState extends State<_SearchableListSheet> {
  late List<Map<String, dynamic>> _filteredItems;
  final TextEditingController _findController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filter(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) {
            final label = (item[widget.labelField] ?? item[widget.labelField[0].toUpperCase() + widget.labelField.substring(1)] ?? '').toString();
            return label.toLowerCase().contains(query.toLowerCase());
          })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _findController,
            decoration: InputDecoration(
              hintText: "Search...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: _filter,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(child: Text("No items found."))
                : ListView.separated(
                    itemCount: _filteredItems.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final label = (item[widget.labelField] ?? item[widget.labelField[0].toUpperCase() + widget.labelField.substring(1)] ?? 'Unknown').toString();
                      return ListTile(
                        title: Text(label),
                        onTap: () => widget.onSelected(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
