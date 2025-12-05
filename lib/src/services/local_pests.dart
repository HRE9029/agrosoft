import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPests {
  static const String storageKey = "local_pests";

  // Guardar una plaga
  static Future<void> savePest(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);

    Map<String, dynamic> all = stored != null ? json.decode(stored) : {};
    all[id] = data;

    await prefs.setString(storageKey, json.encode(all));
  }

  // Obtener una plaga
  static Future<Map<String, dynamic>?> getPest(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);
    if (stored == null) return null;

    final all = json.decode(stored) as Map<String, dynamic>;
    return all[id];
  }

  // Obtener todas las plagas
  static Future<List<Map<String, dynamic>>> getAllPests() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);
    if (stored == null) return [];

    final all = json.decode(stored) as Map<String, dynamic>;
    return all.values.map((e) => e as Map<String, dynamic>).toList();
  }
}
