import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization_model.dart';

class OrganizationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<OrganizationModel>> getOrganizations() async {
    final snapshot = await _firestore.collection('organizations').get();
    return snapshot.docs
        .map((doc) => OrganizationModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
