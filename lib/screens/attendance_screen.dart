import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/attendance_model.dart';
import '../models/student_model.dart';
import '../widgets/glass_container.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedFilter = "All";
  List<AttendanceModel>? _allRecords;
  bool _isLoading = true;
  String? _errorMessage;

  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final prefs = await SharedPreferences.getInstance();
      final orgId = prefs.getString('orgId');
      if (orgId == null) {
        throw Exception("Organization ID not found");
      }

      // First fetch student to get the student UID (doc ID)
      // We listen to the stream once or we can just assume the one from home is cached?
      // Stream subscription is okay but Future is easier for one-time fetch.
      // But getStudent is a stream. Let's filter it.
      final student = await _dbService.getStudent(orgId, user.uid).first;

      if (student == null) {
        throw Exception("Student profile not found");
      }

      final attendance = await _dbService.getAttendance(orgId, student.uid);

      if (mounted) {
        setState(() {
          _allRecords = attendance;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<AttendanceModel> get _filteredRecords {
    if (_allRecords == null) return [];
    if (_selectedFilter == "All") {
      return _allRecords!;
    }
    return _allRecords!
        .where((record) => record.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Attendance History")),
        body: Center(child: Text("Error: $_errorMessage")),
      );
    }

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
            child: _filteredRecords.isEmpty
                ? const Center(child: Text("No records found"))
                : ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final r = _filteredRecords[index];
                      final isBoarded = r.status == "Boarded";

                      return GlassContainer(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isBoarded ? Icons.check_circle : Icons.cancel,
                              color: isBoarded
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 24.r,
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.date,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Status: ${r.status}",
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : Colors.white54,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
