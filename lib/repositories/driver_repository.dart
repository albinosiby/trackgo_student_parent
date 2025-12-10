import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';

class DriverRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DriverModel?> getDriverByBus(String orgId, String busId) async {
    try {
      // 1. Get Bus Document to find driver_id
      final busDoc = await _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('buses')
          .doc(busId)
          .get();

      if (!busDoc.exists || busDoc.data() == null) {
        return null;
      }

      final driverId = busDoc.data()!['driver_id'];

      if (driverId == null || driverId is! String || driverId.isEmpty) {
        return null;
      }

      // 2. Get Driver Document
      final driverDoc = await _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('drivers')
          .doc(driverId)
          .get();

      if (driverDoc.exists && driverDoc.data() != null) {
        return DriverModel.fromMap(driverDoc.data()!, driverDoc.id);
      }
      return null;
    } catch (e) {
      // Handle or log error
      return null;
    }
  }

  // If we wanted a stream for the driver (e.g. for live updates), we could add it here
}
