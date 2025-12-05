import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimeZoneHelper {
  static Future<void> initializeTimeZones() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
  }

  static tz.TZDateTime convertToTZ(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
