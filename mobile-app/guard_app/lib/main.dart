import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'core/services/camera_service.dart';
import 'features/login_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cameras
  try {
    cameras = await availableCameras();
    await CameraService().initializeCameras();
  } catch (e) {
    print('Error initializing cameras: $e');
    cameras = [];
  }
  
  runApp(const SecurityGuardApp());
}

class SecurityGuardApp extends StatelessWidget {
  const SecurityGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security Guard Mobile App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}
