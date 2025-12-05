// 💛 PlaguesPage CORREGIDA FINAL DEFINITIVA
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class PlaguesPage extends StatefulWidget {
  const PlaguesPage({super.key});

  @override
  State<PlaguesPage> createState() => _PlaguesPageState();
}

class _PlaguesPageState extends State<PlaguesPage> {
  bool online = true;
  String search = "";

  List<Map<String, dynamic>> firebaseItems = [];

  @override
  void initState() {
    super.initState();
    checkConnection();
    loadFirebaseData();
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup("google.com")
          .timeout(const Duration(seconds: 2));
      online = result.isNotEmpty;
    } catch (_) {
      online = false;
    }
    setState(() {});
  }

  Future<void> loadFirebaseData() async {
    List<Map<String, dynamic>> items = [];

    String safeLetter(String name) {
      if (name.isEmpty) return "#";
      return name.substring(0, 1).toUpperCase();
    }

    // ------------ PESTS ------------
    try {
      final snap = await FirebaseFirestore.instance.collection("pests").get();
      for (var d in snap.docs) {
        final name = d["name"] ?? "";
        items.add({
          "id": d.id,
          "name": name,
          "letter": safeLetter(name),
          "collection": "pests",
        });
      }
    } catch (_) {}

    // ------------ DISEASES ------------
    try {
      final snap = await FirebaseFirestore.instance.collection("diseases").get();
      for (var d in snap.docs) {
        final name = d["name"] ?? "";
        items.add({
          "id": d.id,
          "name": name,
          "letter": safeLetter(name),
          "collection": "diseases",
        });
      }
    } catch (_) {}

    // ------------ WEEDS ------------
    try {
      final snap = await FirebaseFirestore.instance.collection("weeds").get();
      for (var d in snap.docs) {
        final name = d["name"] ?? "";
        items.add({
          "id": d.id,
          "name": name,
          "letter": safeLetter(name),
          "collection": "weeds",
        });
      }
    } catch (_) {}

    // ------------ CROPS ------------
    try {
      final snap = await FirebaseFirestore.instance.collection("crops").get();
      for (var d in snap.docs) {
        final name = d["name"] ?? "";
        items.add({
          "id": d.id,
          "name": name,
          "letter": safeLetter(name),
          "collection": "crops",
        });
      }
    } catch (_) {}

    firebaseItems = items;
    setState(() {});
  }

  List<Map<String, dynamic>> get filtered {
    return firebaseItems
        .where((p) => p["name"].toLowerCase().contains(search.toLowerCase()))
        .toList()
      ..sort((a, b) => a["name"].compareTo(b["name"]));
  }

  Map<String, List<Map<String, dynamic>>> get groupedAZ {
    final map = <String, List<Map<String, dynamic>>>{};
    for (var item in filtered) {
      final letter = item["letter"];
      map.putIfAbsent(letter, () => []);
      map[letter]!.add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    const double headerH = 110;
    const double maxW = 520;

    final grouped = groupedAZ;
    final letters = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: headerH,
              color: AppColors.headerFooter,
              alignment: Alignment.center,
              child: SizedBox(
                height: 70,
                child: Image.asset("assets/images/agrosoft_logo.png"),
              ),
            ),

            // BUSCADOR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxW),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black87),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => search = v),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Estoy buscando...",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // LISTA A–Z
            Expanded(
              child: firebaseItems.isEmpty
                  ? const Center(child: Text("Cargando o vacío..."))
                  : ListView.builder(
                      itemCount: letters.length,
                      padding: const EdgeInsets.only(bottom: 50),
                      itemBuilder: (_, i) {
                        final letter = letters[i];
                        final groupItems = grouped[letter]!;

                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: maxW),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),

                                ...groupItems.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                                    child: _YellowCard(
                                      title: item["name"],
                                      onTap: () {
                                        context.push("/details/firebase/${item["collection"]}/${item["name"]}");

                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YellowCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _YellowCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldFill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
