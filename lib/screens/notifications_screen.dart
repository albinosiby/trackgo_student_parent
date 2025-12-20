import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../models/student_model.dart';
import '../models/notification_model.dart';
import '../repositories/student_repository.dart';
import '../widgets/glass_container.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  final String orgId;
  const NotificationsScreen({
    super.key,
    required this.orgId,
  }); // Make orgId required

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  final StudentRepository _studentRepository =
      StudentRepository(); // Access to getNotificationsStream

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view notifications")),
      );
    }

    // 1. Fetch Student Model first to get studentId
    return StreamBuilder<StudentModel?>(
      stream: _dbService.getStudent(widget.orgId, user.uid),
      builder: (context, studentSnapshot) {
        if (studentSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (studentSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Notifications")),
            body: Center(child: Text("Error: ${studentSnapshot.error}")),
          );
        }

        if (!studentSnapshot.hasData || studentSnapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Notifications")),
            body: const Center(child: Text("Student profile not found")),
          );
        }

        final student = studentSnapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text("Alerts & Notifications")),
          // 2. Fetch Notifications using student.uid
          body: StreamBuilder<List<NotificationModel>>(
            stream: _studentRepository.getNotificationsStream(
              widget.orgId,
              student.uid,
            ),
            builder: (context, notifSnapshot) {
              if (notifSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (notifSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Error loading notifications: ${notifSnapshot.error}",
                  ),
                );
              }

              final notifications = notifSnapshot.data ?? [];

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64.r,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No notifications yet",
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(12.w),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return GlassContainer(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 0.w,
                      vertical: 8.h,
                    ), // Less padding for ListTile
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getIconColor(
                          n.type,
                        ).withOpacity(0.2), // softer bg
                        child: Icon(
                          _getIcon(n.type),
                          color: _getIconColor(n.type),
                        ),
                      ),
                      title: Text(
                        n.title,
                        style: AppTextStyles.title.copyWith(fontSize: 16.sp),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          Text(n.body, style: AppTextStyles.bodySmall),
                          SizedBox(height: 4.h),
                          Text(
                            _formatDate(n.timestamp),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'bus_assignment':
        return Icons.directions_bus;
      case 'entry_exit':
        return Icons.verified_user;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'bus_assignment':
        return AppColors.primaryAccent; // Electric Cyan
      case 'entry_exit':
        return AppColors.success; // Mint Green
      default:
        return Colors.white;
    }
  }

  String _formatDate(DateTime dt) {
    // Simple helper if intl is not preferred, or assume standard usage
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
