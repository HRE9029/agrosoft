import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _notifier =
      FlutterLocalNotificationsPlugin();

  // =========================================================
  //                 INICIALIZAR NOTIFICACIONES
  // =========================================================
  static Future<void> init() async {
    tz.initializeTimeZones(); // Timezones necesarios

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifier.initialize(settings);

    // Pedir permisos Android 13+
    final androidPlugin = _notifier
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  // =========================================================
  //               NOTIFICACIÓN INSTANTÁNEA
  // =========================================================
  static Future<void> showInstantNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Notificaciones inmediatas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifier.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // =========================================================
  //                 NOTIFICACIÓN PROGRAMADA
  // =========================================================
  static Future<void> scheduleNotification(
    DateTime date,
    String title,
    String body,
  ) async {
    final tzDate = tz.TZDateTime.from(date, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Notificaciones programadas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifier.zonedSchedule(
      tzDate.millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  // =========================================================
  //      ATAJOS PERSONALIZADOS PARA AGROSOFT 🌱
  // =========================================================

  /// Programar notificación de riego
  static Future<void> scheduleIrrigation(DateTime date, String cropName) async {
    await scheduleNotification(
      date,
      "Riego pendiente",
      "Es momento de regar tu cultivo de $cropName.",
    );
  }

  /// Programar notificación de cosecha
  static Future<void> scheduleHarvest(DateTime date, String cropName) async {
    await scheduleNotification(
      date,
      "Cosecha cercana",
      "Tu cultivo de $cropName está próximo a cosechar.",
    );
  }
}
