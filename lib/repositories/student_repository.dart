import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../models/student_model.dart';

class StudentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<StudentModel?> getStudentStream(String orgId, String parentUid) {
    return _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('students')
        .where('parent_uid', isEqualTo: parentUid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            return StudentModel.fromMap(doc.data(), doc.id);
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
}
