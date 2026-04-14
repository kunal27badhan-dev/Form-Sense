import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_page.dart';
import 'screens/camera_screen.dart';
import 'screens/running_dashboard.dart';
import 'screens/meals_dashboard.dart';
import 'screens/progress_dashboard.dart';
import 'screens/programs_dashboard.dart';
import 'screens/ml_modules/meal_page.dart';
import 'screens/ml_modules/workout_page.dart';
import 'screens/ml_modules/weight_page.dart';
import 'screens/ml_modules/fitness_page.dart';

// ✅ Global camera list
late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide system navigation bar
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top], // Keep status bar, hide nav bar
  );

  // ✅ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Initialize Cameras
  cameras = await availableCameras();

  runApp(const FormSenseApp());
}

class FormSenseApp extends StatelessWidget {
  const FormSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),

      // Entry point
      home: const SplashScreen(),

      // Navigation routes
      routes: {
        '/home': (context) => const HomePage(),
        '/camera': (context) => CameraScreen(camera: cameras[0]),
        '/running': (context) => const RunningDashboard(),
        '/meals': (context) => const MealsDashboard(),
        '/progress': (context) => const ProgressDashboard(),
        '/programs': (context) => const ProgramsDashboard(),
        MealPage.routeName: (context) => const MealPage(),
        WorkoutPage.routeName: (context) => const WorkoutPage(),
        WeightPage.routeName: (context) => const WeightPage(),
        FitnessPage.routeName: (context) => const FitnessPage(),
      },
    );
  }
}
