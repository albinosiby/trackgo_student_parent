import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'map_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/student_model.dart';
import '../models/driver_model.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String orgId;
  const HomeScreen({super.key, required this.orgId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();

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
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30.r,
                          backgroundImage: student.profilePhotoUrl != null
                              ? NetworkImage(student.profilePhotoUrl!)
                              : null,
                          child: student.profilePhotoUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Roll No: ${student.rollNumber}",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Text(
                                "Class: ${student.batch}",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            "Boarded",
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          backgroundColor: Colors.green.shade100,
                          labelStyle: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Bus Status Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Text(
                          "Bus Live Status",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatusTile(
                              label: "Bus No",
                              value: student.busNumber ?? "N/A",
                            ),
                            const _StatusTile(
                              label: "Status",
                              value: "Moving",
                            ), // This dynamic status would come from Bus collection
                          ],
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
                                return const Text("Error loading driver info");
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
                                            builder: (_) => const MapScreen(),
                                          ),
                                        );
                                      },
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
                                      icon: const Icon(Icons.call),
                                      label: const Text("Call Driver"),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        else
                          // Fallback if no bus_id, show disabled buttons or static
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
                                  icon: const Icon(Icons.call),
                                  label: const Text("Call Driver"),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                // ... ETA Card can remain static or be updated similarly
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
