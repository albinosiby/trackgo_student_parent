import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_screen.dart';
import 'map_screen.dart';
// import 'attendance_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../widgets/background_wrapper.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/glass_container.dart';
import 'dart:async';

class ParentMainScreen extends StatefulWidget {
  final String orgId;
  const ParentMainScreen({super.key, required this.orgId});

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int index = 0;
  late final List<Widget> pages;
  StreamSubscription? _studentSubscription;
  bool _isUpdateDialogShowing = false;

  @override
  void initState() {
    super.initState();
    pages = [
      HomeScreen(orgId: widget.orgId),
      MapScreen(orgId: widget.orgId),
      // const AttendanceScreen(),
      NotificationsScreen(orgId: widget.orgId),
      const ProfileScreen(),
    ];
    _checkForUpdates();
  }

  void _checkForUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _studentSubscription = DatabaseService()
          .getStudent(widget.orgId, user.uid)
          .listen((student) {
            if (student != null && student.updateAvailable) {
              _showUpdateDialog(student.updateUrl);
            }
          });
    }
  }

  void _showUpdateDialog(String? url) {
    if (_isUpdateDialogShowing) return;
    _isUpdateDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.system_update,
                    size: 64,
                    color: AppColors.primaryAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Update Available",
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primaryAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "A new version of TrackGo is available. Please update to continue.",
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: url != null ? () => _launchURL(url) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text("Download Update"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch update link: $urlString')),
        );
      }
    }
  }

  @override
  void dispose() {
    _studentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: pages[index],
        extendBody: false, // Do not allow body to extend behind nav bar
        bottomNavigationBar: NavigationBar(
          // backgroundColor: handled by theme
          elevation: 0,
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          height: 80.h,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.map), label: "Track"),
            // NavigationDestination(
            //   icon: Icon(Icons.check_circle_outline),
            //   label: "Attendance",
            // ),
            NavigationDestination(
              icon: Icon(Icons.notifications),
              label: "Alerts",
            ),
            NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
