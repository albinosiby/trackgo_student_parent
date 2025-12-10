import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {"title": "Bus Delay", "body": "Due to traffic, bus is 10 min late"},
      {
        "title": "Holiday Reminder",
        "body": "School will remain closed tomorrow",
      },
      {"title": "Route Updated", "body": "New pick-up time: 7:25 AM"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Alerts & Notifications")),
      body: ListView.separated(
        padding: EdgeInsets.all(12.w),
        itemCount: alerts.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final n = alerts[index];

          return Card(
            child: ListTile(
              title: Text(n["title"]!, style: TextStyle(fontSize: 16.sp)),
              subtitle: Text(n["body"]!, style: TextStyle(fontSize: 14.sp)),
              leading: Icon(Icons.notifications_active, size: 24.r),
            ),
          );
        },
      ),
    );
  }
}
