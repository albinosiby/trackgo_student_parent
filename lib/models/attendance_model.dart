import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String date;
  final String status;
  final DateTime timestamp;

  AttendanceModel({
    required this.id,
    required this.date,
    required this.status,
    required this.timestamp,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> data, String id) {
    return AttendanceModel(
      id: id,
      date: data['date'] ?? '',
      status: data['status'] ?? 'Absent',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
