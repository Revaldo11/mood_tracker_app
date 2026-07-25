import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data/sources/local_database.dart';
import 'presentation/controllers/mood_controller.dart';
import 'presentation/screens/splash_screen.dart';

/// Application entry point.
///
/// Initializes Flutter binding, opens the local database, registers
/// dependencies in GetX, and starts the app widget tree.
///
/// Side effects:
/// - Initializes Hive local storage.
/// - Opens local box storage.
/// - Registers singleton instances in GetX service locator.
///
/// Throws:
/// - Any exception from local database initialization (for example I/O errors)
///   will propagate and prevent app startup.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await LocalDatabase.init();
  Get.put(database);
  Get.put(MoodController(database));
  runApp(const MoodTrackerApp());
}

/// Root widget for Mood Tracker application.
class MoodTrackerApp extends StatelessWidget {
  /// Creates the application root widget.
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mood Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6BCB77),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
