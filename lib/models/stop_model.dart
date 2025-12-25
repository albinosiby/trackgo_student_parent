class StopModel {
  final String id;
  final String name;
  final double lat;
  final double long;

  StopModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
  });

  factory StopModel.fromMap(Map<String, dynamic> data, String id) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return StopModel(
      id: id,
      name: data['stop_name'] ?? 'Unknown Stop',
      lat: parseDouble(data['lat']),
      long: parseDouble(data['long']),
    );
  }
}
