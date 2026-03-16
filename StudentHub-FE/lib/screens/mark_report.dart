import 'package:flutter/material.dart';
import 'package:bai1/controllers/grade_controller.dart';
import 'package:bai1/models/grade.dart';

class MarkReportScreen extends StatefulWidget {
  const MarkReportScreen({super.key});

  @override
  State<MarkReportScreen> createState() => _MarkReportScreenState();
}

class _MarkReportScreenState extends State<MarkReportScreen> {
  final GradeController _controller = GradeController();
  List<GradeModel> _grades = [];
  bool _isLoading = true;
  int? _studentId;

  String _selectedYear = 'All';

  List<String> _years = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final filters = await _controller.fetchFilterOptions();
    setState(() {
      _years = ['All', ...filters['years']!];
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _studentId == null) {
      _studentId = args;
      _fetchGrades();
    }
  }

  Future<void> _fetchGrades() async {
    if (_studentId == null) return;

    setState(() => _isLoading = true);

    final yearFilter = _selectedYear == 'All' ? null : _selectedYear;

    final results = await _controller.fetchGrades(
      _studentId!,
      scholastic: yearFilter,
    );

    setState(() {
      _grades = results;
      _isLoading = false;
    });
  }

  // --- AVERAGE SCORE CALCULATION ---
  double get _averageScore {
    if (_grades.isEmpty) return 0.0;
    double sum = 0;
    for (var item in _grades) {
      sum += item.score;
    }
    return sum / _grades.length;
  }

  // --- ACADEMIC RANKING ---
  String get _academicRank {
    double avg = _averageScore;
    if (avg >= 9.0) return 'Excellent';
    if (avg >= 8.0) return 'Very Good';
    if (avg >= 6.5) return 'Good';
    if (avg >= 5.0) return 'Average';
    return 'Weak';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Academic Result',
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

      body: Column(
        children: [
          // 1. FILTER SECTION
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: _buildDropdown(
              value: _selectedYear,
              items: _years,
              label: "Scholastic",
              onChanged: (val) {
                setState(() => _selectedYear = val!);
                _fetchGrades();
              },
            ),
          ),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_grades.isEmpty)
            const Expanded(
              child: Center(child: Text("No grade records found.")),
            )
          else ...[
            // 2. AVERAGE SCORE CARD
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.lightBlue.shade400, Colors.lightBlue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Average Score",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _averageScore.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        width: 1,
                        height: 40,
                        color: Colors.white24,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Rank",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _academicRank,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Passed: ${_grades.where((e) => e.status == 'Passed').length}/${_grades.length}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. GRADE LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _grades.length,
                itemBuilder: (context, index) {
                  final item = _grades[index];
                  final bool isPassed = item.status == 'Passed';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isPassed
                            ? Colors.green[50]
                            : Colors.red[50],
                        child: Icon(
                          isPassed ? Icons.check_circle : Icons.cancel,
                          color: isPassed ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        item.subjectName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.status,
                            style: TextStyle(
                              color: isPassed ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildScoreSmall("O", item.oralScore),
                              _buildScoreSmall("15'", item.smallTestScore),
                              _buildScoreSmall("45'", item.middleTestScore),
                              _buildScoreSmall("FE", item.finalTestScore),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isPassed
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPassed
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "AVG",
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${item.score}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isPassed ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreSmall(String label, double score) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          score.toString(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Helper Widget for Dropdown
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    // Ensure value is in items to avoid error
    final effectiveValue = items.contains(value) ? value : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.lightBlue),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
