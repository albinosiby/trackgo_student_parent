import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'attendance_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class ParentMainScreen extends StatefulWidget {
  final String orgId;
  const ParentMainScreen({super.key, required this.orgId});

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int index = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomeScreen(orgId: widget.orgId),
      const MapScreen(),
      const AttendanceScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        height: 80.h,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.map), label: "Track"),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: "Attendance",
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: "Alerts",
          ),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
