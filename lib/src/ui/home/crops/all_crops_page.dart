import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';

// 🟢 Importar servicios locales
import '../../../services/local_crops.dart';
import '../../../services/local_pests.dart';
import '../../../services/local_diseases.dart';
import '../../../services/local_weeds.dart';

class AllCropsPage extends StatelessWidget {
  const AllCropsPage({super.key});

  // ---------------------------------------------
  // ⭐ Normalizar listas (string → {id: string})
  // ---------------------------------------------
  List<Map<String, dynamic>> normalizeList(dynamic list) {
    if (list == null) return [];

    if (list is List) {
      return list.map<Map<String, dynamic>>((e) {
        if (e is String) return {"id": e};
        if (e is Map) {
          return {"id": e["id"] ?? e["name"] ?? e.toString()};
        }
        return {};
      }).where((m) => m.isNotEmpty).toList();
    }

    return [];
  }

  // ---------------------------------------------
  // ⭐ Descargar plagas, enfermedades, malezas
  // ---------------------------------------------
  Future<void> downloadRelatedData(Map crop, String cropId) async {

    // -------- PLAGAS --------
    try {
      final list = normalizeList(crop["relatedPests"]);
      for (var p in list) {
        final doc = await FirebaseFirestore.instance
            .collection("pests")
            .doc(p["id"])
            .get();
        if (doc.exists) {
          await LocalPests.savePest(doc.id, doc.data()!);
        }
      }
    } catch (e) {
  debugPrint("Error: $e");
}


    // -------- ENFERMEDADES --------
    try {
      final list = normalizeList(crop["relatedDiseases"]);
      for (var d in list) {
        final doc = await FirebaseFirestore.instance
            .collection("diseases")
            .doc(d["id"])
            .get();
        if (doc.exists) {
          await LocalDiseases.saveDisease(doc.id, doc.data()!);
        }
      }
    } catch (e) {
  debugPrint("Error: $e");
}


    // -------- MALEZAS --------
    try {
      final list = normalizeList(crop["relatedWeeds"]);
      for (var w in list) {
        final doc = await FirebaseFirestore.instance
            .collection("weeds")
            .doc(w["id"])
            .get();
        if (doc.exists) {
          await LocalWeeds.saveWeed(doc.id, doc.data()!);
        }
      }
    } catch (e) {
debugPrint("========== DESCARGA COMPLETA ==========");
    }

  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 110;
    const double maxWidth = 520;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Container(
              height: headerHeight,
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
                  SizedBox(
                    height: 60,
                    child: Image.asset('assets/images/agrosoft_logo.png'),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ---------------- LISTA ----------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('crops').snapshots(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxWidth),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (_, i) {
                          final crop = docs[i].data() as Map<String, dynamic>;
                          final id = docs[i].id;
                          final name = crop['name'] ?? 'Cultivo';
                          final imageUrl = crop['imageUrl'] ?? '';

                          return _CropCard(
                            name: name,
                            imageUrl: imageUrl,
                            onTap: () async {
                              // ⭐ Normalizar antes de guardar
                              final normalized = {
                                "id": id,
                                ...crop,
                                "imageUrl": imageUrl,
                                "relatedPests":
                                    normalizeList(crop["relatedPests"]),
                                "relatedDiseases":
                                    normalizeList(crop["relatedDiseases"]),
                                "relatedWeeds":
                                    normalizeList(crop["relatedWeeds"]),
                              };

                              await LocalCrops.saveCrop(id, normalized);

                              // Descargar relacionados
                              await downloadRelatedData(normalized, id);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("$name descargado ✔")),
                                );

                                context.push("/crop/$id");
                              }
                            },
                          );
                        },
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

// ---------------- TARJETA ----------------
class _CropCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback? onTap;

  const _CropCard({required this.name, required this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      borderRadius: border,
      child: InkWell(
        onTap: onTap,
        borderRadius: border,
        child: ClipRRect(
          borderRadius: border,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 36,
                  color: AppColors.buttons,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
