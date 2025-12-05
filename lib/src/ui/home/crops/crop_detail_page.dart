// 💚 details_crops_page.dart (BOTONES ABAJO)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';

class CropDetailPage extends StatefulWidget {
  final String id;

  const CropDetailPage({super.key, required this.id});

  @override
  State<CropDetailPage> createState() => _CropDetailPageState();
}

class _CropDetailPageState extends State<CropDetailPage> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection("crops")
        .doc(widget.id)
        .get();

    if (doc.exists) data = doc.data();

    setState(() => loading = false);
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _field(String title, dynamic value) {
    if (value == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(title),
        const SizedBox(height: 6),
        Text(value.toString(), style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _list(String title, dynamic rawList) {
    if (rawList == null) return const SizedBox();

    late List list;

    if (rawList is String) {
      list = [rawList];
    } else if (rawList is List) {
      list = rawList;
    } else {
      return const SizedBox();
    }

    if (list.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(title),
        const SizedBox(height: 6),
        ...list.map(
          (e) => Text("• $e", style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _mapSection(String title, Map? map) {
    if (map == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(title),
        const SizedBox(height: 6),
        ...map.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              "• ${entry.key}: ${entry.value}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _yellowButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFC8B400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (data == null) {
      return const Scaffold(body: Center(child: Text("Cultivo no encontrado")));
    }

    final img = data!["imageUrl"] ?? "";
    final name = data!["name"] ?? "";
    final sci = data!["scientificName"] ?? "";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.headerFooter,
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.black87),
                      onPressed: () => context.pop()),
                  const Spacer(),
                  const Text(
                    "CULTIVO",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (img.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          img,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),

                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),

                    if (sci.isNotEmpty)
                      Text(
                        sci,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),

                    // --- TODA LA INFORMACIÓN ---
                    _field("Familia", data!["family"]),
                    _field("Origen", data!["origin"]),
                    _field("Ciclo", data!["cycle"]),
                    _field("Descripción", data!["description"]),

                    _mapSection("Temperatura", data!["temperature"]),
                    _mapSection("Suelo", data!["soil"]),
                    _mapSection("Siembra", data!["sowing"]),
                    _mapSection("Riego", data!["irrigation"]),
                    _mapSection("Nutrición", data!["nutrition"]),
                    _mapSection("Cosecha", data!["harvest"]),

                    _list("Micronutrientes",
                        data!["nutrition"]?["micronutrients"]),
                    _list("Indicadores", data!["harvest"]?["indicators"]),
                    _list("Usos", data!["uses"]),

                    _list("Plagas asociadas", data!["relatedPests"]),
                    _list("Enfermedades asociadas", data!["relatedDiseases"]),
                    _list("Malezas asociadas", data!["relatedWeeds"]),

                    const SizedBox(height: 30),

                    _yellowButton(
                      "Enfermedades",
                      () => context.push('/diseases/${widget.id}', extra: name),
                    ),
                    _yellowButton(
                      "Malezas",
                      () => context.push('/weeds/${widget.id}', extra: name),
                    ),
                    _yellowButton(
                      "Plagas",
                      () => context.push('/pests/${widget.id}', extra: name),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
