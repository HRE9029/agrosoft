import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agrosoft/src/services/local_crops.dart';
import '../../theme.dart';

// 🔥 IMPORTANTE
import 'package:agrosoft/src/router/route_observer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Map<String, dynamic> localCrops = {};
  Map<String, dynamic> filteredCrops = {};

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocalCrops();

    searchController.addListener(() {
      _applySearch();
    });
  }

  // 🔥 Nos suscribimos al RouteObserver
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  // 🔥 Cuando regresas al Home desde otra pantalla
  @override


  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalCrops() async {
    final data = await LocalCrops.getAllCrops();

   

    setState(() {
      localCrops = data;
      filteredCrops = Map.from(localCrops);
    });
  }

  void _applySearch() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() => filteredCrops = Map.from(localCrops));
      return;
    }

    setState(() {
      filteredCrops = {
        for (var entry in localCrops.entries)
          if ((entry.value["name"] ?? "")
              .toString()
              .toLowerCase()
              .contains(query))
            entry.key: entry.value
      };
    });
  }

  Future<void> _deleteCrop(String id) async {
    await LocalCrops.deleteCrop(id);
    await _loadLocalCrops();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cultivo eliminado")),
      );
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
              alignment: Alignment.center,
              child: SizedBox(
                height: 70,
                child: Image.asset('assets/images/agrosoft_logo.png'),
              ),
            ),

            // ---------------- CONTENIDO ----------------
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadLocalCrops,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------- BUSCADOR ----------------
                        Container(
                          height: 46,
                          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Estoy buscando...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ---------------- CULTIVOS ----------------
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const _SectionTitle('Cultivos'),
                              const SizedBox(width: 10),
                              _IconButtonSquare(
                                icon: Icons.add,
                                onTap: () => context.push('/all-crops'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ---------------- GRID ----------------
                        Expanded(
                          child: filteredCrops.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No tienes cultivos descargados.\nPresiona el botón + para agregar.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 10, 16, 40),
                                  itemCount: filteredCrops.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 1.2,
                                  ),
                                  itemBuilder: (_, i) {
                                    final key =
                                        filteredCrops.keys.elementAt(i);
                                    final crop = filteredCrops[key];

                                    return _CropCard(
                                      label: crop['name'] ?? key,
                                      imageUrl: crop['imageUrl'] ?? "",
                                      onTap: () {
                                        context.push(
                                          '/crop/$key',
                                          extra: crop['name'],
                                        );
                                      },
                                      onDelete: () => _deleteCrop(key),
                                    );
                                  },
                                ),
                        ),
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

//---------------- TITULO SECCIÓN ----------------
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Colors.black87,
      ),
    );
  }
}

//---------------- BOTÓN CUADRADO ----------------
class _IconButtonSquare extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _IconButtonSquare({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.buttons,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: SizedBox(
          height: 28,
          width: 28,
          child: Icon(icon, size: 17, color: Colors.white),
        ),
      ),
    );
  }
}

//---------------- TARJETA DE CULTIVO ----------------
class _CropCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _CropCard({
    required this.label,
    required this.imageUrl,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      borderRadius: border,
      child: InkWell(
        borderRadius: border,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: border,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                )
              else
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFAEDCB7),
                        Color(0xFF6BB082),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 38,
                  color: AppColors.buttons,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
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
