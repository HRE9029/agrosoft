import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalMyCrops {
  static const String _storageKey = "my_crops";

  /// Guarda un cultivo personal
  static Future<void> saveMyCrop(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> crops = await getAllMyCrops();
    crops[id] = data;

    prefs.setString(_storageKey, jsonEncode(crops));
  }

  /// Obtiene un cultivo específico
  static Future<Map<String, dynamic>?> getMyCrop(String id) async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_storageKey)) return null;

    final jsonData = prefs.getString(_storageKey)!;
    final crops = jsonDecode(jsonData);

    return crops[id];
  }

  /// Obtiene TODOS los cultivos (MAP)
  static Future<Map<String, dynamic>> getAllMyCrops() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_storageKey)) return {};

    final jsonData = prefs.getString(_storageKey)!;
    return Map<String, dynamic>.from(jsonDecode(jsonData));
  }

  /// Convierte el MAP a LISTA
  static Future<List<Map<String, dynamic>>> getAllMyCropsList() async {
    final crops = await getAllMyCrops();

    return crops.entries.map((e) {
      final map = Map<String, dynamic>.from(e.value);
      map["id"] = e.key;
      return map;
    }).toList();
  }

  /// Elimina un cultivo
  static Future<void> deleteMyCrop(String id) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> crops = await getAllMyCrops();
    crops.remove(id);

    prefs.setString(_storageKey, jsonEncode(crops));
  }
}
