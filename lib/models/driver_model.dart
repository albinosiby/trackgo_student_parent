class DriverModel {
  final String uid;
  final String phoneNumber;
  final String assignedBus;
  final String? profilePhotoUrl;
  final String name;

  DriverModel({
    required this.uid,
    required this.phoneNumber,
    required this.assignedBus,
    this.profilePhotoUrl,
    required this.name,
  });

  factory DriverModel.fromMap(Map<String, dynamic> data, String uid) {
    return DriverModel(
      uid: uid,
      phoneNumber: data['phone_number'] ?? '',
      assignedBus: data['assigned_bus'] ?? '',
      profilePhotoUrl: data['profile_photo_url'],
      name: data['name'] ?? 'Driver',
    );
  }
}
