import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/local_crops.dart';
import '../../../theme.dart';

class PestsListPage extends StatefulWidget {
  final String cropId;
  final String cropName;

  const PestsListPage({
    super.key,
    required this.cropId,
    required this.cropName,
  });

  @override
  State<PestsListPage> createState() => _PestsListPageState();
}

class _PestsListPageState extends State<PestsListPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = LocalCrops.getPestsForCrop(widget.cropId);
  }

  @override
  Widget build(BuildContext context) {
    const double headerH = 110;
    const double maxW = 520;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: headerH,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Plagas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.cropName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // LISTA
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Center(child: Text("No hay plagas guardadas"));
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxW),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final p = items[i];
                          final id = p["id"] as String;
                          final name = p["name"] ?? "";
                          final sci = p["scientificName"] ?? "";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RelatedCard(
                              title: name,
                              subtitle: sci,
                              onTap: () {
                                context.push("/pest-detail/$id");
                              },
                            ),
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

class _RelatedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RelatedCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldFill,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
