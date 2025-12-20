import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/background_wrapper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Coordinates for Kochi, Kerala (example location)
  final LatLng _busLocation = const LatLng(9.9312, 76.2673);

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Live Bus Location")),
        body: FlutterMap(
          options: MapOptions(initialCenter: _busLocation, initialZoom: 15.0),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.trackgo_student_parent',
              // Note: For a true dark map, we'd need a dark tile provider (e.g. Mapbox, CartoDB).
              // Standard OSM is light. We will keep it light for readability or can use a ColorFilter to invert it (hacky).
              // Let's keep it standard for reliability.
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _busLocation,
                  width: 80.w,
                  height: 80.h,
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_bus,
                        color: Colors.indigo,
                        size: 40.r,
                      ),
                      Text(
                        "Bus",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
