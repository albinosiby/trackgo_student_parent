import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/student_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  String? _orgId;

  @override
  void initState() {
    super.initState();
    _loadOrgId();
  }

  Future<void> _loadOrgId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgId = prefs.getString('orgId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    if (_orgId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<StudentModel?>(
      stream: _dbService.getStudent(_orgId!, user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(body: Center(child: Text("Profile not found")));
        }

        final student = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text("Student Profile")),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.indigo,
                        backgroundImage: student.profilePhotoUrl != null
                            ? NetworkImage(student.profilePhotoUrl!)
                            : null,
                        child: student.profilePhotoUrl == null
                            ? Icon(
                                Icons.person,
                                size: 50.r,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        student.fullName,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Class: ${student.batch} | Roll No: ${student.rollNumber}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Fee Details Section
                Text(
                  "Fee Details",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FeeInfoTile(
                              label: "Total Fee",
                              amount:
                                  "₹${student.feeAmount.toStringAsFixed(0)}",
                              color: Colors.black,
                            ),
                            _FeeInfoTile(
                              label: "Paid",
                              amount: "₹${student.paid.toStringAsFixed(0)}",
                              color: Colors.green,
                            ),
                            _FeeInfoTile(
                              label: "Pending",
                              amount: "₹${student.due.toStringAsFixed(0)}",
                              color: Colors.red,
                            ),
                          ],
                        ),
                        Divider(height: 32.h),
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            "School Fee",
                          ), // Generalizing Term 1/2 for now
                          trailing: Chip(
                            label: Text("Active"),
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                        // You can iterate over payments subcollection if needed later
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentHistoryScreen(
                                    orgId: _orgId!,
                                    studentUid: student.uid,
                                  ),
                                ),
                              );
                            },
                            child: const Text("View Payment History"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Transport Details
                if (student.busNumber != null || student.busStop != null) ...[
                  Text(
                    "Transport Details",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        if (student.busNumber != null)
                          ListTile(
                            leading: const Icon(Icons.directions_bus),
                            title: Text("Bus No: ${student.busNumber}"),
                          ),
                        if (student.busStop != null)
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text("${student.busStop}"),
                            subtitle: const Text("Bus Stop"),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],

                // Parent/Contact Details
                Text(
                  "Contact Details",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(student.parentName),
                        subtitle: const Text("Parent/Guardian"),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(
                          student.parentPhone.isNotEmpty
                              ? student.parentPhone
                              : "N/A",
                        ),
                        subtitle: const Text("Registered Mobile"),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: Text(
                          student.parentEmail.isNotEmpty
                              ? student.parentEmail
                              : "N/A",
                        ),
                        subtitle: const Text("Parent Email"),
                      ),
                      const Divider(height: 1),
                      if (student.address != null)
                        ListTile(
                          leading: const Icon(Icons.home),
                          title: Text(student.address!),
                          subtitle: const Text("Address"),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    onPressed: () async {
                      await _authService.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeeInfoTile extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _FeeInfoTile({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
