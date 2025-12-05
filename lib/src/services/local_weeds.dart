import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalWeeds {
  static const String storageKey = "local_weeds";

  // Guardar maleza
  static Future<void> saveWeed(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);

    Map<String, dynamic> all = stored != null ? json.decode(stored) : {};
    all[id] = data;

    await prefs.setString(storageKey, json.encode(all));
  }

  // Obtener una maleza
  static Future<Map<String, dynamic>?> getWeed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);
    if (stored == null) return null;

    final all = json.decode(stored) as Map<String, dynamic>;
    return all[id];
  }

  // Obtener todas las malezas
  static Future<List<Map<String, dynamic>>> getAllWeeds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);
    if (stored == null) return [];

    final all = json.decode(stored) as Map<String, dynamic>;
    return all.values.map((e) => e as Map<String, dynamic>).toList();
  }
}
