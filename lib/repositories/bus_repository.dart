import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';

class BusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<BusModel?> getBusStream(String orgId, String busId) {
    return _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('buses')
        .doc(busId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return BusModel.fromMap(snapshot.data()!, snapshot.id);
          }
          return null;
        });
  }
}
