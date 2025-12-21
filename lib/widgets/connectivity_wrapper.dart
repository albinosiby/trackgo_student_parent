import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_container.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  StreamSubscription? _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
    _subscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  Future<void> _checkInitialStatus() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _handleConnectivityChange(results);
    } on PlatformException catch (_) {
      // Handle error
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOffline = results.contains(ConnectivityResult.none);

    // Only update if state changes to avoid unnecessary rebuilds
    if (_isOffline != isOffline) {
      if (mounted) {
        setState(() {
          _isOffline = isOffline;
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          Scaffold(
            backgroundColor: Colors.black.withOpacity(0.6),
            body: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassContainer(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No Internet Connection",
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Please turn on mobile data or Wi-Fi to continue using the app.",
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      const CircularProgressIndicator(color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        "Waiting for network...",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
