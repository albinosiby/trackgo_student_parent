import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedFilter = "All";

  final List<Map<String, String>> _allRecords = [
    {"date": "01 Feb 2025", "status": "Boarded"},
    {"date": "31 Jan 2025", "status": "Boarded"},
    {"date": "30 Jan 2025", "status": "Absent"},
    {"date": "29 Jan 2025", "status": "Boarded"},
    {"date": "28 Jan 2025", "status": "Boarded"},
    {"date": "27 Jan 2025", "status": "Absent"},
  ];

  List<Map<String, String>> get _filteredRecords {
    if (_selectedFilter == "All") {
      return _allRecords;
    }
    return _allRecords
        .where((record) => record["status"] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance History")),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: EdgeInsets.all(12.0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterChip("All"),
                SizedBox(width: 8.w),
                _buildFilterChip("Boarded"),
                SizedBox(width: 8.w),
                _buildFilterChip("Absent"),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: _filteredRecords.length,
              itemBuilder: (context, index) {
                final r = _filteredRecords[index];
                final isBoarded = r["status"] == "Boarded";

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isBoarded ? Icons.check_circle : Icons.cancel,
                      color: isBoarded ? Colors.green : Colors.red,
                      size: 24.r,
                    ),
                    title: Text(r["date"]!, style: TextStyle(fontSize: 16.sp)),
                    subtitle: Text(
                      "Status: ${r['status']}",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 14.sp)),
      selected: _selectedFilter == label,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
    );
  }
}
