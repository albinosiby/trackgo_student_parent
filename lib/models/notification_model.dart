import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'bus_assignment', 'entry_exit'
  final DateTime timestamp;
  final bool read;
  final String? busId;
  final String? scanType;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.read = false,
    this.busId,
    this.scanType,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? 'Notification',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
      busId:
          data['bus_id'] ?? data['busId'], // Handled both casing from functions
      scanType: data['scan_type'],
    );
  }
}
