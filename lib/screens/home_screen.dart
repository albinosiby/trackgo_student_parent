import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'map_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../models/student_model.dart';
import '../models/driver_model.dart';
import '../models/bus_model.dart';
import 'login_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  final String orgId;
  const HomeScreen({super.key, required this.orgId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    try {
      await _notificationService.initialize();
      final token = await _notificationService.getToken();
      final user = _authService.currentUser;

      if (token != null && user != null) {
        // We need to find the student ID to update the token.
        final dbService = DatabaseService();
        // Use a single subscription to get the data once and cancel
        final snapshot = await dbService
            .getStudent(widget.orgId, user.uid)
            .first;
        if (snapshot != null) {
          await dbService.updateFcmToken(widget.orgId, snapshot.uid, token);
          print("FCM Token Updated for ${snapshot.fullName}");
        }
      }
    } catch (e) {
      print("Error setting up notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Not logged in"),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<StudentModel?>(
      stream: _dbService.getStudent(widget.orgId, user.uid),
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
          return const Scaffold(
            body: Center(child: Text("Student profile not found")),
          );
        }

        final student = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(student.fullName)),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Student Card
                GlassContainer(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      // Avatar with Neon Glow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryAccent,
                            width: 2.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAccent.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 30.r,
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
                      ),
                      SizedBox(width: 16.w),

                      // Student Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.fullName,
                              style: AppTextStyles.title.copyWith(
                                fontSize: 18.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 14.sp,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  student.rollNumber,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Icon(
                                  Icons.school_outlined,
                                  size: 14.sp,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  student.batch,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: student.isOnBus
                                ? [
                                    AppColors.success.withOpacity(0.2),
                                    AppColors.success.withOpacity(0.05),
                                  ]
                                : [
                                    AppColors.error.withOpacity(0.2),
                                    AppColors.error.withOpacity(0.05),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color:
                                (student.isOnBus
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              student.isOnBus
                                  ? Icons.directions_bus_rounded
                                  : Icons.person_off_rounded,
                              color: student.isOnBus
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 22.sp,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              student.isOnBus ? "BOARDED" : "OFF-BUS",
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                color: student.isOnBus
                                    ? AppColors.success
                                    : AppColors.error,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Bus Status Card
                GlassContainer(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text("Bus Live Status", style: AppTextStyles.title),
                      SizedBox(height: 12.h),
                      StreamBuilder<BusModel?>(
                        stream: student.busId != null
                            ? _dbService.getBusStream(
                                widget.orgId,
                                student.busId!,
                              )
                            : null,
                        builder: (context, busSnapshot) {
                          String status = "N/A";
                          if (busSnapshot.hasData && busSnapshot.data != null) {
                            final rawStatus = busSnapshot.data!.tripStatus;
                            if (rawStatus == "Trip started") {
                              status = "Trip Started";
                            } else if (rawStatus == "completed") {
                              status = "Completed";
                            } else {
                              status = rawStatus;
                            }
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatusTile(
                                label: "Bus No",
                                value: student.busNumber ?? "N/A",
                              ),
                              _StatusTile(label: "Status", value: status),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                      // Fetch Driver Details using bus_id
                      if (student.busId != null)
                        FutureBuilder<DriverModel?>(
                          future: _dbService.getDriverByBus(
                            widget.orgId,
                            student.busId!,
                          ),
                          builder: (context, driverSnapshot) {
                            if (driverSnapshot.hasError) {
                              return const Text(
                                "Error loading driver info",
                                style: TextStyle(color: AppColors.error),
                              );
                            }

                            String? driverPhone;

                            if (driverSnapshot.hasData &&
                                driverSnapshot.data != null) {
                              driverPhone = driverSnapshot.data!.phoneNumber;
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              MapScreen(orgId: widget.orgId),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryAccent,
                                      foregroundColor: Colors.black,
                                    ),
                                    icon: const Icon(Icons.map),
                                    label: const Text("Track"),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        driverPhone != null &&
                                            driverPhone.isNotEmpty
                                        ? () async {
                                            final Uri launchUri = Uri(
                                              scheme: 'tel',
                                              path: driverPhone,
                                            );
                                            try {
                                              await launchUrl(launchUri);
                                            } catch (e) {
                                              debugPrint(
                                                "Could not launch $launchUri: $e",
                                              );
                                            }
                                          }
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.white54,
                                      ),
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.call),
                                    label: const Text("Call Driver"),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      else
                        // Fallback if no bus_id
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.map),
                                label: const Text("Track"),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: null,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white12),
                                  foregroundColor: Colors.white12,
                                ),
                                icon: const Icon(Icons.call),
                                label: const Text("Call Driver"),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // ... ETA Card can remain static or be updated similarly

                // Dynamic Status Message
                StreamBuilder<BusModel?>(
                  stream: student.busId != null
                      ? _dbService.getBusStream(widget.orgId, student.busId!)
                      : null,
                  builder: (context, busSnapshot) {
                    if (!busSnapshot.hasData || busSnapshot.data == null) {
                      return const SizedBox.shrink();
                    }

                    final bus = busSnapshot.data!;
                    final isTripStarted =
                        bus.tripStatus ==
                        "Trip started"; // Check exact string from backend
                    final isOnBus = student.isOnBus;

                    if (isOnBus) {
                      return Padding(
                        padding: EdgeInsets.only(top: 24.h),
                        child: GlassContainer(
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 20.w,
                          ),
                          borderColor: AppColors.success.withOpacity(0.5),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  "You have boarded successfully",
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (isTripStarted) {
                      return Padding(
                        padding: EdgeInsets.only(top: 24.h),
                        child: GlassContainer(
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 20.w,
                          ),
                          borderColor: Colors.amber.withOpacity(0.5),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_filled,
                                color: Colors.amber,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  "Please be ready on stop, trip has started",
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String label, value;

  const _StatusTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
