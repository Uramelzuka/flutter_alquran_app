import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmPermissions {
  static final _log = Logger('AlarmPermissions');

  static Future<void> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      _log.info('Notification permission denied');
      final res = await Permission.notification.request();
      _log.info('Notification permission result: ${res.isGranted}');
    }
  }

  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    _log.info('Schedule exact alarm permission status: $status');
    if (status.isDenied) {
      _log.info('Schedule exact alarm permission');
      final res = await Permission.scheduleExactAlarm.request();
      _log.info(
        'Schedule exact alarm permission result: ${res.isGranted ? '' : 'not'}',
      );
    }
  }
}
