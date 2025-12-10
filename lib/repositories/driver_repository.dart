import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';

class DriverRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DriverModel?> getDriverByBus(String orgId, String busId) async {
    try {
      final querySnapshot = await _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('drivers')
          .where('assigned_bus', isEqualTo: busId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return DriverModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      // Handle or log error
      return null;
    }
  }

  // If we wanted a stream for the driver (e.g. for live updates), we could add it here
}
