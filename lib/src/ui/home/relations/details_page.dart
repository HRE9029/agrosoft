// 💚 details_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';

class ItemDetailPage extends StatefulWidget {
  final String id;
  final String type;

  const ItemDetailPage({
    super.key,
    required this.id,
    required this.type,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  Map<String, dynamic>? data;
  bool loading = true;

  String get collectionName {
    switch (widget.type) {
      case "pest": return "pests";
      case "disease": return "diseases";
      case "weed": return "weeds";
      default: return "pests";
    }
  }

  String get typeTitle {
    switch (widget.type) {
      case "pest": return "PLAGA";
      case "disease": return "ENFERMEDAD";
      case "weed": return "MALEZA";
      default: return widget.type.toUpperCase();
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(widget.id)
          .get();

      if (doc.exists) {
        data = doc.data()!;
      }
    } catch (e) {
  debugPrint("Error en details_page: $e");
}

    setState(() => loading = false);
  }

  Widget _listSection(String title, dynamic list) {
    if (list == null || list.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...list.map<Widget>((item) =>
            Text("• $item", style: const TextStyle(fontSize: 16))),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _controlSection(dynamic control) {
    if (control == null || control is! Map) return const SizedBox();

    List<Widget> list = [];

    control.forEach((key, value) {
      if (value is List) {
        list.add(_listSection(
          key[0].toUpperCase() + key.substring(1),
          value,
        ));
      }
    });

    if (list.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Control",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...list,
      ],
    );
  }

  Widget _textSection(String title, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value.toString(), style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (data == null) {
      return const Scaffold(body: Center(child: Text("No se encontró información")));
    }

    final name = data!["name"] ?? "";
    final image = data!["imageUrl"] ?? "";
    final description = data!["description"];
    final symptoms = data!["symptoms"];
    final damage = data!["damage"];
    final control = data!["control"];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.headerFooter,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Text(typeTitle,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
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
                    if (image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(image,
                            height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 20),

                    Text(name,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 20),

                    _textSection("Descripción", description),
                    _listSection("Síntomas", symptoms),
                    _listSection("Daños", damage),
                    _controlSection(control),
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
