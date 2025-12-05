import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // ===============================
  //     OPCIONES QUE QUEDAN
  // ===============================
  bool isLargeFont = false;

  bool notifRiego = true;
  bool notifCosecha = true;
  bool notifSound = true;

  bool loaded = false;

  // ===============================
  //        CARGAR AJUSTES
  // ===============================
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    isLargeFont = prefs.getBool("isLargeFont") ?? false;

    notifRiego = prefs.getBool("notifRiego") ?? true;
    notifCosecha = prefs.getBool("notifCosecha") ?? true;
    notifSound = prefs.getBool("notifSound") ?? true;

    loaded = true;
    notifyListeners();
  }

  // ===============================
  //     ACTUALIZAR AJUSTES
  // ===============================

  Future<void> updateFontSize(bool large) async {
    final prefs = await SharedPreferences.getInstance();
    isLargeFont = large;
    await prefs.setBool("isLargeFont", large);
    notifyListeners();
  }

  Future<void> updateNotifRiego(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    notifRiego = value;
    await prefs.setBool("notifRiego", value);
    notifyListeners();
  }

  Future<void> updateNotifCosecha(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    notifCosecha = value;
    await prefs.setBool("notifCosecha", value);
    notifyListeners();
  }

  Future<void> updateNotifSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    notifSound = value;
    await prefs.setBool("notifSound", value);
    notifyListeners();
  }
}
