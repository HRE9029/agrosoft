import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDiseases {
  static const String storageKey = "local_diseases";

  // Guardar enfermedad
  static Future<void> saveDisease(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);

    Map<String, dynamic> all = stored != null ? json.decode(stored) : {};
    all[id] = data;

    await prefs.setString(storageKey, json.encode(all));
  }

  // Obtener una enfermedad
  static Future<Map<String, dynamic>?> getDisease(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);
    if (stored == null) return null;

    final all = json.decode(stored) as Map<String, dynamic>;
    return all[id];
  }

  // Obtener todas las enfermedades
  static Future<List<Map<String, dynamic>>> getAllDiseases() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);
    if (stored == null) return [];

    final all = json.decode(stored) as Map<String, dynamic>;
    return all.values.map((e) => e as Map<String, dynamic>).toList();
  }
}
