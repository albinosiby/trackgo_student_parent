class OrganizationModel {
  final String id;
  final String name;

  OrganizationModel({required this.id, required this.name});

  factory OrganizationModel.fromMap(Map<String, dynamic> data, String id) {
    return OrganizationModel(id: id, name: data['name'] ?? '');
  }
}
