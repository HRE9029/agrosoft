import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/local_weeds.dart';
import '../../../theme.dart';

class WeedDetailPage extends StatefulWidget {
  final String weedId;

  const WeedDetailPage({super.key, required this.weedId});

  @override
  State<WeedDetailPage> createState() => _WeedDetailPageState();
}

class _WeedDetailPageState extends State<WeedDetailPage> {
  Map<String, dynamic>? weed;

  @override
  void initState() {
    super.initState();
    loadWeed();
  }

  Future<void> loadWeed() async {
    weed = await LocalWeeds.getWeed(widget.weedId);
    setState(() {});
  }

  Widget textSection(String title, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value.toString(),
            style: const TextStyle(fontSize: 16, height: 1.35)),
        const SizedBox(height: 16),
      ],
    );
  }

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
    if (weed == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = weed!["name"] ?? "";
    final sci = weed!["scientificName"] ?? "";
    final img = weed!["imageUrl"] ?? "";

    final desc = weed!["description"];
    final symptoms = weed!["symptoms"];
    final damage = weed!["damage"];

    final control = weed!["control"] ?? {};
    final cultural = control["cultural"];
    final manual = control["manual"];
    final quimico = control["quimico"];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
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
                    "Maleza",
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800),
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

                    const SizedBox(height: 16),

                    // Imagen
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

                    // 🔥 SECCIONES COMPLETAS
                    textSection("Descripción", desc),
                    listSection("Síntomas", symptoms),
                    listSection("Daños", damage),

                    listSection("Control cultural", cultural),
                    listSection("Control manual", manual),
                    listSection("Control químico", quimico),
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
