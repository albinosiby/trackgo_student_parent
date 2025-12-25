import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../models/payment_model.dart';
import '../models/student_model.dart';
import '../models/notification_model.dart';

class StudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<StudentModel?> getStudentStream(String orgId, String uid) {
    return _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('students')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return StudentModel.fromMap(snapshot.data()!, snapshot.id);
          }
          return null;
        });
  }

  Future<List<PaymentModel>> getPayments(
    String orgId,
    String studentUid,
  ) async {
    final snapshot = await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('students')
        .doc(studentUid)
        .collection('payments')
        .get();

    return snapshot.docs
        .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<AttendanceModel>> getAttendance(
    String orgId,
    String studentUid,
  ) async {
    final snapshot = await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('students')
        .doc(studentUid)
        .collection('attendance')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateFcmToken(
    String orgId,
    String studentId,
    String token,
  ) async {
    await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('students')
        .doc(studentId)
        .update({'fcmToken': token});
  }

  Stream<List<NotificationModel>> getNotificationsStream(
    String orgId,
    String studentId,
  ) {
    return _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('students')
        .doc(studentId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> clearNotifications(String orgId, String studentId) async {
    final collection = _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('students')
        .doc(studentId)
        .collection('notifications');

    final snapshot = await collection.get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
