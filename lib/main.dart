import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    print("Kamera tidak terdeteksi: \$e");
  }
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  try {
    await FirebaseMessaging.instance.requestPermission();
    await NotificationService.init();

    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM TOKEN: $token");
  } catch (e) {
    print("FCM or Notification init failed (expected on Web without vapid): $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardController()),
      ],
      child: const SmartAttendanceApp(),
    ),
  );
}

class SmartAttendanceApp extends StatelessWidget {
  const SmartAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: const LoginScreen(), 
        ),
      ),
    );
  }
}