import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProfile {
  static const String _key = "user_profile";

  /// Guarda el perfil completo
  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile));
  }

  /// Obtiene el perfil (o null si no existe)
  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_key)) return null;

    final jsonStr = prefs.getString(_key)!;
    return Map<String, dynamic>.from(jsonDecode(jsonStr));
  }

  /// Limpia el perfil (por ejemplo al cerrar sesión)
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
