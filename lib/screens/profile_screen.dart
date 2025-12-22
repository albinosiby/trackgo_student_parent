import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/student_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment_history_screen.dart';
import '../widgets/glass_container.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            (student.profilePhotoUrl != null &&
                                student.profilePhotoUrl!.isNotEmpty)
                            ? CachedNetworkImageProvider(
                                student.profilePhotoUrl!,
                              )
                            : const AssetImage(
                                    'assets/dashboard_profile_mock.png',
                                  )
                                  as ImageProvider,
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
                GlassContainer(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _FeeInfoTile(
                              label: "Total Fee",
                              amount:
                                  "₹${student.feeAmount.toStringAsFixed(0)}",
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Expanded(
                            child: _FeeInfoTile(
                              label: "Paid",
                              amount: "₹${student.paid.toStringAsFixed(0)}",
                              color: AppColors.success,
                            ),
                          ),
                          Expanded(
                            child: _FeeInfoTile(
                              label: "Pending",
                              amount: "₹${student.due.toStringAsFixed(0)}",
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 32.h, color: Colors.white24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          "Travel Status",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.canTravel
                                  ? "Eligible for Transport"
                                  : "Service Suspended",
                              style: TextStyle(
                                color: student.canTravel
                                    ? Colors.white60
                                    : AppColors.error,
                                fontSize: 12.sp,
                              ),
                            ),
                            if (!student.canTravel)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  "Pay the fees to get your seats on bus",
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            student.canTravel ? "Active" : "Deactive",
                          ),
                          backgroundColor: student.canTravel
                              ? AppColors.success
                              : AppColors.error,
                          labelStyle: const TextStyle(color: Colors.black),
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
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("View Payment History"),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Transport Details
                if (student.busNumber != null ||
                    student.busStop != null ||
                    student.routeName != null) ...[
                  Text(
                    "Transport Details",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GlassContainer(
                    width: double.infinity,
                    child: Column(
                      children: [
                        if (student.routeName != null &&
                            student.routeName!.isNotEmpty)
                          ListTile(
                            leading: const Icon(
                              Icons.map,
                              color: AppColors.primaryAccent,
                            ),
                            title: Text(
                              student.routeName!,
                              style: AppTextStyles.body,
                            ),
                            subtitle: const Text(
                              "Route",
                              style: TextStyle(color: Colors.white60),
                            ),
                          ),
                        if (student.busNumber != null)
                          ListTile(
                            leading: const Icon(
                              Icons.directions_bus,
                              color: AppColors.primaryAccent,
                            ),
                            title: Text(
                              "Bus No: ${student.busNumber}",
                              style: AppTextStyles.body,
                            ),
                          ),
                        if (student.busStop != null)
                          ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: AppColors.primaryAccent,
                            ),
                            title: Text(
                              "${student.busStop}",
                              style: AppTextStyles.body,
                            ),
                            subtitle: const Text(
                              "Bus Stop",
                              style: TextStyle(color: Colors.white60),
                            ),
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
                GlassContainer(
                  width: double.infinity,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: AppColors.primaryAccent,
                        ),
                        title: Text(
                          student.parentName,
                          style: AppTextStyles.body,
                        ),
                        subtitle: const Text(
                          "Parent/Guardian",
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      ListTile(
                        leading: const Icon(
                          Icons.phone,
                          color: AppColors.primaryAccent,
                        ),
                        title: Text(
                          student.parentPhone.isNotEmpty
                              ? student.parentPhone
                              : "N/A",
                          style: AppTextStyles.body,
                        ),
                        subtitle: const Text(
                          "Registered Mobile",
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                      if (student.studentPhone != null &&
                          student.studentPhone!.isNotEmpty) ...[
                        const Divider(height: 1, color: Colors.white12),
                        ListTile(
                          leading: const Icon(
                            Icons.smartphone,
                            color: AppColors.primaryAccent,
                          ),
                          title: Text(
                            student.studentPhone!,
                            style: AppTextStyles.body,
                          ),
                          subtitle: const Text(
                            "Student Phone",
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),
                      ],
                      const Divider(height: 1, color: Colors.white12),
                      ListTile(
                        leading: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primaryAccent,
                        ),
                        title: Text(
                          student.parentEmail.isNotEmpty
                              ? student.parentEmail
                              : "N/A",
                          style: AppTextStyles.body,
                        ),
                        subtitle: const Text(
                          "Parent Email",
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      if (student.address != null)
                        ListTile(
                          leading: const Icon(
                            Icons.home,
                            color: AppColors.primaryAccent,
                          ),
                          title: Text(
                            student.address!,
                            style: AppTextStyles.body,
                          ),
                          subtitle: const Text(
                            "Address",
                            style: TextStyle(color: Colors.white60),
                          ),
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
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
        ),
        SizedBox(height: 4.h),
        Text(
          amount,
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }
}
