import 'package:flutter/material.dart';

class TableApp extends StatelessWidget {
  const TableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudentHub Timetable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  // Variables to store selected values
  String selectedYear = '2026';
  String selectedWeek = '02/03 To 08/03';

  @override
  Widget build(BuildContext context) {
    // Slightly increase column 0 width to fit the dropdown
    final Map<int, TableColumnWidth> columnWidths = {
      0: const FixedColumnWidth(110),
      for (int i = 1; i <= 7; i++) i: const FixedColumnWidth(150),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("StudentHub Timetable"),
        backgroundColor: Colors.lightBlue.shade100,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                columnWidths: columnWidths,
                children: [
                  _buildHeaderRow1(),
                  _buildHeaderRow2(),
                  // Slots from 0 to 12
                  _buildEmptySlotRow("Slot 0"),
                  _buildEmptySlotRow("Slot 1"),
                  _buildSlot2Row(),
                  _buildSlot3Row(),
                  _buildSlot4Row(),
                  for (int i = 5; i <= 12; i++) _buildEmptySlotRow("Slot $i"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header Row 1
  TableRow _buildHeaderRow1() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFF03A9F4)), // Light Blue primary
      children: [
        _yearDropdownCell(), // Use Dropdown for Year
        _headerCell("MON", isWhite: true),
        _headerCell("TUE", isWhite: true),
        _headerCell("WED", isWhite: true),
        _headerCell("THU", isWhite: true),
        _headerCell("FRI", isWhite: true),
        _headerCell("SAT", isWhite: true),
        _headerCell("SUN", isWhite: true),
      ],
    );
  }

  // Header Row 2
  TableRow _buildHeaderRow2() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFB3E5FC)), // Light Blue secondary
      children: [
        _weekDropdownCell(), // Use Dropdown for Week
        _headerCell("02/03"),
        _headerCell("03/03"),
        _headerCell("04/03"),
        _headerCell("05/03"),
        _headerCell("06/03"),
        _headerCell("07/03"),
        _headerCell("08/03"),
      ],
    );
  }

  // --- Widget Dropdown for YEAR ---
  Widget _yearDropdownCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "YEAR ",
            style: TextStyle(
              color: Colors.lightBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedYear,
                  isExpanded: true,
                  iconSize: 16,
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedYear = newValue;
                      });
                    }
                  },
                  items: ['2024', '2025', '2026'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Dropdown for WEEK ---
  Widget _weekDropdownCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "WEEK",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.grey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedWeek,
                isExpanded: true,
                iconSize: 16,
                style: const TextStyle(color: Colors.black, fontSize: 11),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedWeek = newValue;
                    });
                  }
                },
                items: ['24/02 To 01/03', '02/03 To 08/03', '09/03 To 15/03']
                    .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      );
                    })
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- The widgets below remain the same ---

  TableRow _buildEmptySlotRow(String slotName) {
    return TableRow(
      children: [
        _slotNameCell(slotName),
        for (int i = 0; i < 7; i++) _emptyCell(),
      ],
    );
  }

  TableRow _buildSlot2Row() {
    return TableRow(
      children: [
        _slotNameCell("Slot 2"),
        _classCell(
          "EXE201",
          "DE-324",
          "(10:00-12:20)",
          isOnline: true,
          status: "(attended)",
        ),
        _emptyCell(),
        _emptyCell(),
        _emptyCell(),
        _emptyCell(),
        _emptyCell(),
        _emptyCell(),
      ],
    );
  }

  TableRow _buildSlot3Row() {
    return TableRow(
      children: [
        _slotNameCell("Slot 3"),
        _emptyCell(),
        _emptyCell(),
        _classCell(
          "PRM393",
          "DE-333",
          "(12:50-15:10)",
          status: "(Not yet)",
          statusColor: Colors.red,
        ),
        _classCell(
          "PRN232",
          "BE-418",
          "(12:50-15:10)",
          status: "(Not yet)",
          statusColor: Colors.red,
        ),
        _classCell(
          "MLN122",
          "BE-217",
          "(12:50-15:10)",
          status: "(Not yet)",
          statusColor: Colors.red,
        ),
        _emptyCell(),
        _emptyCell(),
      ],
    );
  }

  TableRow _buildSlot4Row() {
    return TableRow(
      children: [
        _slotNameCell("Slot 4"),
        _emptyCell(),
        _classCell(
          "PRN232",
          "BE-414",
          "(15:20-17:40)",
          status: "(Not yet)",
          statusColor: Colors.red,
        ),
        _classCell(
          "MLN122",
          "BE-217",
          "(15:20-17:40)",
          status: "(Not yet)",
          statusColor: Colors.red,
        ),
        _emptyCell(),
        _classCell(
          "PRM393",
          "DE-333",
          "(15:20-17:40)",
          status: "(Not yet)",
          statusColor: Colors.red,
        ),
        _emptyCell(),
        _emptyCell(),
      ],
    );
  }

  Widget _headerCell(String text, {bool isWhite = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: isWhite ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _slotNameCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(color: Colors.black87)),
    );
  }

  Widget _emptyCell() {
    return const Padding(padding: EdgeInsets.all(8.0), child: Text("-"));
  }

  Widget _classCell(
    String courseCode,
    String room,
    String time, {
    bool isOnline = false,
    String? status,
    Color statusColor = Colors.green,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "$courseCode- ",
                style: const TextStyle(
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "View Materials",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("at $room"),
          if (isOnline)
            const Text(
              "(HaDTT39 Update Online: True at 14/12/2025 23:19)",
              style: TextStyle(fontSize: 11),
            ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade700,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              time,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
          if (status != null) ...[
            const SizedBox(height: 2),
            Text(status, style: TextStyle(fontSize: 12, color: statusColor)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                time,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
          if (isOnline) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 14),
                const SizedBox(width: 4),
                Text(
                  "Online",
                  style: TextStyle(color: Colors.blue.shade600, fontSize: 16),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
