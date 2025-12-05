import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCrops {
  static const String cropsKey = "local_crops";
  static const String pestsKey = "local_pests";
  static const String diseasesKey = "local_diseases";
  static const String weedsKey = "local_weeds";

  // =====================================================
  //   CULTIVOS
  // =====================================================

  static Future<void> saveCrop(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(cropsKey);

    Map<String, dynamic> all =
        stored != null ? json.decode(stored) : {};

    all[id] = data;

    await prefs.setString(cropsKey, json.encode(all));
  }

  static Future<Map<String, dynamic>?> getCrop(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(cropsKey);
    if (stored == null) return null;

    final all = json.decode(stored);
    return all[id];
  }

  static Future<Map<String, dynamic>> getAllCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(cropsKey);
    if (stored == null) return {};

    return json.decode(stored);
  }

  static Future<void> deleteCrop(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(cropsKey);
    if (stored == null) return;

    final all = json.decode(stored);
    all.remove(id);

    await prefs.setString(cropsKey, json.encode(all));
  }

  // =====================================================
  //   GUARDAR / OBTENER — PLAGAS, ENFERMEDADES, MALEZAS
  // =====================================================

  static Future<void> savePest(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(pestsKey);

    Map<String, dynamic> all =
        stored != null ? json.decode(stored) : {};

    all[id] = data;

    await prefs.setString(pestsKey, json.encode(all));
  }

  static Future<Map<String, dynamic>?> getPest(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(pestsKey);
    if (stored == null) return null;

    final all = json.decode(stored);
    return all[id];
  }

  static Future<List<Map<String, dynamic>>> getAllPests() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(pestsKey);
    if (stored == null) return [];

    final all = json.decode(stored);
    return all.entries
        .map<Map<String, dynamic>>((e) => {"id": e.key, ...e.value})
        .toList();
  }

  static Future<void> saveDisease(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(diseasesKey);

    Map<String, dynamic> all =
        stored != null ? json.decode(stored) : {};

    all[id] = data;

    await prefs.setString(diseasesKey, json.encode(all));
  }

  static Future<Map<String, dynamic>?> getDisease(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(diseasesKey);
    if (stored == null) return null;

    final all = json.decode(stored);
    return all[id];
  }

  static Future<List<Map<String, dynamic>>> getAllDiseases() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(diseasesKey);
    if (stored == null) return [];

    final all = json.decode(stored);
    return all.entries
        .map<Map<String, dynamic>>((e) => {"id": e.key, ...e.value})
        .toList();
  }

  static Future<void> saveWeed(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(weedsKey);

    Map<String, dynamic> all =
        stored != null ? json.decode(stored) : {};

    all[id] = data;

    await prefs.setString(weedsKey, json.encode(all));
  }

  static Future<Map<String, dynamic>?> getWeed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(weedsKey);
    if (stored == null) return null;

    final all = json.decode(stored);
    return all[id];
  }

  static Future<List<Map<String, dynamic>>> getAllWeeds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(weedsKey);
    if (stored == null) return [];

    final all = json.decode(stored);
    return all.entries
        .map<Map<String, dynamic>>((e) => {"id": e.key, ...e.value})
        .toList();
  }

  // =====================================================
  //   OBTENER RELACIONADOS — FUNCIONA CON STRING O MAP
  // =====================================================

  static Future<List<Map<String, dynamic>>> getDiseasesForCrop(String cropId) async {
    final prefs = await SharedPreferences.getInstance();

    final cropsStr = prefs.getString(cropsKey);
    final diseasesStr = prefs.getString(diseasesKey);

    if (cropsStr == null || diseasesStr == null) return [];

    final crops = json.decode(cropsStr);
    final diseases = json.decode(diseasesStr);

    final crop = crops[cropId];
    if (crop == null) return [];

    final list = (crop["relatedDiseases"] ?? []) as List<dynamic>;

    return list.map<Map<String, dynamic>>((item) {
      if (item is String) {
        final entry = diseases.values.firstWhere(
          (e) => (e["name"] ?? "").toString().toLowerCase() == item.toLowerCase(),
          orElse: () => null,
        );

        if (entry != null) {
          final id = diseases.entries.firstWhere((e) => e.value == entry).key;
          return {"id": id, ...entry};
        }
      }

      if (item is Map && item["id"] != null) {
        final id = item["id"];
        final entry = diseases[id];
        if (entry != null) return {"id": id, ...entry};
      }

      return {};
    }).where((m) => m.isNotEmpty).toList();
  }

  static Future<List<Map<String, dynamic>>> getPestsForCrop(String cropId) async {
    final prefs = await SharedPreferences.getInstance();

    final cropsStr = prefs.getString(cropsKey);
    final pestsStr = prefs.getString(pestsKey);

    if (cropsStr == null || pestsStr == null) return [];

    final crops = json.decode(cropsStr);
    final pests = json.decode(pestsStr);

    final crop = crops[cropId];
    if (crop == null) return [];

    final list = (crop["relatedPests"] ?? []) as List<dynamic>;

    return list.map<Map<String, dynamic>>((item) {
      if (item is String) {
        final entry = pests.values.firstWhere(
          (e) => (e["name"] ?? "").toString().toLowerCase() == item.toLowerCase(),
          orElse: () => null,
        );

        if (entry != null) {
          final id = pests.entries.firstWhere((e) => e.value == entry).key;
          return {"id": id, ...entry};
        }
      }

      if (item is Map && item["id"] != null) {
        final id = item["id"];
        final entry = pests[id];
        if (entry != null) return {"id": id, ...entry};
      }

      return {};
    }).where((m) => m.isNotEmpty).toList();
  }

  static Future<List<Map<String, dynamic>>> getWeedsForCrop(String cropId) async {
    final prefs = await SharedPreferences.getInstance();

    final cropsStr = prefs.getString(cropsKey);
    final weedsStr = prefs.getString(weedsKey);

    if (cropsStr == null || weedsStr == null) return [];

    final crops = json.decode(cropsStr);
    final weeds = json.decode(weedsStr);

    final crop = crops[cropId];
    if (crop == null) return [];

    final list = (crop["relatedWeeds"] ?? []) as List<dynamic>;

    return list.map<Map<String, dynamic>>((item) {
      if (item is String) {
        final entry = weeds.values.firstWhere(
          (e) => (e["name"] ?? "").toString().toLowerCase() == item.toLowerCase(),
          orElse: () => null,
        );

        if (entry != null) {
          final id = weeds.entries.firstWhere((e) => e.value == entry).key;
          return {"id": id, ...entry};
        }
      }

      if (item is Map && item["id"] != null) {
        final id = item["id"];
        final entry = weeds[id];
        if (entry != null) return {"id": id, ...entry};
      }

      return {};
    }).where((m) => m.isNotEmpty).toList();
  }
}
