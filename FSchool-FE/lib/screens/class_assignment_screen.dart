import 'package:flutter/material.dart';
import '../controllers/registration_controller.dart';
import '../services/student_service.dart';
import '../services/class_service.dart';

class ClassAssignmentScreen extends StatefulWidget {
  const ClassAssignmentScreen({super.key});

  @override
  State<ClassAssignmentScreen> createState() => _ClassAssignmentScreenState();
}

enum ScreenState { classList, classDetail }

class _ClassAssignmentScreenState extends State<ClassAssignmentScreen> {
  final _registrationController = RegistrationController();
  final _studentService = StudentService();
  final _classService = ClassService();

  ScreenState _currentState = ScreenState.classList;
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _filteredClasses = [];
  Map<String, dynamic>? _selectedClass;
  List<Map<String, dynamic>> _studentsInClass = [];
  
  bool _isLoading = true;
  String _classSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final classes = await _classService.getClasses();
      setState(() {
        _classes = classes;
        _filteredClasses = classes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClassDetails(Map<String, dynamic> schoolClass) async {
    setState(() {
      _selectedClass = schoolClass;
      _isLoading = true;
      _currentState = ScreenState.classDetail;
    });
    try {
      final students = await _classService.getStudentsInClass(schoolClass['id']);
      setState(() {
        _studentsInClass = students;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  void _filterClasses(String query) {
    setState(() {
      _classSearchQuery = query;
      _filteredClasses = _classes
          .where((c) => c['className'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _handleRemoveStudent(int studentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn xóa sinh viên này khỏi lớp?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await _registrationController.removeFromClass(
        classId: _selectedClass!['id'],
        studentId: studentId,
      );
      if (success) {
        _loadClassDetails(_selectedClass!);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddStudentPicker() async {
    final allStudents = await _studentService.getStudents();
    final currentIds = _studentsInClass.map((s) => s['id']).toSet();
    final availableStudents = allStudents.where((s) => !currentIds.contains(s['id'])).toList();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StudentPicker(
        students: availableStudents,
        onSelected: (selectedIds) async {
          if (selectedIds.isEmpty) return;
          setState(() => _isLoading = true);
          final success = await _registrationController.batchAssignToClass(
            classId: _selectedClass!['id'],
            studentIds: selectedIds,
          );
          if (success) {
            _loadClassDetails(_selectedClass!);
          } else {
            setState(() => _isLoading = false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentState == ScreenState.classDetail) {
          setState(() => _currentState = ScreenState.classList);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            _currentState == ScreenState.classList ? 'Xếp Lớp' : _selectedClass?['className'] ?? 'Chi Tiết',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          leading: _currentState == ScreenState.classDetail
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => setState(() => _currentState = ScreenState.classList),
                )
              : null,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : _currentState == ScreenState.classList
                ? _buildClassList()
                : _buildClassDetail(),
        floatingActionButton: _currentState == ScreenState.classList
            ? FloatingActionButton(
                onPressed: _showAddClassDialog,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }

  void _showAddClassDialog() {
    final classNameController = TextEditingController();
    final academicYearController = TextEditingController(text: "2024-2027");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm lớp học mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: classNameController,
              decoration: const InputDecoration(labelText: "Tên lớp (VD: 12A1)"),
            ),
            TextField(
              controller: academicYearController,
              decoration: const InputDecoration(labelText: "Niên khóa (VD: 2024-2027)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (classNameController.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _classService.createClass(
                  className: classNameController.text,
                  academicYear: academicYearController.text,
                );
                _loadClasses();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tạo lớp học thành công!")));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Tạo lớp", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _filterClasses,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm lớp học...',
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
          child: _filteredClasses.isEmpty
              ? const Center(child: Text("Không tìm thấy lớp học"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredClasses.length,
                  itemBuilder: (context, index) {
                    final c = _filteredClasses[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: const Icon(Icons.class_, color: Colors.orange),
                        ),
                        title: Text(c['className'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Lớp ID: ${c['id']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                              onPressed: () => _showEditClassDialog(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _handleDeleteClass(c),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                        onTap: () => _loadClassDetails(c),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showEditClassDialog(Map<String, dynamic> c) {
    final classNameController = TextEditingController(text: c['className']);
    final academicYearController = TextEditingController(text: c['academicYear']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chỉnh sửa lớp học"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: classNameController,
              decoration: const InputDecoration(labelText: "Tên lớp"),
            ),
            TextField(
              controller: academicYearController,
              decoration: const InputDecoration(labelText: "Niên khóa"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (classNameController.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _classService.updateClass(
                  classId: c['id'],
                  className: classNameController.text,
                  academicYear: academicYearController.text,
                );
                _loadClasses();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật lớp học thành công!")));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteClass(Map<String, dynamic> c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa lớp ${c['className']}? Hành động này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _classService.deleteClass(c['id']);
        _loadClasses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Xóa lớp học thành công!")));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildClassDetail() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.orange.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Danh sách sinh viên trong lớp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("${_studentsInClass.length} sinh viên", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ),
        Expanded(
          child: _studentsInClass.isEmpty
              ? const Center(child: Text("Lớp chưa có sinh viên nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _studentsInClass.length,
                  itemBuilder: (context, index) {
                    final s = _studentsInClass[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(s['fullName'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(s['rollNumber']),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
                          onPressed: () => _handleRemoveStudent(s['id']),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _showAddStudentPicker,
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text("THÊM SINH VIÊN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StudentPicker extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final Function(List<int>) onSelected;

  const StudentPicker({super.key, required this.students, required this.onSelected});

  @override
  State<StudentPicker> createState() => _StudentPickerState();
}

class _StudentPickerState extends State<StudentPicker> {
  List<Map<String, dynamic>> _filteredStudents = [];
  final Set<int> _selectedIds = {};
  String _query = "";

  @override
  void initState() {
    super.initState();
    _filteredStudents = widget.students;
  }

  void _filter(String q) {
    setState(() {
      _query = q;
      _filteredStudents = widget.students
          .where((s) =>
              s['fullName'].toString().toLowerCase().contains(q.toLowerCase()) ||
              s['rollNumber'].toString().toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Chọn sinh viên", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: _filter,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên hoặc mã số...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                final s = _filteredStudents[index];
                final isSelected = _selectedIds.contains(s['id']);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(s['fullName']),
                  subtitle: Text(s['rollNumber']),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedIds.add(s['id']);
                      } else {
                        _selectedIds.remove(s['id']);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      widget.onSelected(_selectedIds.toList());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("XÁC NHẬN (${_selectedIds.length})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
