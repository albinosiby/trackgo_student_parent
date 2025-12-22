import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/database_service.dart';
import '../widgets/background_wrapper.dart';
import '../theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  final String orgId;
  const MapScreen({super.key, required this.orgId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DatabaseService _dbService = DatabaseService();
  final MapController _mapController = MapController();

  LatLng? _busLocation;
  String? _busNumber;
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _locationSubscription;
  bool _isDisposed = false;

  // Track if map is ready to accept controller actions
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initLiveTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initLiveTracking() async {
    try {
      print("DEBUG: _initLiveTracking started");
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("DEBUG: User is null");
        if (!_isDisposed) setState(() => _error = "Not authenticated");
        return;
      }
      print("DEBUG: User found: ${user.uid}");

      // 1. Get Student Details to find Bus ID
      final studentStream = _dbService.getStudent(widget.orgId, user.uid);
      print("DEBUG: Fetching student stream...");
      final student = await studentStream.first;

      if (student == null) {
        if (!_isDisposed) setState(() => _error = "Student profile not found.");
        return;
      }

      print(
        "DEBUG: Student data fetched: ${student.fullName}, BusID: ${student.busId}, CanTravel: ${student.canTravel}",
      );

      // 2. Check Permission (canTravel)
      if (!student.canTravel) {
        print("DEBUG: canTravel is false");
        if (!_isDisposed)
          setState(() {
            _isLoading = false;
            _error =
                "Service Suspended.\nPlease pay fees to unlock live tracking.";
          });
        return;
      }

      // 3. Get Bus Details
      if (student.busId == null || student.busId!.isEmpty) {
        print("DEBUG: No bus assigned");
        if (!_isDisposed)
          setState(() {
            _isLoading = false;
            _error = "No bus assigned to this profile.";
          });
        return;
      }

      final busId = student.busId!;
      print(
        "DEBUG: Subscribing to RTDB: organizations/${widget.orgId}/bus_location/$busId",
      );

      // 2. Subscribe to Realtime Database
      final ref = FirebaseDatabase.instance.ref(
        'organizations/${widget.orgId}/bus_location/$busId',
      );

      // Initial Check
      try {
        final snapshot = await ref.get();
        print(
          "DEBUG: Initial .get() completed. Exists: ${snapshot.exists}, Value: ${snapshot.value}",
        );
        if (snapshot.exists && snapshot.value != null) {
          final data = snapshot.value as Map;
          _updateLocationFromData(data);
        } else {
          print("DEBUG: Initial get was empty");
          if (!_isDisposed)
            setState(() {
              _isLoading = false;
              _error = "Waiting for bus to start...";
            });
        }
      } catch (e) {
        print("DEBUG: Initial .get() failed: $e");
      }

      _locationSubscription = ref.onValue.listen(
        (event) {
          print("DEBUG: RTDB Event received");
          if (_isDisposed) return;

          final data = event.snapshot.value as Map?;
          print("DEBUG: RTDB Data: $data");
          if (data != null) {
            _updateLocationFromData(data);
          } else {
            if (!_isDisposed) {
              setState(() {
                _isLoading = false;
                _error = "No location data found for this bus.";
              });
            }
          }
        },
        onError: (e) {
          print("DEBUG: RTDB Listen Error: $e");
          if (!_isDisposed) setState(() => _error = "Tracking error: $e");
        },
      );
    } catch (e) {
      if (!_isDisposed)
        setState(() {
          _isLoading = false;
          _error = "Error initializing map: $e";
        });
    }
  }

  void _updateLocationFromData(Map data) {
    try {
      double parseCoord(dynamic value) {
        if (value == null) return 0.0;
        if (value is num) return value.toDouble();
        String s = value.toString().trim();

        bool isNegative =
            s.toUpperCase().contains('S') || s.toUpperCase().contains('W');
        String cleaned = s.replaceAll(RegExp(r'[^0-9.]'), '');
        double? val = double.tryParse(cleaned);
        if (val != null && isNegative) val = -val;

        return val ?? 0.0;
      }

      final lat = parseCoord(data['latitude']);
      final lng = parseCoord(data['longitude']);
      final busNum = data['bus_number']?.toString();

      setState(() {
        _busLocation = (lat != 0.0 && lng != 0.0) ? LatLng(lat, lng) : null;
        _busNumber = busNum;
        _isLoading = false;
        if (lat == 0.0 && lng == 0.0) {
          _error = "Bus location not yet available (0,0)";
        } else {
          _error = null;
          // Only move map if controller is ready
          if (_busLocation != null && _isMapReady) {
            _mapController.move(_busLocation!, 15);
          }
        }
      });
    } catch (e) {
      print("DEBUG: Error parsing location data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Live Bus Location")),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _busLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 48.r, color: Colors.white54),
            SizedBox(height: 16.h),
            Text(_error!, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    final center = _busLocation ?? const LatLng(0, 0);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15.0,
        onMapReady: () {
          _isMapReady = true;
          // If we already have a location but weren't ready before, move now
          if (_busLocation != null) {
            _mapController.move(_busLocation!, 15);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.trackgo_student_parent',
        ),
        MarkerLayer(
          markers: [
            if (_busLocation != null)
              Marker(
                point: _busLocation!,
                width: 100.w,
                height: 100.h,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryAccent.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.directions_bus_filled,
                        color: Colors.black,
                        size: 30.r,
                      ),
                    ),
                    if (_busNumber != null) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _busNumber!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryAccent,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
