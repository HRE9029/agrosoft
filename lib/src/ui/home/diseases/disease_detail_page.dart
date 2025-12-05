import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/local_diseases.dart';
import '../../../theme.dart';

class DiseaseDetailPage extends StatefulWidget {
  final String diseaseId;

  const DiseaseDetailPage({super.key, required this.diseaseId});

  @override
  State<DiseaseDetailPage> createState() => _DiseaseDetailPageState();
}

class _DiseaseDetailPageState extends State<DiseaseDetailPage> {
  Map<String, dynamic>? disease;

  @override
  void initState() {
    super.initState();
    loadDisease();
  }

  Future<void> loadDisease() async {
    disease = await LocalDiseases.getDisease(widget.diseaseId);
    setState(() {});
  }

  // -----------------------------
  // SECCIÓN PARA TEXTO SIMPLE
  // -----------------------------
  Widget textSection(String title, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, height: 1.35),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // -----------------------------
  // SECCIÓN PARA LISTAS (•)
  // -----------------------------
  Widget listSection(String title, dynamic rawList) {
    if (rawList == null) return const SizedBox();

    List list;

    if (rawList is List) {
      list = rawList;
    } else if (rawList is String) {
      list = [rawList];
    } else {
      return const SizedBox();
    }

    if (list.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...list.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("• $e",
                style: const TextStyle(fontSize: 16, height: 1.25)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (disease == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ---------------- DATOS ----------------
    final name = disease!["name"] ?? "";
    final sci = disease!["scientificName"] ?? "";
    final img = disease!["imageUrl"] ?? "";

    final desc = disease!["description"];
    final symptoms = disease!["symptoms"];
    final damage = disease!["damage"];

    final control = disease!["control"] ?? {};
    final cultural = control["cultural"];
    final biologico = control["biologico"];
    final quimico = control["quimico"];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ----------------- HEADER -----------------
            Container(
              height: 110,
              width: double.infinity,
              color: AppColors.headerFooter,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  const Text(
                    "Enfermedad",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ------------------ BODY ---------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOMBRE
                    Text(name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),

                    if (sci.isNotEmpty)
                      Text(
                        sci,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // IMAGEN
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

                    // 🔥 SECCIONES COMPLETAS — MISMO ESTILO QUE LAS OTRAS FICHAS
                    textSection("Descripción", desc),
                    listSection("Síntomas", symptoms),
                    listSection("Daños", damage),

                    listSection("Control cultural", cultural),
                    listSection("Control biológico", biologico),
                    listSection("Control químico", quimico),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
