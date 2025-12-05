import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';
import '../../../services/local_my_crops.dart'; // <-- CAMBIO IMPORTANTE

class MyCropsPage extends StatefulWidget {
  const MyCropsPage({super.key});

  @override
  State<MyCropsPage> createState() => _MyCropsPageState();
}

class _MyCropsPageState extends State<MyCropsPage> {
  List<Map<String, dynamic>> myCrops = [];
  String search = "";

  @override
  void initState() {
    super.initState();
    loadMyCrops();
  }

  // ---------------- CARGAR CULTIVOS ----------------
  Future<void> loadMyCrops() async {
    final crops = await LocalMyCrops.getAllMyCropsList();

    setState(() {
      myCrops = crops; // <-- YA ES UNA LISTA CORRECTA
    });
  }

  // ---------------- ELIMINAR CULTIVO ----------------
  Future<void> deleteCrop(String id) async {
    await LocalMyCrops.deleteMyCrop(id);
    await loadMyCrops();
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 110;
    const double maxWidth = 520;

    // ---------------- FILTRO DE BÚSQUEDA ----------------
    final filtered = myCrops.where((crop) {
      final name = crop["name"]?.toString().toLowerCase() ?? "";
      return name.contains(search.toLowerCase());
    }).toList();

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
              child: Center(
                child: SizedBox(
                  height: 70,
                  child: Image.asset("assets/images/agrosoft_logo.png"),
                ),
              ),
            ),

            // ---------------- CONTENIDO ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------- BUSCADOR ----------------
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.black87),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Estoy buscando...",
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (v) =>
                                      setState(() => search = v.trim()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ---------------- TÍTULO + BOTÓN ----------------
                        Row(
                          children: [
                            const Text(
                              "Mis cultivos",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => context.push('/add-crop'),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.buttons,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // ---------------- LISTA DE CULTIVOS ----------------
                        if (filtered.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                "No tienes cultivos guardados",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),

                        ...filtered.map((crop) {
                          final cropId = crop["id"] ?? "undefined";
                          final name = crop["name"] ?? "Cultivo";
                          final imageUrl = crop["imageUrl"] ?? "";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _MyCropCard(
                              name: name,
                              imageUrl: imageUrl,
                              onTap: () {
                                context.push('/my-crop/$cropId', extra: crop);
                              },
                              onDelete: () => deleteCrop(cropId),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================
//                  TARJETA DE CULTIVO
// ========================================================
class _MyCropCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MyCropCard({
    required this.name,
    required this.imageUrl,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(12);

    return Material(
      borderRadius: border,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: border,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: border,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // -------- IMAGEN --------
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  height: 90,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 90,
                    width: 100,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),

              // -------- NOMBRE --------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              // -------- BOTÓN BORRAR --------
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.delete, color: Colors.red, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
