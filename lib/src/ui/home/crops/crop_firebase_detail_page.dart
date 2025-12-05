import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';

class FirebaseDetailPage extends StatefulWidget {
  final String collection;
  final String name;

  const FirebaseDetailPage({
    super.key,
    required this.collection,
    required this.name,
  });

  @override
  State<FirebaseDetailPage> createState() => _FirebaseDetailPageState();
}

class _FirebaseDetailPageState extends State<FirebaseDetailPage> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(widget.collection)
          .where("name", isEqualTo: widget.name)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        data = snap.docs.first.data();
      }
    } catch (e) {
      debugPrint("ERROR FIREBASE → $e");
    }

    setState(() => loading = false);
  }

  Widget sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      );

  Widget textField(String title, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title),
        Text(value.toString(), style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget listField(String title, List? arr) {
    if (arr == null || arr.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title),
        ...arr.map((e) => Text("• $e", style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget mapListField(String title, Map? map) {
    if (map == null || map.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title),
        ...map.entries.map((entry) {
          final key = entry.key;
          final val = entry.value;

          if (val == null || val is! List || val.isEmpty) {
            return const SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "➡ $key:",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              ...val.map((e) =>
                  Text("   • $e", style: const TextStyle(fontSize: 16))),
              const SizedBox(height: 10),
            ],
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("Registro no encontrado")),
      );
    }

    final img = data!["imageUrl"] ?? "";
    final name = data!["name"] ?? "";
    final sci = data!["scientificName"] ?? "";
    final type = data!["type"] ?? widget.collection;

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
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black87),
                  ),
                  const Spacer(),
                  Text(
                    type.toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // BODY
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
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 20),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (sci.isNotEmpty)
                      Text(
                        sci,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    textField("Descripción", data!["description"]),
                    textField("Familia", data!["family"]),
                    textField("Origen", data!["origin"]),
                    textField("Ciclo", data!["cycle"]),

                    listField("Síntomas", data!["symptoms"]),
                    listField("Daños", data!["damage"]),
                    listField("Cultivos relacionados", data!["relatedCrops"]),

                    mapListField("Control", data!["control"]),

                    if (widget.collection == "crops") ...[
                      mapListField("Suelo", data!["soil"]),
                      mapListField("Siembra", data!["sowing"]),
                      mapListField("Riego", data!["irrigation"]),
                      mapListField("Nutrición", data!["nutrition"]),
                      listField("Usos", data!["uses"]),
                      mapListField("Temperatura", data!["temperature"]),
                      mapListField("Cosecha", data!["harvest"]),
                      listField("Plagas relacionadas", data!["relatedPests"]),
                      listField("Enfermedades relacionadas", data!["relatedDiseases"]),
                      listField("Malezas relacionadas", data!["relatedWeeds"]),
                    ],
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
