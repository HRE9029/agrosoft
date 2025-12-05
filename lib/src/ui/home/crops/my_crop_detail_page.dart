import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';
import '../../../services/local_my_crops.dart';
import '../../../services/notifications_service.dart';

class MyCropDetailPage extends StatefulWidget {
  final String cropId;

  const MyCropDetailPage({super.key, required this.cropId});

  @override
  State<MyCropDetailPage> createState() => _MyCropDetailPageState();
}

class _MyCropDetailPageState extends State<MyCropDetailPage> {
  Map<String, dynamic>? crop;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCrop();
  }

  // =========================================================
  //                      CARGAR PARCELA
  // =========================================================
  Future<void> _loadCrop() async {
    final data = await LocalMyCrops.getMyCrop(widget.cropId);

    if (data == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se encontró la parcela")),
        );
        context.pop();
      }
      return;
    }

    final normalized = Map<String, dynamic>.from(data);

    final startDate =
        DateTime.tryParse(normalized["date"] ?? "") ?? DateTime.now();

    final irrigationType = normalized["irrigation"] ?? "";
    final irrigationIntervalDays = _getIrrigationIntervalDays(irrigationType);

    DateTime lastIrrigation =
        DateTime.tryParse(normalized["lastIrrigationDate"] ?? "") ?? startDate;

    DateTime nextIrrigation =
        DateTime.tryParse(normalized["nextIrrigationDate"] ?? "") ??
        lastIrrigation.add(Duration(days: irrigationIntervalDays));

    normalized["currentStage"] ??= normalized["stage"];

    DateTime estimatedHarvest =
        DateTime.tryParse(normalized["estimatedHarvestDate"] ?? "") ??
        startDate.add(const Duration(days: 120));

    List history = normalized["history"] ?? [];
    history = List<Map<String, dynamic>>.from(
      history.map((e) => Map<String, dynamic>.from(e)),
    );

    // Guardar normalizado
    normalized["lastIrrigationDate"] = lastIrrigation.toIso8601String();
    normalized["nextIrrigationDate"] = nextIrrigation.toIso8601String();
    normalized["estimatedHarvestDate"] = estimatedHarvest.toIso8601String();
    normalized["history"] = history;

    setState(() {
      crop = normalized;
      loading = false;
    });

    await LocalMyCrops.saveMyCrop(normalized["id"], normalized);
  }

  // =========================================================
  //                        UTILIDADES
  // =========================================================
  int _getIrrigationIntervalDays(String type) {
    switch (type) {
      case "Goteo":
        return 2;
      case "Rodado":
        return 7;
      case "Aspersión":
        return 3;
      case "Microaspersión":
        return 3;
      default:
        return 5;
    }
  }

  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  // =========================================================
  //                      ACCIONES BOTONES
  // =========================================================

  Future<void> _registerIrrigation() async {
    if (crop == null) return;

    final now = DateTime.now();
    final interval = _getIrrigationIntervalDays(crop!["irrigation"] ?? "");
    final next = now.add(Duration(days: interval));

    final history = List<Map<String, dynamic>>.from(crop!["history"] ?? []);
    history.add({
      "type": "irrigation",
      "label": "Riego realizado",
      "date": now.toIso8601String(),
    });

    crop!
      ..["lastIrrigationDate"] = now.toIso8601String()
      ..["nextIrrigationDate"] = next.toIso8601String()
      ..["history"] = history;

    await LocalMyCrops.saveMyCrop(crop!["id"], crop!);
    setState(() {});

    // 🔔 Notificación inmediata
    NotificationsService.showInstantNotification(
      "Riego registrado",
      "El siguiente riego será el ${_formatDate(next)}",
    );

    // 🔔 Notificación programada
    NotificationsService.scheduleNotification(
      next,
      "Riego pendiente",
      "Hoy toca regar tu ${crop!["parcelName"]}",
    );
  }

  Future<void> _advanceStage() async {
    if (crop == null) return;

    final stages =
        (crop!["stages"] ?? ["Siembra", "V1", "V2", "V3", "VT", "R1"])
            .cast<String>();

    final current = crop!["currentStage"] ?? stages.first;
    final index = stages.indexOf(current);

    if (index == -1 || index == stages.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ya estás en la última etapa.")),
      );
      return;
    }

    final nextStage = stages[index + 1];
    final now = DateTime.now();

    final history = List<Map<String, dynamic>>.from(crop!["history"] ?? []);
    history.add({
      "type": "stage",
      "label": "Etapa cambiada a $nextStage",
      "date": now.toIso8601String(),
    });

    crop!
      ..["currentStage"] = nextStage
      ..["history"] = history;

    await LocalMyCrops.saveMyCrop(crop!["id"], crop!);
    setState(() {});

    NotificationsService.showInstantNotification(
      "Etapa actualizada",
      "Ahora tu cultivo está en: $nextStage",
    );
  }

  Future<void> _markHarvestDone() async {
    if (crop == null) return;

    final now = DateTime.now();

    final history = List<Map<String, dynamic>>.from(crop!["history"] ?? []);
    history.add({
      "type": "harvest",
      "label": "Cosecha realizada",
      "date": now.toIso8601String(),
    });

    crop!
      ..["harvestDone"] = true
      ..["harvestDoneDate"] = now.toIso8601String()
      ..["history"] = history;

    await LocalMyCrops.saveMyCrop(crop!["id"], crop!);
    setState(() {});

    NotificationsService.showInstantNotification(
      "Cosecha realizada",
      "Felicidades, completaste la cosecha 🎉",
    );
  }

  // =========================================================
  //                      INTERFAZ
  // =========================================================

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 110;
    const double maxWidth = 520;

    if (loading || crop == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final parcelName = crop!["parcelName"];
    final cropName = crop!["cropName"];
    final imageUrl = crop!["imageUrl"] ?? "";

    final startDate = DateTime.tryParse(crop!["date"] ?? "") ?? DateTime.now();
    final lastIrrigation =
        DateTime.tryParse(crop!["lastIrrigationDate"] ?? "") ?? startDate;
    final nextIrrigation =
        DateTime.tryParse(crop!["nextIrrigationDate"] ?? "") ??
        lastIrrigation.add(const Duration(days: 5));
    final estimatedHarvest =
        DateTime.tryParse(crop!["estimatedHarvestDate"] ?? "") ??
        startDate.add(const Duration(days: 120));

    final today = DateTime.now();
    final daysToNextIrrigation = nextIrrigation.difference(today).inDays;
    final daysToHarvest = estimatedHarvest.difference(today).inDays;

    final harvestDone = crop!["harvestDone"] == true;

    final history = List<Map<String, dynamic>>.from(crop!["history"] ?? []);

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
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        parcelName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        cropName,
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ETAPA
                        Text(
                          "Etapa: ${crop!["currentStage"] ?? crop!["stage"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // IMAGEN / PLOT
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _fakePlot(),
                                )
                              : _fakePlot(),
                        ),
                        const SizedBox(height: 18),

                        // ------------------ RIEGO ------------------
                        const Text(
                          "Riego",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("Último: ${_formatDate(lastIrrigation)}"),
                        Text("Próximo: ${_formatDate(nextIrrigation)}"),
                        if (daysToNextIrrigation < 0)
                          Text(
                            "⚠ Riego atrasado ${-daysToNextIrrigation} días",
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 10),

                        // ------------------ ETAPA ------------------
                        const Text(
                          "Etapa",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("Actual: ${crop!["currentStage"]}"),
                        const SizedBox(height: 10),

                        // ------------------ SUPERFICIE ------------------
                        const Text(
                          "Superficie",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("${crop!["surface"] ?? "-"} m²"),
                        const SizedBox(height: 10),

                        // ------------------ FECHAS ------------------
                        const Text(
                          "Inicio de siembra",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(_formatDate(startDate)),
                        const SizedBox(height: 8),

                        const Text(
                          "Fecha estimada de cosecha",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(_formatDate(estimatedHarvest)),
                        if (!harvestDone && daysToHarvest <= 15)
                          Text(
                            daysToHarvest >= 0
                                ? "🌾 Cosecha en aproximadamente $daysToHarvest días"
                                : "⚠ Cosecha estimada pasada hace ${-daysToHarvest} días",
                            style: const TextStyle(color: Colors.brown),
                          ),
                        if (harvestDone)
                          const Text(
                            "✅ Cosecha realizada",
                            style: TextStyle(color: Colors.green),
                          ),

                        const SizedBox(height: 20),

                        // BOTONES ACCIÓN
                        _ActionButton(
                          text: "Registrar riego",
                          onTap: _registerIrrigation,
                        ),
                        const SizedBox(height: 10),
                        _ActionButton(
                          text: "Avanzar etapa",
                          onTap: _advanceStage,
                        ),
                        const SizedBox(height: 10),
                        _ActionButton(
                          text: "Marcar cosecha realizada",
                          onTap: _markHarvestDone,
                        ),

                        const SizedBox(height: 24),

                        // HISTORIAL
                        const Text(
                          "Historial",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (history.isEmpty)
                          const Text(
                            "Aún no hay eventos registrados.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          )
                        else
                          Column(
                            children: history.reversed.map((h) {
                              final date =
                                  DateTime.tryParse(h["date"] ?? "") ??
                                  DateTime.now();
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("• "),
                                    Expanded(
                                      child: Text(
                                        "${h["label"]} – ${_formatDate(date)}",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
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

  // =========================================================
  //                    PLACEHOLDER DEL SUELO
  // =========================================================

  Widget _fakePlot() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: const Color(0xFFE0E0E0))),
          Container(
            height: 40,
            color: const Color(0xFF5A3218),
            alignment: Alignment.center,
            child: const Icon(Icons.spa, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ActionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.buttons,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
