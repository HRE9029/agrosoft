import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';
import '../../../services/local_my_crops.dart';
import '../../../services/notifications_service.dart';

class AddCropPage extends StatefulWidget {
  const AddCropPage({super.key});

  @override
  State<AddCropPage> createState() => _AddCropPageState();
}

class _AddCropPageState extends State<AddCropPage> {
  String? selectedCropId;
  Map<String, dynamic>? selectedCropData;

  String? selectedStage;
  String? selectedSoil;
  String? selectedIrrigation;

  final TextEditingController notesCtrl = TextEditingController();
  final TextEditingController surfaceCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now();
  int parcelNumber = 1;

  @override
  void initState() {
    super.initState();
    loadParcelNumber();
  }

  Future<void> loadParcelNumber() async {
    final crops = await LocalMyCrops.getAllMyCrops();
    parcelNumber = crops.length + 1;
    setState(() {});
  }

  Future<void> pickDate() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate != null) {
      setState(() => selectedDate = newDate);
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 60,
                    child: Image.asset("assets/images/agrosoft_logo.png"),
                  ),
                  const Spacer(),
                ],
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
                        // ---------------- TÍTULO + FECHA ----------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Parcela $parcelNumber",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            GestureDetector(
                              onTap: pickDate,
                              child: Text(
                                "${selectedDate.day.toString().padLeft(2, '0')}/"
                                "${selectedDate.month.toString().padLeft(2, '0')}/"
                                "${selectedDate.year}",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 🔽 CULTIVOS DESDE FIRESTORE
                        const Text("Cultivo", style: _labelStyle),
                        const SizedBox(height: 6),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("crops")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final docs = snapshot.data!.docs;

                            return _DropdownContainer(
                              value: selectedCropId,
                              hintText: "Selecciona un cultivo",
                              items: docs.map((d) {
                                final data =
                                    d.data() as Map<String, dynamic>;
                                return DropdownMenuItem<String>(
                                  value: d.id,
                                  child: Text(
                                    data["name"] ?? "Cultivo",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                selectedCropId = v;
                                final crop =
                                    docs.firstWhere((d) => d.id == v);
                                selectedCropData =
                                    crop.data() as Map<String, dynamic>;

                                selectedStage = null;
                                setState(() {});
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // 🔽 ETAPAS DINÁMICAS
                        const Text("Etapa del cultivo", style: _labelStyle),
                        const SizedBox(height: 6),
                        _DropdownContainer(
                          value: selectedStage,
                          hintText: "Selecciona etapa",
                          items:
                              (selectedCropData?["stages"] ??
                                      ["V1", "V2", "V3", "VT", "R1"])
                                  .map<DropdownMenuItem<String>>(
                                    (e) => DropdownMenuItem<String>(
                                      value: e.toString(),
                                      child: Text(
                                        e.toString(),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => selectedStage = v),
                        ),

                        const SizedBox(height: 18),

                        // 🔽 TIPO DE SUELO
                        const Text("Tipo de suelo", style: _labelStyle),
                        const SizedBox(height: 6),
                        _DropdownContainer(
                          value: selectedSoil,
                          hintText: "Selecciona tipo de suelo",
                          items: [
                            "Arcilloso",
                            "Arenoso",
                            "Franco",
                            "Franco-arenoso",
                            "Franco-arcilloso",
                            "Limoso",
                          ]
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedSoil = v),
                        ),

                        const SizedBox(height: 18),

                        // 🔽 SISTEMA DE RIEGO
                        const Text("Sistema de riego", style: _labelStyle),
                        const SizedBox(height: 6),
                        _DropdownContainer(
                          value: selectedIrrigation,
                          hintText: "Selecciona sistema",
                          items: [
                            "Goteo",
                            "Rodado",
                            "Aspersión",
                            "Microaspersión",
                          ]
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedIrrigation = v),
                        ),

                        const SizedBox(height: 18),

                        // 🔽 SUPERFICIE
                        const Text("Superficie (m²)", style: _labelStyle),
                        const SizedBox(height: 6),
                        TextField(
                          controller: surfaceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration,
                        ),

                        const SizedBox(height: 18),

                        // 🔽 NOTAS
                        const Text("Notas", style: _labelStyle),
                        const SizedBox(height: 6),
                        TextField(
                          controller: notesCtrl,
                          maxLines: 3,
                          decoration: _inputDecoration,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ================= FOOTER CON BOTÓN =================
            Container(
              height: 80,
              width: double.infinity,
              color: AppColors.headerFooter,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              child: Center(
                child: GestureDetector(
                  onTap: saveCrop,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Agregar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  // ===========================================================================================
  //  GUARDA EL CULTIVO + PROGRAMA NOTIFICACIONES
  // ===========================================================================================
  Future<void> saveCrop() async {
    if (selectedCropId == null ||
        selectedStage == null ||
        selectedSoil == null ||
        selectedIrrigation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Completa todos los campos")),
        );
      }
      return;
    }

    final id = "parcela_$parcelNumber";

    // Calcular intervalo de riego
    int irrigationInterval;
    switch (selectedIrrigation) {
      case "Goteo":
        irrigationInterval = 2;
        break;
      case "Rodado":
        irrigationInterval = 7;
        break;
      case "Aspersión":
        irrigationInterval = 3;
        break;
      case "Microaspersión":
        irrigationInterval = 3;
        break;
      default:
        irrigationInterval = 5;
    }

    final nextIrrigationDate =
        selectedDate.add(Duration(days: irrigationInterval));
    final estimatedHarvest =
        selectedDate.add(const Duration(days: 120)); // estimación simple

    await LocalMyCrops.saveMyCrop(id, {
      "id": id,
      "parcelName": "Parcela $parcelNumber",
      "cropId": selectedCropId,
      "cropName": selectedCropData?["name"],
      "imageUrl": selectedCropData?["imageUrl"],
      "stage": selectedStage,
      "soil": selectedSoil,
      "irrigation": selectedIrrigation,
      "surface": surfaceCtrl.text.trim(),
      "notes": notesCtrl.text.trim(),
      "date": selectedDate.toIso8601String(),
      "nextIrrigationDate": nextIrrigationDate.toIso8601String(),
      "estimatedHarvestDate": estimatedHarvest.toIso8601String(),
      "history": [],
    });

    // Notificaciones
    await NotificationsService.scheduleIrrigation(
      nextIrrigationDate,
      selectedCropData?["name"] ?? "Tu cultivo",
    );

    await NotificationsService.scheduleHarvest(
      estimatedHarvest,
      selectedCropData?["name"] ?? "Tu cultivo",
    );

    if (!mounted) return;
    context.pop();
  }
}

// ===================== WIDGETS REUSABLES ======================

const _labelStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: Colors.black87,
);

class _DropdownContainer extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;

  const _DropdownContainer({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.fieldFill, // amarillo del prototipo
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.fieldFill, // menú amarillo también
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          hint: Text(
            hintText,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

final _inputDecoration = InputDecoration(
  filled: true,
  fillColor: const Color(0xFF4D4A42), // gris oscuro tipo prototipo
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  ),
);
