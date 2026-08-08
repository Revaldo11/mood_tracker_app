import 'package:workmanager/workmanager.dart';

import '../data/sources/local_database.dart';
import '../domain/repositories/notification_repository.dart';
import '../services/notification_service.dart';
import '../services/workmanager_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != WorkManagerService.taskName) {
      return true;
    }
    try {
      final database = await LocalDatabase.init();
      final repository = NotificationRepository(database);
      await NotificationService.instance.initNotifications();
      await NotificationService.instance.showMoodReminder(repository);
      return true;
    } catch (_) {
      return false;
    }
  });
}
