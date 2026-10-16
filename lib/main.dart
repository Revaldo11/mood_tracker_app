import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data/sources/local_database.dart';
import 'data/sources/google_drive_backup_service.dart';
import 'presentation/controllers/backup_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/mood_controller.dart';
import 'presentation/screens/splash_screen.dart';
import 'constant/app_colors.dart';

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
  Get.put(AuthController(database));
  final moodController = Get.put(MoodController(database));
  final driveService = Get.put(GoogleDriveBackupService());
  Get.put(BackupController(database, driveService, moodController));
  runApp(const MoodTrackerApp());
}

/// Root widget for Mood Tracker application.
class MoodTrackerApp extends StatelessWidget {
  /// Creates the application root widget.
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LUMINA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.accent,
          onPrimary: Colors.white,
          surface: AppColors.paper,
          onSurface: AppColors.ink,
          outline: AppColors.line,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.paper,
        dividerColor: AppColors.line,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.ink),
          bodyMedium: TextStyle(color: AppColors.ink),
          bodySmall: TextStyle(color: AppColors.inkSoft),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.accent,
          onPrimary: Colors.white,
          surface: AppColors.night,
          onSurface: AppColors.mist,
          outline: AppColors.lineDark,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.night,
        dividerColor: AppColors.lineDark,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.mist),
          bodyMedium: TextStyle(color: AppColors.mist),
          bodySmall: TextStyle(color: AppColors.mist),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
