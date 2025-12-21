import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/parent_main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Offline Persistence
  try {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    print("Persistence init error: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final String? orgId = prefs.getString('orgId');

  runApp(ParentApp(orgId: orgId));
}

class ParentApp extends StatelessWidget {
  final String? orgId;
  const ParentApp({super.key, this.orgId});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: "Parent App",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: FirebaseAuth.instance.currentUser != null && orgId != null
              ? ParentMainScreen(orgId: orgId!)
              : const LoginScreen(),
        );
      },
    );
  }
}
