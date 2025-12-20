class BusModel {
  final String id;
  final String busNumber;
  final String tripStatus;
  final String? driverId;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.tripStatus,
    this.driverId,
  });

  factory BusModel.fromMap(Map<String, dynamic> data, String id) {
    return BusModel(
      id: id,
      busNumber: data['bus_number'] ?? 'N/A',
      tripStatus: data['trip_status'] ?? 'N/A',
      driverId: data['driver_id'],
    );
  }
}
