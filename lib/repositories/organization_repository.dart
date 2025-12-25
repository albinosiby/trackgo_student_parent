import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization_model.dart';
import '../models/stop_model.dart';

class OrganizationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<OrganizationModel>> getOrganizations() async {
    final snapshot = await _firestore.collection('organizations').get();
    return snapshot.docs
        .map((doc) => OrganizationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<StopModel?> getStop(String orgId, String stopId) async {
    try {
      final doc = await _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('stops')
          .doc(stopId)
          .get();

      if (doc.exists && doc.data() != null) {
        return StopModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching stop: $e");
      return null;
    }
  }

  Future<StopModel?> getStopByName(String orgId, String stopName) async {
    try {
      final snapshot = await _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('stops')
          .where('stop_name', isEqualTo: stopName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return StopModel.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print("Error fetching stop by name: $e");
      return null;
    }
  }

  Future<StopModel?> findStopByStudent(String orgId, String studentUid) async {
    try {
      final snapshot = await _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('stops')
          .where('assigned_students', arrayContains: studentUid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return StopModel.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print("Error finding stop by student: $e");
      return null;
    }
  }
}
